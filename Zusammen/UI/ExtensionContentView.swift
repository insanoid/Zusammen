//
//  ExtensionContentView.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 13/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Cocoa
import Foundation
import WebKit
import Alamofire

class ExtensionContentView: NSView {
    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var taglineLabel: NSTextField!
    @IBOutlet var tagsLabel: NSTextField!
    @IBOutlet var webView: WKWebView!
    @IBOutlet var installButton: NSButton!
    @IBOutlet var githubButton: NSButton!
    @IBOutlet var swiftVersionLabel: BadgeLabel!

    // This loading webview shows temporarily loading indicator while switching between two plugins.
    // Since we are removing content using JavaScript it takes time to render.
    var loadingWebView: WKWebView?

    var currentExtension: Extension? {
        didSet { updateCurrentExtensionUI(selectedExtennsion: currentExtension) }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)

        if newWindow == nil {
            webView.uiDelegate = nil
            webView.navigationDelegate = nil
        } else {
            webView.uiDelegate = self
            webView.navigationDelegate = self
        }
    }

    // Reset the view to all blank values.
    func resetView() {
        installButton.isEnabled = false
        githubButton.isEnabled = false
        titleLabel.stringValue = ""
        taglineLabel.stringValue = ""
        loadDefaultWebpage(currentWebView: webView)
        hideLoadingWebView()
        swiftVersionLabel.updateValue(string: nil)
    }

    func updateCurrentExtensionUI(selectedExtennsion: Extension?) {
        guard let currentExtension = selectedExtennsion else {
            self.alphaValue = 0.0
            resetView()
            return
        }
         self.alphaValue = 1.0
        hideLoadingWebView()
        // Reseting view is always better than showing old content while new content loads.
        titleLabel.stringValue = currentExtension.name
        taglineLabel.stringValue = currentExtension.descriptionValue
        swiftVersionLabel.updateValue(string: currentExtension.swiftVersion)
        
        if currentExtension.installationType == .appleStore {
           installButton.title = "Install (Store)"
        } else if currentExtension.installationType == .githubSource {
            installButton.title = "Install (Xcode Project)"
        }else if currentExtension.installationType == .githubRelease {
            installButton.title = "Install (Download Ext.)"
        } else {
            installButton.title = "Install"
        }
        
        if let tags = currentExtension.tags {
            tagsLabel.stringValue = tags.map { (value) -> String in
                value.uppercased()
            }.joined(separator: " · ")
        } else {
            tagsLabel.stringValue = ""
        }

        if let contentPath = currentExtension.readmeUrl, let contentURL = URL(string: contentPath) {
            openContentPage(path: contentURL)
        }
    }

    func showLoadingWebView() {
        
        loadingWebView = WKWebView(frame: NSRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        loadingWebView?.uiDelegate = self
        loadingWebView?.navigationDelegate = self

        loadingWebView!.heightAnchor.constraint(equalTo: webView.heightAnchor, multiplier: 1.0)
        loadingWebView!.topAnchor.constraint(equalTo: webView.topAnchor)
        addSubview(loadingWebView!)
    }

    func hideLoadingWebView() {
        if loadingWebView != nil {
            loadingWebView?.removeFromSuperview()
            loadingWebView = nil
        }
    }

    func openContentPage(path: URL) {
        showLoadingWebView()
        loadDefaultWebpage(currentWebView: loadingWebView!)
        webView.load(URLRequest(url: path))
    }

    /// Load the default webpage in the webview.
    func loadDefaultWebpage(currentWebView: WKWebView) {
        let url = Bundle.main.url(forResource: "placeholder", withExtension: "html")!
        currentWebView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        currentWebView.load(request)
    }

    // Install the currently selected addon on to your machine.
    ///
    /// - Parameter _: Button
    @IBAction func installAction(_: Any) {
        
        // If there is no download URL then we cannot do much about it.
        guard let downloadPath = currentExtension?.downloadUrl,
              let downloadURL = URL(string: downloadPath) else {
            return
        }
        
        // Disable button to stop multiple download actions to be triggered at once.
        self.installButton.isEnabled = false
        
        // We need a name and path for the temp folder for the extenstion.
        let folderName = currentExtension!.name.replacingOccurrences(of: " ", with: "")
        let tempFolderPath = "\(Constants.tempFolderPath)\(folderName)"
        
        // Clear if this folder already exists so that we do not have duplicate item problem.
        FileHelper.removeFolder(atPath: tempFolderPath)
        
        if currentExtension?.installationType == .appleStore {
            // Open the app store page on the browser, since apps might not be in the country of the user.
            // We do not have a sure shot way to show it in the app store app.
            NSWorkspace.shared.open(downloadURL)
            self.installButton.isEnabled = true

        } else  if currentExtension?.installationType == .githubSource {
            // Currently we are just cloning the github repo and opening the folder in finder for the user.
            // Installation directly is tricky as we will need to know and have the build system
            let input = "git clone \(downloadPath) '\(tempFolderPath)'"
            let _ = input.runAsCommand()
            NSWorkspace.shared.openFile(tempFolderPath)
            self.installButton.isEnabled = true

        } else if currentExtension?.installationType == .githubRelease {

            let fileName = downloadURL.lastPathComponent
            FileHelper.downloadFile(fileURL: downloadURL, destination: tempFolderPath, fileName: fileName) { (successful, errorMessage) in
                if successful {
                    let input = "unzip -o '\(tempFolderPath)/\(fileName)' -d ~/Applications/"
                    let output = input.runAsCommand()
                    print(output)
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
                            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Extensions.prefPane"))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                    let alert: NSAlert = NSAlert()
                    alert.messageText = errorMessage ?? "The installation was not successful. Please open the source code webpage and install manually."
                    alert.alertStyle = .warning
                    let _ = alert.runModal()
                    }
                }
                DispatchQueue.main.async {
                    self.installButton.isEnabled = true
                }
            }
        }
       
        
    }
    /// Open source file for the project (A URL on the source control repo).
    ///
    /// - Parameter _: Button
    @IBAction func openSourceAction(_: Any) {
        let url = URL(string: currentExtension!.sourceUrl!)!
        NSWorkspace.shared.open(url)
    }

    /// Open the system preference panel with the extensions section option.
    ///
    /// - Parameter _: Button.
    @IBAction func openExtensionsSystemPreferencePanel(_: Any) {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Extensions.prefPane"))
    }
}

