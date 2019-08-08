//
//  ExtensionList.swift
//
//  Created by Karthikeya Udupa on 08/08/2019
//  Copyright (c) Karthik. All rights reserved.
//

import Foundation

struct ExtensionList: Codable {
    enum CodingKeys: String, CodingKey {
        case extensions
    }

    var extensions: [Extension]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        extensions = try container.decode([Extension].self, forKey: .extensions)
    }
}
