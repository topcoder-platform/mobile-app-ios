//
//  ViewController.swift
// TopcoderMobileApp
//
//  Created by Volkov Alexander on 10/4/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import QRCodeScanner83
import SwiftEx83
import MobileWallet
import SwiftyJSON
import AVFoundation
import Combine

typealias VcxUtil = CMConfig

// TODO REMOVE. It's not used anymore.
class ViewController: UIViewController, CodeScannerViewControllerDelegate {
    
    /// outlets
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var checkCredentialsButton: UIButton!
    
    var cancellable: AnyCancellable?
    var serializedConnection: String?
    
    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = "SDK Initialization... Please wait."
        scanButton.isEnabled = false
        checkCredentialsButton.isEnabled = false
        NotificationCenter.add(observer: self, selector: #selector(notificationHandler(_:)), name: SdkEvent.ready)
    }
    
    @objc func notificationHandler(_ notification: NSNotification) {
        if notification.name.rawValue == SdkEvent.ready.rawValue {
            updateUI()
        }
    }
    
    private func updateUI() {
        if serializedConnection == nil {
            statusLabel.text = "You can scan an invitation now"
            scanButton.isEnabled = true
            checkCredentialsButton.isEnabled = false
        }
        else {
            statusLabel.text = "You can accept credential offers (if exist)"
            scanButton.isEnabled = true
            checkCredentialsButton.isEnabled = true
        }
    }
    
    /// "Scan.." button action handler
    ///
    /// - parameter sender: the button
    @IBAction func scanAction(_ sender: Any) {
        checkCredentialsButton.isEnabled = false
        openScanner()
    }
    
    @IBAction func checkCredentials(_ sender: Any) {
        guard let serializedConnection = serializedConnection else { return }
        print("CHECKING CREDENTIALS...")
        
        let util = VcxUtil.shared
        var connectionHandle: Int!
        var credentialHandle: Int!
        let loadingIndicator = ActivityIndicator(parentView: nil).start()
        
        statusLabel.text = "Checking offers..."
        // Deserialize a saved connection
        self.cancellable = util.connectionDeserialize(serializedConnection: serializedConnection)
            .map { handle in
                connectionHandle = handle
            }
            .flatMap({
                // Check agency for a credential offers
                util.credentialGetOffers(connectionHandle: connectionHandle)
            })
            .map { [weak self] offers -> String in
                let json = JSON(parseJSON: offers) // Parse offers
                print("Credential offers: ", json)
                // Use first offer
                if let firstOffer = json.arrayValue.first {
                    return firstOffer.rawString()!
                }
                loadingIndicator.stop()
                showError(errorMessage: "No offers")
                self?.updateUI()
                self?.cancellable?.cancel()
                return ""
            }
            .flatMap({ [weak self] offer -> Future<Int, Error> in
                // Create a credential object from the credential offer
                self?.statusLabel.text = "Processing an offer..."
                return util.credentialCreateWithOffer(sourceId: "1", credentialOffer: offer)
            })
            .map { handle in
                credentialHandle = handle
            }
            .flatMap({
                // Send a credential request
                util.credentialSendRequest(credentialHandle: credentialHandle, connectionHandle: connectionHandle, paymentHandle: 0)
            })
            .map { _ in
                sleep(4)
            }
            .flatMap({ [weak self] Void -> Future<Int, Error> in
                self?.statusLabel.text = "Accepting credential offer..."
                // Accept credential offer from faber
                return util.credentialUpdateState(credentialHandle: credentialHandle)
            })
            .map { _ in
                // Release vcx objects from memory
                _ = util.connectionRelease(handle: connectionHandle)
                _ = util.credentialRelease(credentialHandle: credentialHandle)
            }
            .sink(receiveCompletion: { [weak self] completion in
                loadingIndicator.stop()
                self?.updateUI()
                self?.showAlert("", "Credential offer accepted")
                switch completion {
                case .finished: break
                case .failure(let error): fatalError(error.localizedDescription)
                }
            }, receiveValue: { _ in })
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
                
                let loadingIndicator = ActivityIndicator(parentView: nil).start()
                var connectionHandle: Int!
                let util = VcxUtil.shared
                // Creating a connection
                self?.cancellable = util.connect(withInviteDetails: value.dictionaryObject ?? [:])
                    .flatMap({ handle -> Future<Void, Error> in
                        connectionHandle = handle
                        return util.connect(handle: handle, connectionType: .qr)
                    })
                    .map { _ in
                        sleep(4)
                }
                .flatMap({ handle in
                    util.connectionGetState(handle: connectionHandle)
                })
                    .flatMap({ state in
                        // TODO call update only `if(state != 4) {`
                        util.connectionUpdateState(handle: connectionHandle)
                    })
                    .flatMap({ _ in
                        util.connectionSerialize(handle: connectionHandle)
                    })
                    .map { value in
                        self?.serializedConnection = value
                        _ = util.connectionRelease(handle: connectionHandle)
                        self?.checkCredentialsButton.isEnabled = true
                        self?.updateUI()
                }
                .sink(receiveCompletion: { completion in
                    loadingIndicator.stop()
                    switch completion {
                    case .finished: break
                    case .failure(let error): showError(errorMessage: error.localizedDescription)
                    }
                }, receiveValue: { _ in })
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
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomCodeScannerViewController") as? CustomCodeScannerViewController else {
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

extension Publisher {
    
    /// Add delay to Future
    ///
    /// - Parameter time: the delay time
    /// - Returns: Future
    func withDelay(_ interval: TimeInterval) -> Future<Self.Output, Error> { // where Self.Output == P {
        let this = self
        return Future { promise in
            SwiftEx83.delay(interval) {
                _ = this.sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error): promise(.failure(error))
                    }
                }, receiveValue: { value in
                    promise(.success(value))
                })
            }
        }
    }
}
