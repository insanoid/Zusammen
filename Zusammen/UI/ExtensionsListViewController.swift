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
    @IBOutlet var extensionContentView: SourceExtensionContentView!
    @IBOutlet var extensionListTableView: NSTableView!
    @IBOutlet var searchField: NSSearchField!
    @IBOutlet var versionSegmentControl: NSSegmentedControl!
    @IBOutlet var tagsComboBox: NSComboBox!
    
    var uniqueTags: [String]?

    var extensionsList: [SourceExtension]?
    public var currentExtension: SourceExtension? {
        didSet { updateCurrentExtensionUI(selectedExtennsion: currentExtension) }
    }

    func updateCurrentExtensionUI(selectedExtennsion: SourceExtension?) {
        extensionContentView.currentExtension = selectedExtennsion
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitialData()
        loadData()
    }
    
    func loadInitialData() {
        let allExtensions = try! SourceExtensionListLoader.getExtensions(nil)
        uniqueTags = SourceExtensionList.uniqueTags(inExtensions: allExtensions)
        tagsComboBox.addItems(withObjectValues: uniqueTags ?? [])
    }

    func loadData() {
        let selectedTag = self.tagsComboBox.stringValue == "All Tags" ? nil : self.tagsComboBox.stringValue
        extensionsList = try! SourceExtensionListLoader.getExtensions(searchField.stringValue,
                                                                      versionSegmentControl.selectedSegment == 1,
                                                                      selectedTag)

        if currentExtension == nil || extensionsList!.contains(where: { (extensionValue) -> Bool in
            currentExtension?.name == extensionValue.name
        }) == false {
            currentExtension = nil
        }
        extensionListTableView.reloadData()

        if currentExtension != nil {
            let index = extensionsList?.firstIndex(where: { (extensionVal) -> Bool in
                currentExtension!.name == extensionVal.name
            })
            extensionListTableView.selectRowIndexes(IndexSet(integer: index!), byExtendingSelection: false)
            extensionListTableView.scrollRowToVisible(index!)
        }
    }

    @IBAction func searchFieldAction(_: Any) {
        loadData()
    }

    @IBAction func filterButtonAction(_: Any) {
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
        return SourceExtensionCell.view(tableView: tableView,
                                        owner: self,
                                        subject: extensionsList?[row] as AnyObject?)
    }

    func tableView(_: NSTableView, heightOfRow _: Int) -> CGFloat {
        return CGFloat(SourceExtensionCell.height)
    }

    func tableView(_: NSTableView, shouldSelectRow row: Int) -> Bool {
        if row < extensionsList?.count ?? 0 {
            currentExtension = extensionsList?[row]
        }
        return true
    }
}
