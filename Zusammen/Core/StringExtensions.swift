//
//  StringExtensions.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 27/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Foundation

extension String {
    
    /// Runs the string as a command on the shell.
    ///
    /// - returns: Response from the stdout after running the command.
    func runAsCommand() -> String {
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", String(format:"%@", self)]
        task.standardOutput = pipe
        let file = pipe.fileHandleForReading
        task.launch()
        if let result = NSString(data: file.readDataToEndOfFile(), encoding: String.Encoding.utf8.rawValue) {
            return result as String
        }
        else {
            let errorString = " * Error running command - Unable to initialize string from file data."
            print(errorString)
            return errorString
        }
    }
}
