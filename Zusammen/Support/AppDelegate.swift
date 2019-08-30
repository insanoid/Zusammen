//
//  AppDelegate.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 08/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        // First thing we do is clear all the temporary files created by the app previously.
        FileHelper.removeTemporaryFolder()
    }

    func applicationWillTerminate(_: Notification) {}
}
