//
//  SourceExtensionList.swift
//
//  Created by Karthikeya Udupa on 08/08/2019
//  Copyright (c) Karthik. All rights reserved.
//

import Foundation

/// A structure to hold a list of source extenion list.
struct SourceExtensionList: Codable {
    enum CodingKeys: String, CodingKey {
        case extensions
    }

    var extensions: [SourceExtension]

    init(extensions: [SourceExtension]) {
        self.extensions = extensions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        extensions = try container.decode([SourceExtension].self, forKey: .extensions)
    }

    /// Filter the list of source extension based on the values provided.
    ///
    /// - Parameters:
    ///   - searchString: String that needs to be searched for in the extension's details.
    ///   - limitToLatest: Limit the result to extensions that are made only in the latest version of Swift.
    /// - Returns: Filtered list of `SourceExtension`.
    func filter(_ searchString: String?, _ limitToLatest: Bool = false) -> [SourceExtension] {
        let filtered = extensions.filter { (extensionValue) -> Bool in
            let limitInRange = limitToLatest ? extensionValue.swiftVersionStartsWith(baseSwiftVersion: Constants.lastSwiftVersion) : true
            let searchString = searchString != nil && searchString!.count > 0 ? extensionValue.isAMatch(forString: searchString!) : true
            return limitInRange && searchString
        }
        // Filtered list need to be sorted alphabetically.
        return filtered.sorted(by: { (extensionOne, extensionTwo) -> Bool in
            extensionOne.name < extensionTwo.name
        })
    }
}
