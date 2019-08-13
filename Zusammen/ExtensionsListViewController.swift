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

    @IBOutlet weak var extensionContentView: ExtensionContentView!

    var extensionsList: ExtensionList?
    public var currentExtension: Extension? {
        didSet { updateCurrentExtensionUI(selectedExtennsion: currentExtension) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }

    @IBAction func openExtensionsSystemPreferencePanel(_: Any) {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Extensions.prefPane"))
    }

    func loadData() {
        extensionsList = try! ExtensionListLoader.allExtensions()
        currentExtension = extensionsList?.extensions.first
    }
    
    func updateCurrentExtensionUI(selectedExtennsion: Extension?) {
        self.extensionContentView.currentExtension = selectedExtennsion
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

