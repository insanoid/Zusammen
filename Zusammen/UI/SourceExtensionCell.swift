//
//  SourceExtensionCell.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 09/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Cocoa
import Foundation
import QuartzCore

/// NSTableCellView to show information about the `SourceExtension`.
class SourceExtensionCell: NSTableCellView {
    static var identifier = NSUserInterfaceItemIdentifier(rawValue: "extensionCellIdentifier")
    static var height = 75

    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var taglineLabel: NSTextField!
    @IBOutlet var badgeLabel: BadgeLabel!
    @IBOutlet var thumbnailImageView: NSImageView!

    /// Current `SourceExtension` that need to be shown in the cell.
    private var currentSourceExtension: SourceExtension?

    class func view(tableView: NSTableView,
                    owner: AnyObject?,
                    subject: AnyObject?) -> NSView? {
        if let view = tableView.makeView(withIdentifier: SourceExtensionCell.identifier, owner: owner) as? SourceExtensionCell {
            if let Extension = subject as? SourceExtension {
                view.setCurrentExtension(currentExtension: Extension)
            }
            return view
        }
        return nil
    }

    private func setCurrentExtension(currentExtension: SourceExtension) {
        currentSourceExtension = currentExtension
        updateUI()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        taglineLabel.textColor = .gray
        titleLabel.textColor = .black
    }

    func updateUI() {
        guard let extensionValue = self.currentSourceExtension else {
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
