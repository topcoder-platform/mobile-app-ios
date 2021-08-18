//
//  CodeScannerViewController.swift
//  QRCodeScanner
//
//  Created by Volkov Alexander on 12/22/2018.
//  Updated by Volkov Alexander on 12/3/2020.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage

/// alias to easy usage (uses the library name)
typealias QRCodeScanner = CodeScannerViewController

/// Screen states
public enum CodeScannerScreenState {
    /**
     - noCamera - camera is not yet configured or missing on a given device
     - hasCamera - camera configuration completed. The state also means that code is not yet scanned
     - detecting - the code has detected and delegated to `callbackProcessCode`. New codes will not be detected at this point.
     - completed - the code was proceeded and `callbackCodeScanned` will be called immidiately
     */
    case noCamera, hasCamera, detecting, completed
}

/// CodeScannerViewController delegate
public protocol CodeScannerViewControllerDelegate {
    
    /// Update UI with new state and suggested status text (you can use your own depending on the state)
    /// - Parameters:
    ///   - text: the status text
    ///   - screenState: the screen state
    func codeScannerUpdateUIStatus(text: String, screenState: CodeScannerScreenState)
    
    /// Update flash button state (if is)
    /// - Parameter mode: the flash mode
    func codeScannerUpdateUIFlashButton(mode: AVCaptureDevice.FlashMode)
    
}

/// CodeScannerViewController delegate for rendering corners
public protocol CodeScannerViewControllerCornersDelegate {
    
    /// Update corners
    /// - Parameters:
    ///   - x1: x - of left top corner
    ///   - y1: y - of left top corner
    ///   - x2: x - of right bottom corner
    ///   - y2: x - of right bottom corner
    func codeScannerUpdateCorners(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat)
}

/**
 View controller used to display camera which scans codes defined by `codeTypes`
 - Add `NSCameraUsageDescription` to `Info.plist`, e.g.:
 ```
 <key>NSCameraUsageDescription</key>
 <string>Will scan QR codes</string>
 ```
 - Create view controller in XIB and set its class to `CodeScannerViewController` and specify identifier, e.g. `CodeScannerViewController`
 - Add view, set its class to `CameraPreviewView` and connect it with `previewView` outlet.
 - Instantiate `CodeScannerViewController` in code and configure using public vars and callbacks, e.g. you need at least define `callbackCodeScanned`.
 - Optionally configure:
 - - `codeTypes` - to limit the recognized code types
 - - `delegate` - to handle different states of the scanner (add `import AVFoundation`)
 - Dismiss the view controller in `callbackCodeScanned` callback.
 ```
 guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "CodeScannerViewController") as? CodeScannerViewController else {
    return
 }
 vc.callbackCodeScanned = { code in
    print("SCANNED CODE: \(code)")
    vc.dismiss(animated: true, completion: nil)
 }
 self.present(vc, animated: true, completion: nil)
 ```
 */
open class CodeScannerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate {
    
    /// preview views
    @IBOutlet public weak var previewView: CameraPreviewView!
    @IBOutlet weak var photoPreviewView: UIImageView?
    
    /// Camera types on iOS device
    public enum CameraType {
        case back, front
    }

    /// the callback for processing a scanned code code, e.g. to check if it's correct or related to the app (return true if code is correct)
    public var callbackProcessCode: ((String, @escaping (Bool)->())->())?
    /// the callback called when code is scanned. If `callbackProcessCode` is defined, then it's called after `callbackProcessCode` returns `true`, if not defined, then called immidiately after code is scanned.
    public var callbackCodeScanned: ((String)->())?
    
    public var delegate: CodeScannerViewControllerDelegate?
    public var cornersDelegate: CodeScannerViewControllerCornersDelegate?
    
    /// the supported code types
    public var codeTypes: [AVMetadataObject.ObjectType] = [.qr, .code39, .code93, .code128, .code39Mod43]
    
    /// screen state
    private var state: CodeScannerScreenState = .noCamera
    /// The type of the camera. Default - back camera.
    private var cameraType = CameraType.back
    /// Current AVCaptureSession and preview layer
    private var session: AVCaptureSession?
    
    /// Selected camera and device input
    private var lastUsedCamera: AVCaptureDevice?
    private var lastAddedInput: AVCaptureDeviceInput?
    
    /// metadata output
    private var metadataOutput: AVCaptureMetadataOutput?
    
    /// Last selected/captured image and code
    private var lastSourceImage: UIImage?
    private var lastUsedCode: String?
    
