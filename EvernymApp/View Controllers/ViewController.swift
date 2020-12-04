//
//  ViewController.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 10/4/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import QRCodeScanner83
import SwiftEx83
import AVFoundation

class ViewController: UIViewController, CodeScannerViewControllerDelegate {

    /// outlets
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    
    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = "SDK Initialization... Please wait."
        scanButton.isEnabled = false
        NotificationCenter.add(observer: self, selector: #selector(notificationHandler(_:)), name: SdkEvent.ready)
    }
    
    @objc func notificationHandler(_ notification: NSNotification) {
        if notification.name.rawValue == SdkEvent.ready.rawValue {
            statusLabel.text = "You can scan an invitation now"
            scanButton.isEnabled = true
        }
    }
    
    /// "Scan.." button action handler
    ///
    /// - parameter sender: the button
    @IBAction func scanAction(_ sender: Any) {
        openScanner()
    }
    
    /// Process invitation URL provided as QR code
    /// - Parameter code: the code
    private func process(code: String) {
        print("SCANNED CODE: \(code)")
        guard let url = URL(string: code) else { return }
        print("GETTING INVITATION...")
        RestServiceApi.getInvitation(url: url)
            .addActivityIndicator(on: UIViewController.getCurrentViewController() ?? self)
            .subscribe(onNext: { [weak self] value in
                print("INVITAION:\n\(value)")
                
                // Creating a connection
                CMConfig.connect(withInviteDetails: value) { [weak self] (handle, error) in
                    guard !ViewController.process(error: error) else { return }
                    
                    if let handle = handle {
                        CMConfig.connect(handle: handle) { (error) in
                            guard !ViewController.process(error: error) else { return }
                            
                            delay(4) {
                                CMConfig.connectionGetState(handle: handle) { (state, error) in
                                    guard !ViewController.process(error: error) else { return }
                                    CMConfig.connectionUpdateState(handle: handle) { (state2, error) in
                                        guard !ViewController.process(error: error) else { return }
                                        self?.showAlert("Connected", "Successfully connected using the invitation (handle \(handle)) and updated state=\(state) to state=\(state2)")
                                    }
                                }
                            }
                        }
                    }
                    else {
                        self?.showAlert("Connected", "Successfully connected using the invitation (no handle)")
                    }
                }
                return
                }, onError: { _ in
            }).disposed(by: rx.disposeBag)
    }
    
    
    /// Return true if there is an error
    private static func process(error: Error?) -> Bool {
        if let error = error {
            showError(errorMessage: error.localizedDescription)
            return true
        }
        return false
    }
    
    // MARK: - CodeScannerViewControllerDelegate
    
    private func openScanner() {
        // Open scanner
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CodeScannerViewController") as? CodeScannerViewController else {
            return
        }
        vc.delegate = self
        vc.callbackCodeScanned = { code in
            vc.dismiss(animated: true, completion: { [weak self] in
                self?.process(code: code)
            })
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func codeScannerUpdateUIStatus(text: String, screenState: CodeScannerScreenState) {
        print("state=\(screenState) status: \(text)")
    }
    
    func codeScannerUpdateUIFlashButton(mode: AVCaptureDevice.FlashMode) {
        /// nothing to do
    }
}

