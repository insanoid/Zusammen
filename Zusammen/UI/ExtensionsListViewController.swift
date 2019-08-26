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
    @IBOutlet var extensionContentView: ExtensionContentView!

    var extensionsList: ExtensionList?
    public var currentExtension: Extension? {
        didSet { updateCurrentExtensionUI(selectedExtennsion: currentExtension) }
    }

    func updateCurrentExtensionUI(selectedExtennsion: Extension?) {
        extensionContentView.currentExtension = selectedExtennsion
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitialData()
    }

    func loadInitialData() {
        extensionsList = try! ExtensionListLoader.allExtensions()
        currentExtension = extensionsList?.extensions.first
    }
}

// MARK: - TableView Delegates and Datasource Methods.

extension ExtensionsListViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        if let allExtensions = self.extensionsList {
            return allExtensions.extensions.count
        }
        return 0
    }

    func tableView(_ tableView: NSTableView,
                   viewFor _: NSTableColumn?,
                   row: Int) -> NSView? {
        return ExtensionCell.view(tableView: tableView,
                                  owner: self,
                                  subject: extensionsList?.extensions[row] as AnyObject?)
    }

    func tableView(_: NSTableView, heightOfRow _: Int) -> CGFloat {
        return CGFloat(ExtensionCell.height)
    }

    func tableView(_: NSTableView, shouldSelectRow row: Int) -> Bool {
        if row < extensionsList?.extensions.count ?? 0 {
            let extensionSelected = extensionsList?.extensions[row]
            updateCurrentExtensionUI(selectedExtennsion: extensionSelected)
        }
        return true
    }
}
