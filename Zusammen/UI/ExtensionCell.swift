//
//  ExtensionCell.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 09/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Cocoa
import Foundation
import QuartzCore

/// Tableview cell to show information about the sensor.
class ExtensionCell: NSTableCellView {
    static var identifier = NSUserInterfaceItemIdentifier(rawValue: "extensionCellIdentifier")
    static var height = 75
    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var taglineLabel: NSTextField!
    @IBOutlet var badgeLabel: BadgeLabel!
    @IBOutlet var thumbnailImageView: NSImageView!
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
        taglineLabel.textColor = .gray
        titleLabel.textColor = .black
    }

    func updateUI() {
        guard let extensionValue = self.currentExtension else {
            return
        }
        titleLabel.textColor = .textColor
        taglineLabel.textColor = .textColor

        taglineLabel.alphaValue = 0.7
        titleLabel.stringValue = extensionValue.name
        taglineLabel.stringValue = extensionValue.descriptionValue
        badgeLabel.updateValue(string: extensionValue.swiftVersion)
    }
}
