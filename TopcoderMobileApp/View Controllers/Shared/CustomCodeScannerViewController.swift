//
//  CustomCodeScannerViewController.swift
//  TopcoderMobileApp
//
//  Created by Volkov Alexander on 8/14/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import Foundation
import QRCodeScanner83
import SwiftEx83

/// Custom QR code scanner
class CustomCodeScannerViewController: CodeScannerViewController {
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var codeBorder: UIView!
    @IBOutlet weak var scanningStatusLabel: UILabel!
    @IBOutlet var corners: [UIImageView]!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColoredCorners(false)
        scanningStatusLabel.isHidden = true
        cancelButton.round()
        codeBorder.backgroundColor = .clear
    
        callbackProcessCode = { [weak self] code, callback in
            self?.setColoredCorners(true)
            delay(3) {
                callback(true)
            }
        }
    }
    
    /// Apply mask
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyMask()
    }
    
    /// Apply mask to show window for the QR code
    private func applyMask() {
        overlayView.mask(codeBorder.frame, cornerSize: 11, invert: true)
    }
    
    /// Update color of the corners
    /// - Parameter colored: true - set highlighted color, false - default color
    private func setColoredCorners(_ colored: Bool) {
        for view in corners {
            view.tintColor = colored ? UIColor(0x59c653) : .white
        }
        scanningStatusLabel.isHidden = false
    }
}

extension UIView {
 
    /// Adds mask to the view
    /// - Parameters:
    ///   - rect: the mask rectangle
    ///   - cornerSize: the corner size
    ///   - invert: true - if need to invert the mask, false - normal mask
    func mask(_ rect: CGRect, cornerSize: CGFloat, invert: Bool = false) {
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        if invert {
            path.addRect(bounds)
        }
        path.addRoundedRect(in: rect, cornerWidth: cornerSize, cornerHeight: cornerSize)
        maskLayer.path = path
        if invert {
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        }
        // Set the mask of the view.
        layer.mask = maskLayer
    }
}
