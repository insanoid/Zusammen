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

/// The right-side view for the app to showcase information about the `SourceExtension`.
class SourceExtensionContentView: NSView {
    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var taglineLabel: NSTextField!
    @IBOutlet var tagsLabel: NSTextField!
    @IBOutlet var webView: WKWebView!
    @IBOutlet var installButton: NSButton!
    @IBOutlet var githubButton: NSButton!
    @IBOutlet var swiftVersionLabel: BadgeLabel!

    // This loading webview shows temporarily loading indicator while switching between two plugins.
    // Since we are removing content using JavaScript it takes time to render.
    // TODO: Replace the loading view with an actual `NSView`.
    var loadingWebView: WKWebView?

    /// Current extension that needs to be displayed in the view.
    var currentExtension: SourceExtension? {
        didSet { updateCurrentExtensionUI(selectedExtennsion: currentExtension) }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        resetView()
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

    /// Update the view with the new selected `SourceExtension`'s details.
    ///
    /// - Parameter selectedExtennsion: `SourceExtension` that needs to be loaded into the view.
    func updateCurrentExtensionUI(selectedExtennsion: SourceExtension?) {
        // If there was no source extension selected, then hide the whole view.
        guard let currentExtension = selectedExtennsion else {
            alphaValue = 0.0
            resetView()
            return
        }

        alphaValue = 1.0
        hideLoadingWebView()

        titleLabel.stringValue = currentExtension.name
        taglineLabel.stringValue = currentExtension.descriptionValue
        swiftVersionLabel.updateValue(string: currentExtension.swiftVersion)

        // Toggle the button if it cannot be installed or there is no source code.
        installButton.isEnabled = currentExtension.downloadUrl != nil
        githubButton.isEnabled = currentExtension.installationType != .unknown
        installButton.title = currentExtension.installationType.installationText()
        tagsLabel.stringValue = currentExtension.combineTags()

        if let contentPath = currentExtension.readmeUrl, let contentURL = URL(string: contentPath) {
            openContentPage(path: contentURL)
        } else {
            // TODO: load a placeholder version of the page.
        }
    }

    // Install the currently selected addon on to your machine.
    ///
    /// - Parameter _: Button
    @IBAction func installAction(_: Any) {
        guard let currentExtensionValue = currentExtension else {
            return
        }

        installButton.isEnabled = false
        currentExtensionValue.install { _ in
            DispatchQueue.main.async {
                self.installButton.isEnabled = true
            }
        }
    }

    /// Open source file for the project (A URL on the source control repo).
    ///
    /// - Parameter _: Button
    @IBAction func openSourceAction(_: Any) {
        guard let sourceUrl = currentExtension?.sourceUrl, let url = URL(string: sourceUrl) else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    /// Open the system preference panel with the extensions section option.
    ///
    /// - Parameter _: Button.
    @IBAction func openExtensionsSystemPreferencePanel(_: Any) {
        NSWorkspace.shared.open(URL(fileURLWithPath: Constants.extensionPreferencesURL))
    }
}

/// All loading view methods in a single extension.
extension SourceExtensionContentView {
    /// Create a new web view and show the loading placeholder page.
    func showLoadingWebView() {
        loadingWebView = WKWebView(frame: NSRect(x: 0, y: 0, width: frame.width, height: frame.height))
        loadingWebView?.uiDelegate = self
        loadingWebView?.navigationDelegate = self
        loadingWebView!.heightAnchor.constraint(equalTo: webView.heightAnchor, multiplier: 1.0)
        loadingWebView!.topAnchor.constraint(equalTo: webView.topAnchor)
        addSubview(loadingWebView!)
    }

    /// Hide the loading web view that was created to cover the whole view.
    func hideLoadingWebView() {
        if loadingWebView != nil {
            loadingWebView?.removeFromSuperview()
            loadingWebView = nil
        }
    }

    /// Load the default webpage in the webview.
    func loadDefaultWebpage(currentWebView: WKWebView) {
        let url = Bundle.main.url(forResource: "placeholder", withExtension: "html")!
        currentWebView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        currentWebView.load(request)
    }
}

/// Webview related functions grouped together in a single extension.
extension SourceExtensionContentView: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        defer {
            if webView == self.webView {
                hideLoadingWebView()
            }
        }

        guard let url = webView.url, url.host == "github.com" else {
            return
        }
        // This script removes the header from github and just keeps the readme for the user to read.
        let script = try! FileHelper.loadFileFromBundle(filename: "GithubHeaderRemovalScript", fileExtension: "js")
        webView.evaluateJavaScript(script)
    }

    func webView(_ webView: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        if webView == self.webView {
            hideLoadingWebView()
        }
    }

    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        // Any new page that is triggered by clicking links inside the webview should be opened in the browser.
        guard navigationAction.navigationType == .other || navigationAction.navigationType == .reload else {
            decisionHandler(.cancel)
            let url = URL(string: navigationAction.request.url!.absoluteString)!
            NSWorkspace.shared.open(url)
            return
        }
        decisionHandler(.allow)
    }

    /// Open the content at the provided the URL in the default web view.
    ///
    /// - Parameter path: Path that needs to be loaded in the web view.
    func openContentPage(path: URL) {
        showLoadingWebView()
        loadDefaultWebpage(currentWebView: loadingWebView!)
        webView.load(URLRequest(url: path))
    }
}
