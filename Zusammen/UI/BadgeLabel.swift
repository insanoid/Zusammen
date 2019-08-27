//
//  BadgeLabel.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 27/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Cocoa
import Foundation

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

    func updateValue(string: String?) {
        if let value = string {
            stringValue = value
            alphaValue = 0.7
        } else {
            alphaValue = 0.0
        }
    }
}
