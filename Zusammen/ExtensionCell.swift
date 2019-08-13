//
//  ExtensionCell.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 09/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Foundation
import Cocoa


/// Tableview cell to show information about the sensor.
class ExtensionCell: NSTableCellView {

    static var identifier = NSUserInterfaceItemIdentifier(rawValue: "extensionCellIdentifier")
    static var height = 75

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var taglineLabel: NSTextField!
    @IBOutlet weak var thumbnailImageView: NSImageView!
    
    private var currentExtension: Extension?
    
    class func view(tableView: NSTableView,
                    owner: AnyObject?,
                    subject: AnyObject?) -> NSView? {
        if let view = tableView.makeView(withIdentifier: ExtensionCell.identifier, owner: owner) as? ExtensionCell {
            if let Extension = subject as? Extension {
                view.setCurrentExtension(currentExtension: Extension)
            }
            return view
        }
        return nil
    }
    
    private func setCurrentExtension(currentExtension: Extension) {
        self.currentExtension = currentExtension
        updateUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        taglineLabel.textColor = NSColor.gray
        titleLabel.textColor = NSColor.black
    }
    
    func updateUI() {
        guard let extensionValue = self.currentExtension else {
            return
        }
        self.titleLabel.textColor = .textColor
        self.taglineLabel.textColor = .textColor
        self.taglineLabel.alphaValue = 0.7
        self.titleLabel.stringValue = extensionValue.name
        self.taglineLabel.stringValue = extensionValue.descriptionValue
    }
    
}
