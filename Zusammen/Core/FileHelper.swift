//
//  FileHelper.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 28/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Foundation

/// A structure to store all kind of file system helper functions.
struct FileHelper {
    
    /// Clear temporary folder with all the previously downloaded repositories and extensions.
    static func clearTemporaryFolder() {
        do {
            try FileManager.default.removeItem(atPath: Constants.tempFolderPath)
            print(" * Cleared the tmp folder for Zusammen.")
        } catch {
             print()
            print(" * Error: Unable to file/clear the tmp folder for Zusammen - \(error.localizedDescription).")
        }
    }
    
    /// Clear the folder at the given location.
    static func clearFolder(folderPath: String) {
        do {
            try FileManager.default.removeItem(atPath: folderPath)
            print(" * Cleared the tmp folder at location \(folderPath).")
        } catch {
            print(" * Error: Unable to file/clear the tmp folder at  \(folderPath) - \(error.localizedDescription).")
        }
    }
    
    
    static func downloadFile(fileURL: URL, destination: String, fileName: String, completion: @escaping (_ result: Bool, _ reason: String?)->()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url:fileURL)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Successfully downloaded the request.
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print(" * Successfully downloaded (\(fileURL)) Status code: \(statusCode)")
                }
                
                // We will need to create the directory if it does not exist.
                do {
                    try FileManager.default.createDirectory(at: URL.init(fileURLWithPath: destination), withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(" * Error creating folder at the new location, probably already exists.")
                }
                
                // Now move the temporary file to the folder in the zusammen temp folder.
                do {
                    let destinationFilePath = "\(destination)/\(fileName)"
                    try FileManager.default.copyItem(atPath: tempLocalUrl.path, toPath: destinationFilePath)
                    completion(true, nil)
                } catch {
                    print(" * Error creating file at the new location.")
                    completion(false, "Error creating file at the new location.")
                }
                
            } else {
                print(" * Error took place while downloading a file.")
                completion(false, "Error took place while downloading a file.")
            }
        }
        task.resume()
        
    }

    
}
