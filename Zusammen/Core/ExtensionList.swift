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

    init(extensions: [Extension]) {
        self.extensions = extensions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        extensions = try container.decode([Extension].self, forKey: .extensions)
    }
    
    func filter(_ searchString: String?, _ limitToLatest: Bool = false) -> [Extension] {
        let filtered =  self.extensions.filter { (extensionValue) -> Bool in
            let limitInRange = limitToLatest ? extensionValue.versionContains(swiftVersion: Constants.lastSwiftVersion) : true
            let searchString = searchString != nil && searchString!.count > 0 ? extensionValue.contains(string: searchString!) : true
            return limitInRange && searchString
        }
        return filtered
    }
    
}