// Webview related functions grouped together in a single extension.
extension ExtensionContentView: WKUIDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        guard let url = webView.url, url.host == "github.com" else {
            return
        }
        // This script removes the header from github and just keeps the readme for the user to read.
        let script = """
        function removeItems() {
            var header = document.getElementsByClassName('position-relative js-header-wrapper')[0];
            var pageHead = document.getElementsByClassName('pagehead')[0];
            var signupPrompt = document.getElementsByClassName('signup-prompt-bg rounded-1')[0];
            var fileHeader = document.getElementsByClassName('d-flex flex-items-start flex-shrink-0 pb-3 flex-column flex-md-row')[0];
            var boxHeader1 = document.getElementsByClassName('Box Box--condensed d-flex flex-column flex-shrink-0')[0];
            var footer = document.getElementsByClassName('footer')[0];
            var boxHeader2 = document.getElementsByClassName('Box-header py-2 d-flex flex-column flex-shrink-0 flex-md-row flex-md-items-center')[0];

            header.parentNode.removeChild(header);
            pageHead.parentNode.removeChild(pageHead);
            signupPrompt.parentNode.removeChild(signupPrompt);
            fileHeader.parentNode.removeChild(fileHeader);
            boxHeader1.parentNode.removeChild(boxHeader1);
            footer.parentNode.removeChild(footer);
            boxHeader2.parentNode.removeChild(boxHeader2);
        }
        removeItems();
        """
        webView.evaluateJavaScript(script)
        if webView == self.webView {
            hideLoadingWebView()
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        guard navigationAction.navigationType == .other || navigationAction.navigationType == .reload  else {
            decisionHandler(.cancel)
            let url = URL(string: navigationAction.request.url!.absoluteString)!
            NSWorkspace.shared.open(url)
            return
        }
        decisionHandler(.allow)
    }
}
