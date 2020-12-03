//
//  UIImageExtension.swift
//  SwiftEx
//
//  Created by Volkov Alexander on 10/25/15.
//  Copyright (c) 2015-2018 Alexander Volkov. All rights reserved.
//

import UIKit

// MARK: - Extends UIImage with a shortcut methods
extension UIImage {

    /// Get image from given view
    ///
    /// - Parameter view: the view
    /// - Returns: UIImage
    public class func imageFromView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)

        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    /// Cut image
    ///
    /// - Parameter sides: the cuts
    /// - Returns: the image
    public func cut(_ sides: UIEdgeInsets)-> UIImage {
        let size = CGSize(width: self.size.width - sides.left - sides.right, height: self.size.height - sides.top - sides.bottom)
        let drawSize = CGRect(x: -sides.left, y: -sides.top, width: self.size.width, height: self.size.height)

        let imageObj = self

        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        imageObj.draw(in: drawSize)

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage ?? self
    }

    /// Combine images
    ///
    /// - Parameter list: the list of images
    /// - Returns: the result image
    public static func combineVertically(_ list: [UIImage]) -> UIImage? {
        var width: CGFloat = 0
        var height: CGFloat = 0
        for image in list {
            width = max(width, image.size.width)
        }
        var sizes = [CGSize]()
        for image in list {
            let k = width / image.size.width
            let drawSize = CGSize(width: width, height: image.size.height * k)
            height += image.size.height
            sizes.append(drawSize)
        }

        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), !hasAlpha, scale)
        var y: CGFloat = 0
        var i = 0
        for imageObj in list {
            let drawSize = sizes[i]
            imageObj.draw(in: CGRect(x: 0, y: y, width: drawSize.width, height: drawSize.height))
            y += drawSize.height
            i += 1
        }
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }

    /// Convert image to data
    ///
    /// - Returns: the data
    public func toData() -> Data? {

        if let data = UIImagePNGRepresentation(self) {
            return data
        }
        return nil
    }

    /// Convert data to image
    ///
    /// - Parameter data: the data
    /// - Returns: the image
    public class func from(data: Data?) -> UIImage? {
        if let data = data {
            return UIImage(data: data)
        }
        return nil
    }

    /// Resize image with given ratio
    ///
    /// - Parameter ratio: the ratio
    /// - Returns: the resized image
    func resize(withRatio ratio: CGFloat) -> UIImage {
        let image = self

        let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
//    public func pixelData() -> [UInt8]? {
//        let dataSize = size.width * size.height * 4
//        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let context = CGContext(data: &pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 4 * Int(size.width), space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
//        
//        guard let cgImage = self.cgImage else { return nil }
//        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//        
//        return pixelData
//    }
}

/// type alias for image request callback
public typealias ImageCallback = (UIImage?)->()

/// Class for storing in-memory cached images
public class UIImageCache {

    /// Cache for images
    public var CachedImages = [String: (UIImage?, [ImageCallback])]()

    /// the singleton
    static let shared: UIImageCache = UIImageCache()
}

/// Extends UIImage with a shortcut method.
extension UIImage {
    /// Load image
    ///
    /// - Parameters:
    ///   - url: image URL
    ///   - callback: the callback to return the image
    public class func load(fromUrl url: URL, callback: @escaping ImageCallback) {
        let key = url.absoluteString

        // If there is cached data, then use it
        if let data = UIImageCache.shared.CachedImages[key] {
            if data.1.isEmpty { // Is image already loadded, then use it
                callback(data.0)
            }
            else { // If image is not yet loaded, then add callback to the list of callbacks
                var savedCallbacks: [ImageCallback] = data.1
                savedCallbacks.append(callback)
                UIImageCache.shared.CachedImages[key] = (nil, savedCallbacks)
            }
            return
        }
        // If the image is first time requested, then load it
        UIImageCache.shared.CachedImages[key] = (nil, [callback])
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {

            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                DispatchQueue.main.async { () -> Void in
                    guard let data = data, error == nil else { callback(nil); return }
                    if let image = UIImage(data: data) {

                        // Notify all callbacks
                        for callback in UIImageCache.shared.CachedImages[key]!.1 {
                            callback(image)
                        }
                        UIImageCache.shared.CachedImages[key] = (image, [])
                        return
                    }
                    else {
                        print("ERROR: Error occured while creating image from the data: \(data) url=\(url)")
                    }
                }
            }) .resume()
        })
    }

    /// Load image.
    /// More simple method than load(fromUrl:) that helps to cover common fail cases
    /// and allow to concentrate on success loading.
    ///
    /// - Parameters:
    ///   - urlString: the url string
    ///   - callback: the callback to return the image
    public class func load(_ urlString: String?, callback: @escaping (UIImage?)->()) {
        if let urlStr = urlString {
            if urlStr.hasPrefix("http") {
                if let url = URL(string: urlStr) {
                    UIImage.load(fromUrl: url, callback: { (image: UIImage?) -> () in
                        callback(image)
                    })
                    return
                }
                else {
                    print("ERROR: Wrong URL: \(urlStr)")
                    callback(nil)
                }
            }
            // If urlString is not real URL, then try to load image from assets
            else if let image = UIImage(named: urlStr) {
                callback(image)
            }
        }
        else {
            callback(nil)
        }
    }
}
