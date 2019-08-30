//
//  StringExtensions.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 27/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Foundation

/// Extension to store all the possible generic string functions.
extension String {
    /// Runs the string as a command on the shell.
    ///
    /// - Parameter completion: A completion handler that provides the response and the stdout value.
    func runAsCommand(completion: @escaping (_ result: Bool, _ output: String) -> Void) {
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", String(format: "%@", self)]
        task.standardOutput = pipe
        let file = pipe.fileHandleForReading
        task.launch()

        if let result = String(data: file.readDataToEndOfFile(), encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
            completion(true, result)
        } else {
            let errorString = " * Error running command - Unable to initialize string from file data."
            print(errorString)
            completion(false, errorString)
        }
    }
}
