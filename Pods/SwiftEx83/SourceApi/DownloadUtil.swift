//
//  DownloadUtil.swift
//  SwiftEx
//
//  Created by Volkov Alexander on 05.11.2019.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(SwiftEx)
import SwiftEx // required for swift package
#endif
// Download utility
/*
let g = DispatchGroup()
g.enter()
let url = URL(string: "http://<url to the file>")!
DownloadUtil().download(url: url) { (location) in
    print("Downloaded: \(location)")
    
    do {
        let input = try InputStreamReader(url: location)
        input.kLimit = 10 // limit reading to first 10 lines
        try input
            .log(every: 10000)
            .process { (str, k) in
                print(str)
        }
    }
    catch let error {
        print("ERROR: \(error)")
    }
    g.leave()
}
g.wait()
print("Done")
*/
open class DownloadUtil: NSObject, URLSessionDownloadDelegate {
    
    public let api: RESTApi!
    
    private var downloadCallback: ((URL)->())?
    private var lastLogged: Int = 0
    
    public lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        
        return URLSession(configuration: configuration,
                          delegate: self,
                          delegateQueue: nil)
    }()
    
    public override init() { self.api = nil; super.init() }
    
    public init(baseUrl: String) {
        api = RESTApi(baseUrl: baseUrl)
    }
    
    public func process(endpoint: String, callback: @escaping (String)->()) {
        api.getData(endpoint, parameters: [:], callback: { (string) in
            print("|string|=\(string.count)")
            callback(string)
        }, failure: { error in
            print("ERROR: \(error)")
        })
    }
    
    public func download(url: URL, callback: @escaping (URL)->()) {
        let task = downloadsSession.downloadTask(with: url)
        lastLogged = 0
        task.resume()
        self.downloadCallback = callback
    }
    
    // MARK: - URLSessionDelegate
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        downloadCallback?(location)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesWritten > lastLogged {
            lastLogged += 1000000
            print("Downloaded: \(totalBytesWritten)/\(totalBytesExpectedToWrite)")
        }
    }
}

extension RESTApi {
    
    public func getData(_ endpoint: String, parameters: [String: Any], callback: @escaping (String) -> (), failure: @escaping FailureCallback) {
        let request = self.createRequest(method: .GET, endpoint: endpoint, contentType: ContentType.OTHER, parameters: parameters, failure: wrapFailureCallback(failure))
        sendRequestAndParseString(request: request, success: callback, failure: wrapFailureCallback(failure))
    }
    
    public func sendRequestAndParseString(request: URLRequest, log: Bool? = nil, success: @escaping (String)->(), failure: @escaping RestFailureCallback) {
        sendRequest(request: request, log: log, success: { (data, code) in
            
            // read json from data
            var string: String = ""
            if data.count > 0 {
                string = String(data: data, encoding: .utf8) ?? ""
            }
            
            DispatchQueue.main.async {
                if code >= 400 { // check common errors in response
                    // Check if the endpoint allows such HTTP code
//                    let endpoint = (request.url?.absoluteString ?? "").replace(self.baseUrl, withString: "")
//                    if self.extraAllowedHttpCodes.contains(code) && self.endpointsForExtraAllowedHttpCodes.contains(endpoint) {
//                        print("WARNING: HTTP CODE \(code)")
//                        success(string)
//                    }
//                    else
                    if code == 401 { // need to logout
                        failure("Unauthorized", nil)
                    }
                    else {
                        failure("Unknown error", nil)
                    }
                }
                else {
                    success(string)
                }
            }
        }, failure: failure)
    }
}