    /// true - will scan automatically
    private var automaticQRCodeScanner = true
    
    /// the current flash mode
    private var flashMode: AVCaptureDevice.FlashMode = .auto // dodo default from settings
    
    /// true - if access is verified and allowed
    private var accessVerifiedAndAllowed = false
    
    // MARK: - Camera initialization
    
    /// Initializes AVCaptureSession and configures camera
    open override func viewDidLoad() {
        super.viewDidLoad()
        session = AVCaptureSession()
        
        initCamera()
    }
    
    /// Initialize camera
    private func initCamera() {
        self.photoPreviewView?.image = nil
        self.lastSourceImage = nil
        if (session?.canSetSessionPreset(AVCaptureSession.Preset.photo) != nil) {
            session?.sessionPreset = AVCaptureSession.Preset.photo
            configureAndConnectCamera(byType: cameraType)
        }
        else {
            showError(errorMessage: NSLocalizedString("Code capture is not supported", comment: "Code capture is not supported"))
        }
        
        setupPreview()
        
        // dodo simulation of QR code reading. Uncomment if you need to test in simulator.
        //        delay(3) {
        //            self.lastUsedCode = "4b5fc6d2-ace5-4718-8ae1-f8a582b5f72c"
        //            self.processCapturedImage(callDelegate: true)
        //        }
    }
    
    /// Configure camera of given type and attach to the preview layer.
    /// Used during view controller initialization
    /// and when user switches the camera (need to support in UI and currently this case is not presented)
    ///
    /// - Parameter type: the camera type
    func configureAndConnectCamera(byType type: CameraType) {
        var camera: AVCaptureDevice?
        
        // Lock buttons for .noCamera state
        setStateAndSyncUI(.noCamera)
        
        switch type {
        case .front:
            camera = findCamera(position: .front)
        default:
            camera = findCamera(position: .back)
            if camera == nil {
                camera = findCamera(position: .front)
            }
        }
        
        // Add camera as input to the session
        if let cam = camera {
            session?.beginConfiguration()
            lastUsedCamera = cam
            configureCamera(cam)
            checkPermissions { [weak self] success in
                if success {
                    self?.accessVerifiedAndAllowed = true
                    self?.connectCamera(cam)
                    self?.setStateAndSyncUI(.hasCamera)
                }
                else {
                    self?.setStateAndSyncUI(.noCamera)
                }
                self?.session?.commitConfiguration()
                if self?.viewAppear == true && success {
                    self?.session?.startRunning()
                }
            }
        }
        else {
            session = nil
            delay(1) { [weak self] in
                self?.showError(errorMessage: NSLocalizedString("Camera not found.", comment: "Camera not found."))
            }
        }
        previewView.isHidden = false
    }
    
    private var viewAppear = false
    
    
    /// Turn on camera.
    ///
    /// - Parameter animated: the animation flag
    open override func viewDidAppear(_ animated: Bool) {
        viewAppear = true
        if accessVerifiedAndAllowed {
            session?.startRunning()
        }
    }
    
    /// Sets up preview layer
    func setupPreview() {
        if let session = session {
            previewView.videoPreviewLayer.session = session
        }
        previewView.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewView.videoPreviewLayer.backgroundColor = UIColor.gray.cgColor
        previewView.videoPreviewLayer.masksToBounds = true
    }
    
