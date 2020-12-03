//
//  UIDeviceOrientation.swift
//  SwiftEx
//
//  Created by Volkov Alexander on 14/4/19.
//  Copyright (c) 2019 Alexander Volkov. All rights reserved.
//

import UIKit


// MARK: - Helpful methods in UIDeviceOrientation
extension UIDeviceOrientation {
    
    /// Image orientation
    ///
    /// Usage in `AVCapturePhotoCaptureDelegate` implementation
    /// ```
    ///    private var deviceOrientation: UIDeviceOrientation = .faceUp
    ///
    ///    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
    ///        self.deviceOrientation = UIDevice.current.orientation
    ///        print("Device orientation: \(self.deviceOrientation.rawValue)")
    ///    }
    ///    ...
    ///    let image = UIImage(cgImage: imageData, scale: 1, orientation: deviceOrientation.toImageOrientation())
    ///```
    public func toImageOrientation() -> UIImage.Orientation {
        switch self {
        case UIDeviceOrientation.portrait, .faceUp: return UIImage.Orientation.right
        case UIDeviceOrientation.portraitUpsideDown, .faceDown: return UIImage.Orientation.left
        case UIDeviceOrientation.landscapeLeft: return UIImage.Orientation.up
        case UIDeviceOrientation.landscapeRight: return UIImage.Orientation.down
        case UIDeviceOrientation.unknown: return UIImage.Orientation.up
        }
    }
}
