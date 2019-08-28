//
//  InstallerViewController.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 27/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Foundation
import Cocoa

//class InstallerViewController: NSViewController {
//    @IBOutlet var installerTextView: NSTextView!
//    let installationType: InstallationType
//    let sourcePath: String
//    let extensionName: String
//    
//    init(installationType: InstallationType, sourcePath: String, extensionName: String) {
//        super.init()
//        self.installationType = installationType
//        self.sourcePath = sourcePath
//        self.extensionName = extensionName
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//    
//    func runInstaller() {
//        if installationType == .githubSource {
//            // TODO: Add more steps to install the extension on your own.
//            let folderName = self.extensionName.replacingOccurrences(of: " ", with: "")
//            let input = "git clone \(self.sourcePath) '\(Constants.tempFolderPath)\(folderName)'"
//            let output = input.runAsCommand()
//            self.installerTextView.string = output
//            NSWorkspace.shared.openFile("\(Constants.tempFolderPath)\(folderName)")
//        }
//    }
//}
