//
//  ExtensionContentView.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 13/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Foundation
import Cocoa
import WebKit

class ExtensionContentView: NSView, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var taglineLabel: NSTextField!
    @IBOutlet weak var tagsLabel: NSTextField!
    @IBOutlet var webView: WKWebView!   
    @IBOutlet var installButton: NSButton!
    @IBOutlet var githubButton: NSButton!

    var currentExtension: Extension? {
        didSet { updateCurrentExtensionUI(selectedExtennsion: currentExtension) }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func updateCurrentExtensionUI(selectedExtennsion: Extension?) {
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        guard let currentExtension = selectedExtennsion else {
            self.installButton.isEnabled = false
            self.githubButton.isEnabled = false
            // TODO: load a default page on the webview.
            return
        }
        self.titleLabel.stringValue = currentExtension.name
        self.taglineLabel.stringValue = currentExtension.descriptionValue
        if let tags = currentExtension.tags {
            self.tagsLabel.stringValue = tags.map({ (value) -> String in
                value.uppercased()
            }).joined(separator: " · ")
        } else {
            self.tagsLabel.stringValue = ""
        }
       
        if let contentPath = currentExtension.readmeUrl, let contentURL = URL(string: contentPath) {
            openContentPage(path: contentURL)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let script="""
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
    }

    
    func openAppStore(identifier: String) {
        if let url = URL(string: "macappstore://apps.apple.com/app/id" + identifier) {
            NSWorkspace.shared.open(url)
        }
    }
    
    func openContentPage(path: URL) {
        webView.load(URLRequest(url: path))
    }
    
    @IBAction func openGithubLinkAction(_: Any) {
        let url = URL(string: self.currentExtension!.readmeUrl!)!
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func openAppStoreLinkAction(_: Any) {
        openAppStore(identifier: self.currentExtension!.downloadUrl!)
    }
    
    @IBAction func openExtensionsSystemPreferencePanel(_: Any) {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Extensions.prefPane"))
    }

}
