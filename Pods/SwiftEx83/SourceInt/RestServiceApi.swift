//
//  RestServiceApi.swift
//  SwiftExInt
//
//  Created by Alexander Volkov on 31/12/18.
//  Copyright (c) 2018-2019 Alexander Volkov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift
import RxAlamofire
//import SwiftEx
//import SwiftExData
//import NSObject_Rx

/**
 * REST API implementation.
 * You can nest from this class or use directly to call API methods.
 *
 * - author: Volkov Alexander
 * - version: 1.0
 */
open class RestServiceApi {

    /// The callback used to notify about unauthorized access. Can be used to show login form.
    public static var callback401: (()->())?

    /// The common headers, e.g. "Authorization". Applied in every request.
    public static var headers: [String:String] = [:]
    
    /// The code used to check if user became unauthorized. It must be 401, but in some backends, e.g. Azure it's incorrectly 403 (https://developer.mozilla.org/ru/docs/Web/HTTP/Status/403). Can be set before class is used.
    public static var UNAUTHORIZED_CODES: [Int] = [401]
    
    /// The key and values in JSON response to check for UNAUTHORIZED case. In some cases backend returns 40X code with some error meaning UNAUTHORIZED. It can be used instead of updated UNAUTHORIZED_CODES when 403 may change the meaning depending on the code. When this values found in response, `callback401` will be called.
    public static var UNAUTHORIZED_JSON_ERROR: (String, [String])?
    
    /// true - will log all HTTP response readers, false - will log only HTTP code
    public static var LOG_RESPONSE_HEADERS = false
    
    /// Get request
    ///
    /// - Parameter url: URL
    /// - Returns: the observable
    public static func get<T: Decodable>(url: URLConvertible, parameters: [String: Any] = [:]) -> Observable<T> {
        var url = url
        if !parameters.isEmpty {
            url = "\(url)?\(parameters.toURLString())" 
        }
        return request(.get, url: url)
            .map { (json) -> T in
                return try json.decode(T.self)
        }
    }

    /// Get request
    ///
    /// - Parameter url: URL
    /// - Returns: the observable
    public static func get(url: URLConvertible) -> Observable<Void> {
        return request(.get, url: url).map { _ in }
    }

    /// POST request
    ///
    /// - Parameter url: URL
    /// - Returns: the observable
    public static func post<T: Decodable>(url: URLConvertible, parameters: [String: Any]) -> Observable<T> {
        return request(.post, url: url, parameters: parameters)
            .map { (json) -> T in
                return try json.decode(T.self)
        }
    }

    /// POST request
    ///
    /// - Parameter url: URL
    /// - Returns: the observable
    public static func put<T: Decodable>(url: URLConvertible, parameters: [String: Any]) -> Observable<T> {
        return request(.put, url: url, parameters: parameters)
            .map { (json) -> T in
                return try json.decode(T.self)
        }
    }

    /// PATCH request
    ///
    /// - Parameter url: URL
    /// - Returns: the observable
    public static func patch<T: Decodable>(url: URLConvertible, parameters: [String: Any]) -> Observable<T> {
        return request(.patch, url: url, parameters: parameters)
            .map { (json) -> T in
                return try json.decode(T.self)
        }
    }

    /// DELETE request
    ///
    /// - Parameter url: URL
    /// - Returns: the observable
    public static func delete(url: URLConvertible) -> Observable<Void> {
        return request(.delete, url: url).map { _ in }
    }
    
    // MARK: - Raw request methods