    /// Get camera of the given type
    ///
    /// - Parameter position:  device position that defines the camera type
    /// - Returns: the camera
    func findCamera(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        var camera: AVCaptureDevice?
        if #available(iOS 10.2, *) {
            var types: [AVCaptureDevice.DeviceType] = [.builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera]
            if #available(iOS 11.1, *) {
                types.append(.builtInTrueDepthCamera)
            }
            let devices = AVCaptureDevice.DiscoverySession(deviceTypes: types, mediaType: AVMediaType.video, position: position).devices
            for d in devices {
                camera = d
            }
        } else {
            let devices = AVCaptureDevice.devices()
            for d in devices {
                if d.hasMediaType(AVMediaType.video) {
                    if d.position == position {
                        camera = d
                    }
                }
            }
        }
        return camera
    }
    
    /// Configure camera
    ///
    /// - Parameter camera: camera the camera
    func configureCamera(_ camera: AVCaptureDevice) {
        do {
            try camera.lockForConfiguration()
            if camera.isFocusModeSupported(AVCaptureDevice.FocusMode.continuousAutoFocus) {
                camera.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
                camera.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
            }
            
            if camera.isExposureModeSupported(AVCaptureDevice.ExposureMode.continuousAutoExposure) {
                camera.exposurePointOfInterest = CGPoint(x: 0.5, y: 0.5)
                camera.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            }
            camera.unlockForConfiguration()
        }
        catch let error {
            print(error)
        }
    }
    /// Check permissions to the camera
    /// - Parameter callback: the callback used to notify when the app has access to the camera
    private func checkPermissions(callback: @escaping (Bool)->()) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            callback(true)
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    callback(granted)
                }
            }
        case .denied: // The user has previously denied access.
            delay(0) {
                self.showAlert("No access to the camera", "To scan QR codes you need to grant access to the cammera in Settings for this app")
            }
            callback(false)
            return
        case .restricted: // The user can't grant access due to restrictions.
            callback(false)
            return
        @unknown default:
            return
        }
    }
    
    /// Connect the camera and QR Code scanner to current session
    ///
    /// - Parameter camera: the camera
    func connectCamera(_ camera: AVCaptureDevice) {
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            // Remove last input
            if let last = lastAddedInput {
                session?.removeInput(last)
            }
            
            // Attach new input
            if (session?.canAddInput(input) != nil) {
                session?.addInput(input)
                self.lastAddedInput = input
            }
            else {
                showError(errorMessage: NSLocalizedString("Cannot add input from camera to the capture session", comment: "Cannot add input from camera to the capture session"))
            }
            
            // Add QR Code scanning
            setupAVFoundationQRCode()
        }
        catch let error {
            showError(errorMessage: NSLocalizedString("Cannot create input from camera:", comment: "Cannot create input from camera:") + " \(error)")
        }
    }
    
    // MARK: QR Code scanner
    
    /// Sets up QR code detection
    func setupAVFoundationQRCode() {
        let output = AVCaptureMetadataOutput()
        self.metadataOutput = output
        
        if let s = self.session {
            if !s.canAddOutput(output) {
                return
            }
            
            // Metadata processing will be fast, and mostly updating UI which should be done on the main thread
            output.setMetadataObjectsDelegate(self, queue: .main)
            s.addOutput(output)
            
            let types: [AVMetadataObject.ObjectType] = self.codeTypes
            var supportedTypes = [AVMetadataObject.ObjectType]()
            for type in types {
                if output.availableMetadataObjectTypes.contains(type) {
                    supportedTypes.append(type)
                }
            }
            output.metadataObjectTypes = supportedTypes
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    /// Handle metadata
    ///
    /// - Parameters:
    ///   - output: the output
    ///   - metadataObjects: the metadataObjects
    ///   - connection: the connection
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if state == .hasCamera || state == .detecting {
            let types: [AVMetadataObject.ObjectType] = codeTypes
            for metadataObject in metadataObjects {
                if types.contains(metadataObject.type) {
                    if let code = metadataObject as? AVMetadataMachineReadableCodeObject {
                        let corners = code.corners
                        self.lastUsedCode = code.stringValue
                        
                        /// Return and dismiss this screen automatically
                        if self.automaticQRCodeScanner {
                            processCapturedImage(corners: corners, callDelegate: state == .hasCamera)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Capture image
    
    /// "Scan" button action handler.
    /// Captures image from the camera
    ///
    /// - Parameter sender: the button
    @IBAction func captureAction(_ sender: AnyObject) {
        
        // If camera is on and photo is not yet selected/captured
        if state == .hasCamera {
            self.setStateAndSyncUI(.detecting)
            
            //            if #available(iOS 11.0, *) { dodo remove comments
            let output = AVCapturePhotoOutput()
            guard let camera = lastUsedCamera else { showError(errorMessage: NSLocalizedString("Camera not found.", comment: "Camera not found.")); return }
            let outputSettings = getSettings(camera: camera, flashMode: flashMode)
            
            previewView.isHidden = true
            self.lastUsedCode = nil
            if (session?.canAddOutput(output) != nil) {
                session?.addOutput(output)
                delay(0.5) {
                    output.capturePhoto(with: outputSettings, delegate: self)
                }
                return
            }
            //            } else {
            //                let stillImageOutput = AVCaptureStillImageOutput()
            //                let outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            //                stillImageOutput.outputSettings = outputSettings
            //
            //                previewView?.isHidden = true
            //                self.lastUsedCode = nil
            //                if (session?.canAddOutput(stillImageOutput) != nil) {
            //                    session?.addOutput(stillImageOutput)
            //                    let videoConnection = getVideoConnection(stillImageOutput)
            //                    if let conn = videoConnection {
            //                        delay(0.5) {
            //                            self.captureImage(stillImageOutput, conn)
            //                        }
            //                        return
            //                    }
            //                    else {
            //                        showError(errorMessage: "Cannot find video connection in AVCaptureStillImageOutput")
            //                    }
            //                }
            //            }
            
            self.setStateAndSyncUI(.hasCamera)
        }
        else if state == .noCamera {
            showError(errorMessage: NSLocalizedString("Cannot take picture for now.", comment: "Cannot take picture for now."))
        }
    }
    
    /// Get settings
    ///
    /// - Parameters:
    ///   - camera: the camera
    ///   - flashMode: the current flash mode
    /// - Returns: AVCapturePhotoSettings
    private func getSettings(camera: AVCaptureDevice, flashMode: AVCaptureDevice.FlashMode) -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])
        
        if camera.hasFlash {
            settings.flashMode = flashMode
        }
        return settings
    }
    
    //    ///  Saves image from the given AVCaptureStillImageOutput
    //    func captureImage(_ stillImageOutput: AVCaptureStillImageOutput, _ videoConnection: AVCaptureConnection) {
    //        // Change state
    //
    //        stillImageOutput.captureStillImageAsynchronously(
    //            from: videoConnection,
    //            completionHandler: { buff, error -> Void in
    //
    //                // Remove output from session
    //                self.session?.removeOutput(stillImageOutput)
    //
    //                if let err = error {
    //                    print("ERROR: \(err)")
    //                    showError(errorMessage: NSLocalizedString("Cannot capture image. Please try again.", comment: "Cannot capture image. Please try again."))
    //                }
    //                else if let buff = buff {
    //                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buff)
    //                    let image = UIImage(data: imageData ?? Data())
    //                    self.lastSourceImage = image
    //                    //                    self.lastImageData = imageData dodo
    //                    self.photoPreviewView?.image = image
    //                    self.processCapturedImage()
    //                }
    //                else {
    //                    print("ERROR: captureImage(stillImageOutput:,videoConnection:)")
    //                }
    //        })
    //    }
    
    //    /// Get AVCaptureConnection
    //    func getVideoConnection(_ stillImageOutput: AVCaptureStillImageOutput) -> AVCaptureConnection? {
    //        var videoConnection: AVCaptureConnection?
    //        for connection in stillImageOutput.connections {
    //            for p in connection.inputPorts {
    //                if p.mediaType == .video {
    //                    videoConnection = connection
    //                    break
    //                }
    //            }
    //        }
    //        return videoConnection
    //    }
    
    /// Process captured image.
    /// Returns image to the delegate and dismisses the view controller.
    ///
    /// - Parameter corners: the border corners
    func processCapturedImage(corners: [CGPoint]? = nil, callDelegate: Bool = true) {
        if let code = lastUsedCode {
            setStateAndSyncUI(.detecting)
            if let corners = corners, corners.count > 0 {
                var x1 = corners.first!.x
                var y1 = corners.first!.y
                var x2 = corners.first!.x
                var y2 = corners.first!.y
                for p in corners {
                    if p.x < x1 { x1 = p.x }
                    if p.y < y1 { y1 = p.y }
                    if p.x > x2 { x2 = p.x }
                    if p.y > y2 { y2 = p.y }
                }
                x1 = x1 * self.previewView.bounds.height
                x2 = x2 * self.previewView.bounds.height
                y1 = y1 * self.previewView.bounds.width
                y2 = y2 * self.previewView.bounds.width
                // delegate corner rendering
                cornersDelegate?.codeScannerUpdateCorners(x1: x1, y1: y1, x2: x2, y2: y2)
            }
            if callDelegate {
                // TODO delegate scan completion animation and call delegate after that.
                let animationCompleted = true
                var success: Bool = false
                if let callbackProcessCode = callbackProcessCode {
                    callbackProcessCode(code) { [weak self] res in
                        success = res
                        if animationCompleted {
                            if success {
                                self?.setStateAndSyncUI(.completed)
                                self?.callbackCodeScanned?(code)
                            }
                        }
                    }
                }
                else {
                    setStateAndSyncUI(.completed)
                    callbackCodeScanned?(code)
                }
            }
        }
        else {
            showAlert(NSLocalizedString("Retake QR Code", comment: "Retake QR Code"), NSLocalizedString("QR Code has not found on the image you have scanned. Please try retake the QR Code.", comment: "QR Code has not found on the image you have scanned. Please try retake the QR Code."))
        }
    }
    
    /// Animation shortcut
    ///
    /// - Parameters:
    ///   - duration: the animation duration
    ///   - completion: the completion callback
    private func animate(withDuration duration: TimeInterval, _ completion: @escaping ()->()) {
        UIView.animate(withDuration: duration, animations: {self.view.layoutIfNeeded()}, completion: {_ in completion()})
    }
    
    /// Sync UI with current state - changes buttons states
    ///
    /// - Parameter newState: new state
    internal func setStateAndSyncUI(_ newState: CodeScannerScreenState) {
        let oldState = state
        state = newState
        
        var statusText = NSLocalizedString("Align the QR Code with in grid for scanning", comment: "Align the QR Code with in grid for scanning")
        switch state {
        case .noCamera:
            break
        case .hasCamera:
            break
        case .detecting:
            statusText = NSLocalizedString("Scanning code...", comment: "Scanning code...")
        case .completed:
            statusText = NSLocalizedString("Scan completed", comment: "Scan completed")
        }
        
        delegate?.codeScannerUpdateUIStatus(text: statusText, screenState: newState)
        syncFlashButton()
        
        // If user clicks Retake photo
        if state != .detecting && oldState == .detecting {
            previewView.isHidden = false
            // OpenUp camera preview - just clear captured image
            self.photoPreviewView?.image = nil
            self.lastSourceImage = nil
        }
    }
    
    /// "Flash" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func flashAction(_ sender: Any) {
        // cycle through states
        flashMode = AVCaptureDevice.FlashMode(rawValue: flashMode.rawValue + 1) ?? AVCaptureDevice.FlashMode(rawValue: 0)!
        syncFlashButton()
    }
    
    /// Sync flash button state
    private func syncFlashButton() {
        delegate?.codeScannerUpdateUIFlashButton(mode: flashMode)
    }
    
    /// "Cancel" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func cancelAction(_ sender: Any) {
        closeViewController()
    }
    
    /// Stops session and dismisses view controller from the navigation view controller.
    func closeViewController(completion: (()->())? = nil) {
        session?.stopRunning()
        
        // Dismiss this view controller
        self.dismiss(animated: true, completion: completion)
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    @available(iOS 11.0, *)
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // Remove output from session
        self.session?.removeOutput(output)
        
        if let _ = error {
            showError(errorMessage: NSLocalizedString("Cannot capture image. Please try again.", comment: "Cannot capture image. Please try again."))
        }
        else if let imageData = photo.cgImageRepresentation()?.takeUnretainedValue() {
            let image = UIImage(cgImage: imageData)
            self.lastSourceImage = image
            self.photoPreviewView?.image = image
            self.processCapturedImage()
        }
    }
    
    // MARK: - General methods
    
    /// Displays alert with specified title & message
    ///
    /// - Parameters:
    ///   - title: the title
    ///   - message: the message
    ///   - completion: the completion callback
    private func showAlert(_ title: String, _ message: String, completion: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default,
                                      handler: { (_) -> Void in
                                        alert.dismiss(animated: true, completion: nil)
                                        DispatchQueue.main.async {
                                            completion?()
                                        }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Show alert with given error message
    ///
    /// - Parameters:
    ///   - errorMessage: the error message
    ///   - completion: the completion callback
    private func showError(errorMessage: String, completion: (()->())? = nil) {
        if Thread.isMainThread {
            showAlert(NSLocalizedString("Error", comment: "Error alert title"), errorMessage, completion: completion)
        }
        else {
            DispatchQueue.main.async {
                self.showAlert(NSLocalizedString("Error", comment: "Error alert title"), errorMessage, completion: completion)
            }
        }
    }
    
    /// Delay execution
    ///
    /// - Parameters:
    ///   - delay: the delay in seconds
    ///   - callback: the callback to invoke after 'delay' seconds
    private func execute(after delay: TimeInterval, _ callback: @escaping ()->()) {
        #if os(Linux)
        callback()
        #else
        let delay = delay * Double(NSEC_PER_SEC)
        let popTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: popTime, execute: {
            callback()
        })
        #endif
    }
    
    /// shortcut for `execute(after:callback)`
    private func delay(_ delay: TimeInterval, _ callback: @escaping ()->()) {
        execute(after: delay, callback)
    }
}

/// Preview view
public class CameraPreviewView: UIView {
    public override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    public var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

