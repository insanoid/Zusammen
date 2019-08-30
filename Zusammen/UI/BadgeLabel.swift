//
//  BadgeLabel.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 27/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Cocoa
import Foundation

/// NSTextField which creates a badge with rounded corners and orange background.
class BadgeLabel: NSTextField {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        updateUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateUI()
    }

    func updateUI() {
        usesSingleLineMode = true
        wantsLayer = true
        layer?.cornerRadius = 3
        layer?.masksToBounds = true
        alignment = .center
        textColor = .white
        backgroundColor = .orange
    }

    /// Update the value of the label if the value is nil then hide the label.
    func updateValue(string: String?) {
        if let value = string {
            stringValue = "Swift \(value)"
            isHidden = false
        } else {
            isHidden = true
        }
    }
}
