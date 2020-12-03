//
//  FileUtil.swift
//  SwiftEx
//
//  Created by Alexander Volkov on 12/8/15
//  Created by Alexander Volkov on 29/30/19
//  Copyright (c) 2015-2019 Alexander Volkov. All rights reserved.
//

import UIKit
import SwiftyJSON

// Subdirectory name for saved files
let CONTENT_DIR = "content"

/**
 * Utility for accessing local files (save/load)
 *
 * - author: Alexander Volkov
 * - version: 1.0
 */
open class FileUtil {
    
    /// Saves image to a file
    ///
    /// - Parameters:
    ///   - fileName: the fileName
    ///   - image: the image
    /// - Returns: URL
    public class func saveImage(fileName: String, image: UIImage) -> URL? {
        if let data = image.toData() {
            return save(fileName: fileName, data: data)
        }
        return nil
    }
    
    /// Saves content file with given name and data
    ///
    /// - Parameters:
    ///   - fileName: the file name
    ///   - data: the data
    /// - Returns: the URL of the file
    public class func save(fileName: String, data: Data) -> URL? {
        if saveDataToDocumentsDirectory(data, path: fileName, subdirectory: CONTENT_DIR) {
            return getLocalFileURL(fileName)
        }
        return nil
    }
    
    /// Remove given file
    ///
    /// - Parameter fileName: the file name
    public class func removeFile(fileName: String) {
        let path = fileName
        let subdirectory = CONTENT_DIR
        
        // Create generic beginning to file save path
        var savePath = self.applicationDocumentsDirectory().path+"/"
        
        // Subdirectory
        savePath += subdirectory
        savePath += "/"
        
        // Add requested save path
        savePath += path
        
        // Remove file
        do {
            try FileManager.default.removeItem(atPath: savePath)
        } catch let error {
            print(error)
        }
    }
    
    /// Saves data on the given path in subdirectory in Documents
    ///
    /// - Parameters:
    ///   - fileData: the data
    ///   - path: the main path
    ///   - subdirectory: the subdirectory name
    /// - Returns: true - if successfully saved, false - else
    public class func saveDataToDocumentsDirectory(_ fileData: Data, path: String, subdirectory: String?) -> Bool {
        
        // Create generic beginning to file save path
        var savePath = self.applicationDocumentsDirectory().path+"/"
        
        // Subdirectory
        if let dir = subdirectory {
            savePath += dir
            self.create(subDirectory: savePath)
            savePath += "/"
        }
        
        // Add requested save path
        savePath += path
        
        // Save the file and see if it was successful
        let ok: Bool = FileManager.default.createFile(atPath: savePath, contents: fileData, attributes:nil)
        
        // Return status of file save
        return ok
    }
    
    /// Returns url to local file by fileName
    ///
    /// - Parameter fileName: the file name
    /// - Returns: the URL
    public class func getLocalFileURL(_ fileName: String) -> URL {
        return URL(fileURLWithPath: "\(self.applicationDocumentsDirectory().path)/\(CONTENT_DIR)/\(fileName)")
    }
    
    /// Returns url to Documents directory of the current app
    ///
    /// - Returns: the URL
    public class func applicationDocumentsDirectory() -> URL {
        
        var documentsDirectory: String?
        let paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as [AnyObject];
        if paths.count > 0 {
            if let pathString = paths[0] as? NSString {
                documentsDirectory = pathString as String
            }
        }
        return URL(string: documentsDirectory!)!
    }
    
    /**
     Returns url to Documents directory of the current app as a string
     
     - returns: the URL
     */
    public class func applicationDocumentsDirectory() -> String? {
        let paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                     FileManager.SearchPathDomainMask.userDomainMask, true) as [AnyObject]
        if paths.count > 0 {
            if let pathString = paths[0] as? NSString {
                return pathString as String
            }
        }
        return nil
    }
    
    /// Creates directory is not exists
    ///
    /// - Parameter subdirectoryPath: the subdirectoty name
    /// - Returns: true - if created successfully or exists, false - else
    @discardableResult
    public class func create(subDirectory subdirectoryPath: String) -> Bool {
        var isDir: ObjCBool = false;
        let exists = FileManager.default.fileExists(atPath: subdirectoryPath as String, isDirectory:&isDir)
        if exists {
            // a file of the same name exists, we don't care about this so won't do anything
            if isDir.boolValue {
                // subdirectory already exists, don't create it again
                return true
            }
        }
        do {
            try FileManager.default.createDirectory(atPath: subdirectoryPath,
                                                    withIntermediateDirectories: true, attributes: nil)
            return true
        }
        catch {
            print("ERROR: \(error)")
        }
        return false
    }
    
    /// Get data from resource file
    ///
    /// - Parameters:
    ///   - name: the file name
    ///   - ext: the file extension
    /// - Returns: the file data
    public static func resource(named name: String, withExtension ext: String) -> Data? {
        guard let resourceUrl = Bundle.main.url(forResource: name, withExtension: ext) else {
            fatalError("Could not find resource \(name)")
        }
        
        // create data from the resource content
        var data: Data
        do {
            data = try Data(contentsOf: resourceUrl, options: Data.ReadingOptions.dataReadingMapped) as Data
        } catch let error {
            print("ERROR: \(error)")
            return nil
        }
        // reading the json
        return data
    }
}

/**
 * Extension adds methods for reading and writing into a local file
 *
 * - author: Alexander Volkov
 * - version: 1.0
 */
extension JSON {
    
    /// Save JSON object into given file
    ///
    /// - Parameter fileName: the file name
    /// - Returns: the URL of the saved file
    public func saveFile(fileName: String) -> URL? {
        do {
            let data = try self.rawData()
            return FileUtil.save(fileName: fileName, data: data)
        } catch {
            return nil
        }
    }
    
    /// Get JSON object from given file
    ///
    /// - Parameter fileName: he file name
    /// - Returns: JSONObject
    public static func contentOfFile(_ fileName: String) -> JSON? {
        let url = FileUtil.getLocalFileURL(fileName)
        if FileManager.default.fileExists(atPath: url.path) {
            if let data = try? Data(contentsOf: url) {
                return try? JSON(data: data)
            }
        }
        return nil
    }
}