    /// Request to API with JSON response
    ///
    /// - Parameters:
    ///   - method: the method
    ///   - url: the URL
    ///   - parameters: the parameters
    ///   - headers: the headers
    ///   - encoding: the encoding
    /// - Returns: the observable
    public static func request(_ method: HTTPMethod,
             url: URLConvertible,
             parameters: [String: Any]? = nil,
             headers: [String: String] = [:],
             encoding: ParameterEncoding = JSONEncoding.default) -> Observable<JSON> {
        var headers = headers
        for (k,v) in RestServiceApi.headers {
            headers[k] = v
        }
        return RxAlamofire
            .request(method, url, parameters: parameters, encoding: encoding, headers: headers)
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .default))
            .validate(contentType: ["application/json"])
            .responseJSON()
            .flatMap { (result: DataResponse<Any>) -> Observable<Any> in
                #if DEBUG
                if let request = result.request {
                    logRequest(request)
                    if let response = result.response {
                        logResponse(result.value as AnyObject, forRequest: request, response: response)
                    }
                }
                #endif
                if let code = result.response?.statusCode, UNAUTHORIZED_CODES.contains(code) {
                    if let callback401 = callback401 { DispatchQueue.main.async { callback401() } }
                    return Observable.error(result.error ?? NSLocalizedString("Unauthorized", comment: "Unauthorized"))
                }
                else if let data = result.value, result.response?.statusCode ?? 0 >= 400 {
                    let error: Error? = JSON(data)["message"].stringValue
                    checkResponseForUnauthorizedErrors(data: data)
                    return Observable.error(error as? String ?? NSLocalizedString("Unknown error", comment: "Unknown error"))
                }
                if let data = result.value {
                    return Observable.just(data)
                }
                return Observable.error(result.error ?? NSLocalizedString("Not Found", comment: "Not Found"))
            }
            .map({ (result: Any) -> JSON in
                return JSON(result)
            })
    }

    /// Request to API with empty response
    ///
    /// - Parameters:
    ///   - method: the method
    ///   - url: the URL
    ///   - parameters: the parameters
    ///   - headers: the headers
    ///   - encoding: the encoding
    /// - Returns: the observable
    public static func requestVoid(_ method: HTTPMethod = .delete,
                                   url: URLConvertible,
                                   parameters: [String: Any]? = nil,
                                   headers: [String: String] = [:],
                                   encoding: ParameterEncoding = JSONEncoding.default) -> Observable<Void> {
        var headers = headers
        for (k,v) in RestServiceApi.headers {
            headers[k] = v
        }
        var sendRequest: URLRequest!
        return RxAlamofire
            .request(method, url, parameters: parameters, encoding: encoding, headers: headers)
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .default))
            .validate(contentType: ["application/json"])
            .do(onNext: { (request) in
                #if DEBUG
                if let request = request.request {
                    sendRequest = request
                    logRequest(request)
                }
                #endif
            })
            .responseData()
            .flatMap { (response: HTTPURLResponse, data) -> Observable<Void> in
                #if DEBUG
                logResponse(data as AnyObject, forRequest: sendRequest, response: response)
                #endif
                if UNAUTHORIZED_CODES.contains(response.statusCode) {
                    if let callback401 = callback401 { DispatchQueue.main.async { callback401() } }
                    return Observable.error(NSLocalizedString("Unauthorized", comment: "Unauthorized"))
                }
                else if response.statusCode >= 400 {
                    let error: Error? = JSON(data)["message"].stringValue
                    checkResponseForUnauthorizedErrors(data: data)
                    return Observable.error(error as? String ?? NSLocalizedString("Unknown error", comment: "Unknown error"))
                }
                return Observable.just(())
        }
    }

    /// Request to API with array body.
    /// Used for PUT and POST requests.
    /// "Content-Type" will be set to "application/json"
    ///
    /// - Parameters:
    ///   - method: the method
    ///   - url: the URL
    ///   - parameters: the parameters
    ///   - headers: the headers
    /// - Returns: the observable
    public static func request(_ method: HTTPMethod,
                               url: URLConvertible,
                               body: [[String: Any]],
                               headers: [String: String] = [:]) -> Observable<JSON> {
        var headers = headers
        for (k,v) in RestServiceApi.headers {
            headers[k] = v
        }
        headers["Content-Type"] = "application/json"
        do {
            let data = try JSON(body).data()
            var request = try URLRequest(url: url, method: method, headers: headers)
            request.httpBody = data
            return RxAlamofire.request(request)
                .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .default))
                .validate(contentType: ["application/json"])
                .responseJSON()
                .flatMap { (result: DataResponse<Any>) -> Observable<Any> in
                    #if DEBUG
                    if let request = result.request {
                        logRequest(request)
                        if let response = result.response {
                            logResponse(result.value as AnyObject, forRequest: request, response: response)
                        }
                    }
                    #endif
                    if let code = result.response?.statusCode, UNAUTHORIZED_CODES.contains(code) {
                        if let callback401 = callback401 { DispatchQueue.main.async { callback401() } }
                        return Observable.error(result.error ?? NSLocalizedString("Unauthorized", comment: "Unauthorized"))
                    }
                    else if let data = result.value, result.response?.statusCode ?? 0 >= 400 {
                        let error: Error? = JSON(data)["message"].stringValue
                        checkResponseForUnauthorizedErrors(data: data)
                        return Observable.error(error as? String ?? NSLocalizedString("Unknown error", comment: "Unknown error"))
                    }
                    if let data = result.value {
                        return Observable.just(data)
                    }
                    return Observable.error(result.error ?? NSLocalizedString("Not Found", comment: "Not Found"))
            }
            .map({ (result: Any) -> JSON in
                return JSON(result)
            })
        }
        catch let error {
            return Observable.error(error)
        }
    }
    
    /// Request to API with FORM encoding and Data response
    ///
    /// - Parameters:
    ///   - method: the method
    ///   - url: the URL
    ///   - parameters: the parameters
    ///   - headers: the headers
    ///   - encoding: the encoding
    /// - Returns: the observable
    public static func requestData(_ method: HTTPMethod,
                                     url: URLConvertible,
                                     parameters: [String: Any]? = nil,
                                     headers: [String: String] = [:],
                                     encoding: ParameterEncoding = URLEncoding.default) -> Observable<Data> {
        var allHeaders = headers
        for (k,v) in headers {
            allHeaders[k] = v
        }
        var sendRequest: URLRequest!
        return RxAlamofire
            .request(method, url, parameters: parameters, encoding: encoding, headers: allHeaders)
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .default))
            .do(onNext: { (request) in
                if let request = request.request {
                    sendRequest = request
                    logRequest(request)
                }
            })
            .responseData()
            .flatMap { (result: HTTPURLResponse, data: Data) -> Observable<Data> in
                logResponse(data as AnyObject, forRequest: sendRequest, response: result)
                if UNAUTHORIZED_CODES.contains(result.statusCode) {
                    if let callback401 = callback401 { callback401() }
                    return Observable.error(NSLocalizedString("Unauthorized", comment: "Unauthorized"))
                }
                else if result.statusCode >= 400 {
                    let error = String(data: data, encoding: .utf8)
                    checkResponseForUnauthorizedErrors(data: data)
                    return Observable.error(error ?? NSLocalizedString("Unknown error", comment: "Unknown error"))
                }
                return Observable.just(data)
        }
    }
    
    // Check response for `UNAUTHORIZED` errors and call `callback401` if needed.
    public static func checkResponseForUnauthorizedErrors(data: Any) {
        if let (key, values) = UNAUTHORIZED_JSON_ERROR,
            let json = (data is Data ? (try? JSON(data: data as! Data)) : JSON(data)),
            let value = json[key].string {
            for v in values {
                if value == v {
                    if let callback401 = callback401 { callback401() }
                    break;
                }
            }
        }
    }

    /// Prints given request URL, Method and body
    ///
    /// - Parameters:
    ///   - request: URLRequest to log
    public static func logRequest(_ request: URLRequest) {
        // Log request URL
        var info = "url"
        if let m = request.httpMethod { info = m }
        let hash = "[H\(request.hashValue)]"
        var logMessage = "\(Date())"
        logMessage += "[REQUEST]\(hash)\n curl -X \(info) \"\(request.url!.absoluteString)\""

        // log body if set
        if let body = request.httpBody, let bodyAsString = String(data: body, encoding: .utf8) {
            logMessage += "\\\n\t -d '\(bodyAsString.replace("\n", withString: "\\\n"))'"
        }
        for (k,v) in request.allHTTPHeaderFields ?? [:] {
            logMessage += "\\\n\t -H \"\(k): \(v.replace("\"", withString: "\\\""))\""
        }
        print(logMessage)
    }

    /// Prints given response object.
    ///
    /// - Parameters:
    ///   - object: related object
    ///   - request: the request
    ///   - response: the response
    public static func logResponse(_ object: AnyObject?, forRequest request: URLRequest, response: URLResponse?) {
        let hash = "[H\(request.hashValue)]"
        var info: String = "\(Date())<----------------------------------------------------------[RESPONSE]\(hash):\n"
        if let response = response as? HTTPURLResponse {
            if LOG_RESPONSE_HEADERS {
                info += "HTTP \(response.statusCode); headers:\n"
                for (k,v) in response.allHeaderFields {
                    info += "\t\(k): \(v)\n"
                }
            }
            else {
                info += "HTTP \(response.statusCode);\n"
            }
        }
        else {
            info += "<no response> "
        }
        if let o: AnyObject = object {
            if let data = o as? Data {
                let json = try? JSON(data: data, options: JSONSerialization.ReadingOptions.allowFragments)
                if let json = json {
                    info += "\(json)"
                }
                else {
                    info += "Data[length=\(data.count)]"
                    if data.count < 10000 {
                        info += "\n" + (String(data: data, encoding: .utf8) ?? "")
                    }
                }
            }
            else {
                info += String(describing: o)
            }
        }
        else {
            info += "<null response>"
        }
        print(info)
    }
}

