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

class ExtensionContentView: NSView, WKUIDelegate, WKNavigationDelegate {
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
            resetView()
            return
        }
        hideLoadingWebView()
        // Reseting view is always better than showing old content while new content loads.
        titleLabel.stringValue = currentExtension.name
        taglineLabel.stringValue = currentExtension.descriptionValue
        swiftVersionLabel.updateValue(string: currentExtension.swiftVersion)
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

    func openAppStore(identifier: String) {
        if let url = URL(string: "macappstore://apps.apple.com/app/id" + identifier) {
            NSWorkspace.shared.open(url)
        }
    }

    func showLoadingWebView() {
        loadingWebView = WKWebView(frame: webView.frame)
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
        openAppStore(identifier: currentExtension!.downloadUrl!)
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
