//
//  RestServiceExtensions.swift
//  SwiftExInt
//
//  Created by Volkov Alexander on 3/14/19.
//  Copyright (c) 2019 Alexander Volkov. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import SwiftyJSON
import UIKit
//import SwiftExApi

extension RestServiceApi {
    
    /// Upload image
    /// Modified version of https://github.com/RxSwiftCommunity/RxAlamofire/issues/65
    ///
    /// - Parameters:
    ///   - image: the image
    ///   - url: URL
    ///   - parameters: the parameters
    ///   - headers: the headers
    /// - Returns: sequence
    public static func upload(image: UIImage, to url: URLConvertible, parameters: [String: String]? = nil, headers: [String: String] = [:]) ->  Observable<JSON> {
        var headers = headers
        for (k,v) in RestServiceApi.headers {
            headers[k] = v
        }
        return Observable<JSON>.create({observer in
            Alamofire.upload(multipartFormData: { multipartFormData in
                if let imageData = UIImageJPEGRepresentation(image, 0.9) {
                    multipartFormData.append(imageData, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
                }
                
                for (key, value) in parameters ?? [:] {
                    multipartFormData.append((value.data(using: .utf8))!, withName: key)
                }}, to: url, method: .post, headers: headers,
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                guard response.result.error == nil else {
                                    observer.onError(response.result.error!)
                                    return
                                }
                                if let value = response.result.value {
                                    observer.onNext(JSON(value))
                                }
                                else {
                                    observer.onNext(JSON.null)
                                }
                                observer.onCompleted()
                            }
                        case .failure(let encodingError):
                            observer.onError(encodingError)
                        }
            })
            return Disposables.create();
        })
    }
}
