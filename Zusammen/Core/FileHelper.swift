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
    static func removeTemporaryFolder() {
        do {
            try FileManager.default.removeItem(atPath: Constants.tempFolderPath)
            print(" * Cleared the tmp folder for Zusammen.")
        } catch {
             print()
            print(" * Error: Unable to file/clear the tmp folder for Zusammen - \(error.localizedDescription).")
        }
    }
    
    /// Remove the folder at the provided path.
    ///
    /// - parameter folderPath: Path for the folder that needs to be remove.
    static func removeFolder(atPath: String) {
        do {
            try FileManager.default.removeItem(atPath: atPath)
            print(" * Cleared the tmp folder at location \(atPath).")
        } catch {
            print(" * Error: Unable to file/clear the tmp folder at  \(atPath) - \(error.localizedDescription).")
        }
    }
    
    /// Download file from the given URL.
    ///
    /// - parameter fileURL: URL of the file from the server.
    /// - parameter destination: destination folder where to place the file after downloading.
    /// - parameter filename: name of the file.
    /// - parameter completion: Completion handler.
    ///
    /// - returns: Response from the stdout after running the command.
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
