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
    ///   - selectedTag: Only show extensions with a certain tag.
    /// - Returns: Filtered list of `SourceExtension`.
    func filter(_ searchString: String?, _ limitToLatest: Bool = false, _ selectedTag: String? = nil) -> [SourceExtension] {
        let filtered = extensions.filter { (extensionValue) -> Bool in
            let limitInRange = limitToLatest ? extensionValue.swiftVersionStartsWith(baseSwiftVersion: Constants.lastSwiftVersion) : true
            let contentSearch = searchString != nil && searchString!.count > 0 ? extensionValue.isAMatch(forString: searchString!) : true
            let tagPresent = selectedTag != nil ? extensionValue.isTagged(withTag: selectedTag!) : true
            return limitInRange && contentSearch && tagPresent
        }
        // Filtered list need to be sorted alphabetically.
        return filtered.sorted(by: { (extensionOne, extensionTwo) -> Bool in
            extensionOne.name < extensionTwo.name
        })
    }

    /// Fetch all the unique tags in the source extensions provided.
    ///
    /// - Parameter inExtensions: Source extensions from which tags need to be considered.
    /// - Returns: Unique and alphabetically sorted tags.
    static func uniqueTags(inExtensions: [SourceExtension]) -> [String] {
        let allTags = inExtensions.compactMap { $0.tags }
        return Array(Set(Array(allTags.joined()))).sorted()
    }
}
