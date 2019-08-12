//
//  ExtensionsListViewController.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 08/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Cocoa
import WebKit

class ExtensionsListViewController: NSViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet var webView: WKWebView!
    @IBOutlet var nameLabel: NSTextField!
    @IBOutlet var descriptionLabel: NSTextField!
    @IBOutlet var tagsLabel: NSTextField!
    @IBOutlet var installButton: NSButton!
    @IBOutlet var githubButton: NSButton!

    var extensionsList: ExtensionList?
    var currentExtension: Extension? {
        didSet { updateCurrentExtensionUI(selectedExtennsion: currentExtension) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        loadData()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    @IBAction func openExtensionsSystemPreferencePanel(_: Any) {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Extensions.prefPane"))
    }

    func loadData() {
        extensionsList = try! ExtensionListLoader.allExtensions()
        currentExtension = extensionsList?.extensions.first
    }
}

extension ExtensionsListViewController {

    func updateCurrentExtensionUI(selectedExtennsion: Extension?) {
        guard let currentExtension = selectedExtennsion else {
            self.installButton.isEnabled = false
            self.githubButton.isEnabled = false
            // TODO: load a default page on the webview.
            return
        }
       // nameLabel.stringValue = currentExtension.name
        if let contentPath = currentExtension.readmeUrl, let contentURL = URL(string: contentPath) {
            openContentPage(path: contentURL)
        }
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
}

// MARK: - TableView Delegates and Datasource Methods.
extension ExtensionsListViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let allExtensions = self.extensionsList {
            return allExtensions.extensions.count
        }
       return 0
    }
    
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        return ExtensionCell.view(tableView: tableView, owner: self, subject: extensionsList?.extensions[row] as AnyObject?)
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return CGFloat.init(ExtensionCell.height)
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if row < extensionsList?.extensions.count ?? 0 {
            let extensionSelected = extensionsList?.extensions[row]
            updateCurrentExtensionUI(selectedExtennsion: extensionSelected)
        }
        return true
    }
}

