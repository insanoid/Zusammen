//
//  ExtensionsListViewController.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 08/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Cocoa
import WebKit

class ExtensionsListViewController: NSViewController, WKUIDelegate, WKNavigationDelegate, NSSearchFieldDelegate {
    @IBOutlet var extensionContentView: ExtensionContentView!
    @IBOutlet var extensionListTableView: NSTableView!
    @IBOutlet var searchField: NSSearchField!
    @IBOutlet var versionSegmentControl: NSSegmentedControl!

    var extensionsList: [Extension]?
    public var currentExtension: Extension? {
        didSet { updateCurrentExtensionUI(selectedExtennsion: currentExtension) }
    }

    func updateCurrentExtensionUI(selectedExtennsion: Extension?) {
        extensionContentView.currentExtension = selectedExtennsion
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }

    func loadData() {
        extensionsList = try! ExtensionListLoader.getExtensions(searchField.stringValue,
                                                                versionSegmentControl.selectedSegment == 1)
        
        if currentExtension == nil || extensionsList!.contains(where: { (extensionValue) -> Bool in
            return currentExtension?.name == extensionValue.name
        }) == false {
             currentExtension = nil
        }
        self.extensionListTableView.reloadData()
    }
    
    @IBAction func searchFieldAction(_ sender: Any) {
        loadData()
    }
    
    @IBAction func filterButtonAction(_ sender: Any) {
        loadData()
    }

    
}

// MARK: - TableView Delegates and Datasource Methods.

extension ExtensionsListViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        if let allExtensions = self.extensionsList {
            return allExtensions.count
        }
        return 0
    }

    func tableView(_ tableView: NSTableView,
                   viewFor _: NSTableColumn?,
                   row: Int) -> NSView? {
        return ExtensionCell.view(tableView: tableView,
                                  owner: self,
                                  subject: extensionsList?[row] as AnyObject?)
    }

    func tableView(_: NSTableView, heightOfRow _: Int) -> CGFloat {
        return CGFloat(ExtensionCell.height)
    }

    func tableView(_: NSTableView, shouldSelectRow row: Int) -> Bool {
        if row < extensionsList?.count ?? 0 {
            self.currentExtension = extensionsList?[row]
        }
        return true
    }
}
