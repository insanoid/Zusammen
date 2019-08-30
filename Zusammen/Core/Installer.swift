//
//  Installer.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 30/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Cocoa
import Foundation

/// Installation of various kind of source extension.
extension SourceExtension {
    func install(_ completion: @escaping (_ result: Bool) -> Void) {
        // If there is no download URL then we cannot do much about it.
        // This condition should never be triggered as the button would be disabled in case there is no URL.
        guard let downloadPath = self.downloadUrl, let downloadURL = URL(string: downloadPath) else {
            completion(false)
            return
        }

        // We need a name and path for the temp folder for the extenstion.
        // We need to clear out the invalid characters before we use the name as the folder name.
        var invalidCharacters = CharacterSet(charactersIn: ":/")
        invalidCharacters.formUnion(.newlines)
        invalidCharacters.formUnion(.illegalCharacters)
        invalidCharacters.formUnion(.controlCharacters)
        invalidCharacters.formUnion(.whitespacesAndNewlines)
        let folderName = name.components(separatedBy: invalidCharacters).joined(separator: "")
        let tempFolderPath = "\(Constants.tempFolderPath)\(folderName)"

        // Remove the folder if it already exists so that we do not have duplication realted problems.
        FileHelper.removeFolder(atPath: tempFolderPath)

        if installationType == .appleStore {
            // Open the app store page on the browser, since apps might not be in the country of the user.
            // We do not have a sure shot way to show it in the app store app.
            NSWorkspace.shared.open(downloadURL)
            completion(true)
        } else if installationType == .githubSource {
            // Currently we are just cloning the github repo and opening the folder in finder for the user.
            // Installation directly is tricky as we will need to know and have the build system
            let input = "git clone \(downloadPath) '\(tempFolderPath)'"
            _ = input.runAsCommand { result, message in
                print(message)
                NSWorkspace.shared.openFile(tempFolderPath)
                completion(result)
            }
        } else if installationType == .githubRelease {
            let fileName = downloadURL.lastPathComponent
            FileHelper.downloadFile(fileURL: downloadURL, destination: tempFolderPath, fileName: fileName) { successful, errorMessage in
                if successful {
                    let input = "unzip -o '\(tempFolderPath)/\(fileName)' -d ~/Applications/"
                    input.runAsCommand(completion: { _, message in
                        print(message)
                        let appName = fileName.components(separatedBy: ".").first!
                        NSWorkspace.shared.launchApplication(appName)
                        NSWorkspace.shared.openFile("~/Applications/")
                        DispatchQueue.main.async {
                            let alert: NSAlert = NSAlert()
                            alert.messageText = "The application has been installed, enable the extensions in the system preference."
                            alert.alertStyle = .informational
                            alert.addButton(withTitle: "Close")
                            alert.addButton(withTitle: "Extensions Preferences")
                            let alertResult = alert.runModal()
                            if alertResult == .alertSecondButtonReturn {
                                NSWorkspace.shared.open(URL(fileURLWithPath: Constants.extensionPreferencesURL))
                            }
                            completion(true)
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        let alert: NSAlert = NSAlert()
                        alert.messageText = errorMessage ?? "The installation was not successful. Please open the source code webpage and install manually."
                        alert.alertStyle = .warning
                        _ = alert.runModal()
                        completion(false)
                    }
                }
            }
        }
        // Should never be reached as `unknown` installation type should not allowed to be installed.
        completion(false)
    }
}
