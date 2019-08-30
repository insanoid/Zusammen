//
//  FileHelper.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 28/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Foundation

/// A structure to store all kinds of file system helper functions.
struct FileHelper {
    /// Remove temporary folder with all the previously downloaded repositories and extensions.
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
    /// - Parameters:
    ///   - fileURL: URL of the file from the server.
    ///   - destination: Destination folder where to place the file after downloading.
    ///   - fileName: Name of the file.
    ///   - completion: Completion handler the provides the result and reason for the result.
    static func downloadFile(fileURL: URL, destination: String, fileName: String, completion: @escaping (_ result: Bool, _ reason: String?) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: fileURL)

        let task = session.downloadTask(with: request) { tempLocalUrl, response, error in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Successfully downloaded the request.
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print(" * Successfully downloaded (\(fileURL)) Status code: \(statusCode)")
                }

                // We will need to create the directory if it does not exist.
                do {
                    try FileManager.default.createDirectory(at: URL(fileURLWithPath: destination), withIntermediateDirectories: true, attributes: nil)
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

    /// Read the file from the current bundle and return the string content inside it.
    ///
    /// - Parameters:
    ///   - filename: Name of the file.
    ///   - extension: Extension of the file.
    /// - Returns: String content in the file.
    /// - Throws: Throws the error when fetching file and reading the content as string.
    static func loadFileFromBundle(filename: String, fileExtension: String) throws -> String {
        guard let path = Bundle.main.path(forResource: filename, ofType: fileExtension) else {
            return ""
        }
        let content = try String(contentsOfFile: path)
        return content
    }
}