// MARK: - Helpful methods in ObservableType
extension ObservableType {
    
    /// Add delay to the sequence
    ///
    /// - Parameter time: the delay time
    /// - Returns: sequence
    public func withDelay(_ time: TimeInterval) -> Observable<Element> {
        let this = self
        return Observable.create({ (obs) -> Disposable in
            SwiftEx83.delay(time) {
                _ = this.subscribe(onNext: {
                    obs.on(.next($0))
                    obs.on(.completed)
                }, onError: {
                    obs.on(.error($0))
                }, onCompleted: {
                    obs.on(.completed)
                }, onDisposed: {})
            }
            return Disposables.create()
        })
    }
}

extension RestServiceApi {
    
    /// POST request
    ///
    /// - Parameter url: URL
    /// - Returns: the observable
    public static func postVoid(url: URLConvertible, parameters: [String: Any]) -> Observable<Void> {
        return requestString(.post, url: url, parameters: parameters)
            .void()
    }
    
    /// Upload image
    /// Modified version of https://github.com/RxSwiftCommunity/RxAlamofire/issues/65
    ///
    /// - Parameters:
    ///   - image: the image data
    ///   - url: URL
    ///   - parameters: the parameters
    ///   - headers: the headers
    /// - Returns: sequence
    public static func upload(image imageData: Data, to url: URLConvertible, parameters: [String: String]? = nil, headers: [String: String] = [:]) ->  Observable<JSON> {
        var headers = headers
        for (k,v) in RestServiceApi.headers {
            headers[k] = v
        }
        return Observable<JSON>.create({observer in
            Alamofire.upload(multipartFormData: { multipartFormData in
                                multipartFormData.append(imageData, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
                                
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
    
    /// Request to API with URLEncoding encoding
    ///
    /// - Parameters:
    ///   - method: the method
    ///   - url: the URL
    ///   - parameters: the parameters
    ///   - headers: the headers
    ///   - encoding: the encoding
    /// - Returns: the observable
    public static func requestString(_ method: HTTPMethod,
                                     url: URLConvertible,
                                     parameters: [String: Any]? = nil,
                                     headers: [String: String] = [:],
                                     encoding: ParameterEncoding = URLEncoding.default) -> Observable<Data> {
        var headers = headers
        for (k,v) in RestServiceApi.headers {
            headers[k] = v
        }
        var sendRequest: URLRequest!
        return RxAlamofire
            .request(method, url, parameters: parameters, encoding: encoding, headers: headers)
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .default))
            .do(onNext: { (request) in
                if let request = request.request {
                    sendRequest = request
                    logRequest(request)
                }
            })
            .responseData()
            .flatMap { (response: HTTPURLResponse, data: Data) -> Observable<Data> in
                logResponse(data as AnyObject, forRequest: sendRequest, response: response)
                
                if UNAUTHORIZED_CODES.contains(response.statusCode) {
                    if let callback401 = callback401 { DispatchQueue.main.async { callback401() } }
                    return Observable.error(NSLocalizedString("Unauthorized", comment: "Unauthorized"))
                }
                else if response.statusCode >= 400 {
                    let error: Error? = JSON(data)["message"].stringValue
                    checkResponseForUnauthorizedErrors(data: data)
                    return Observable.error(error as? String ?? NSLocalizedString("Unknown error", comment: "Unknown error"))
                }
                return Observable.just(data)
            }
    }
}
