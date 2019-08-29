//
//  ExtensionListLoader.swift
//  Zusammen
//
//  Created by Karthikeya Udupa on 08/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Foundation

struct ExtensionListLoader {
    /// Load all possible extensions from the JSON source.
    ///
    /// - Parameter searchString: Search string provided by the user.
    /// - Parameter limitToLatest: Limit the extensions which use the latest version of the swift.
    /// - Returns: List of `ExtensionList` from the JSON source file.
    /// - Throws: JSON parsing errors.
    static func getExtensions(_ searchString: String?, _ limitToLatest: Bool = false) throws -> [Extension] {
        let extensionsListJSON = try loadJSONFile("source")
        let jsonData = extensionsListJSON.data(using: .utf8)!
        return try JSONDecoder().decode(ExtensionList.self, from: jsonData).filter(searchString, limitToLatest)
    }

    /// Load the JSON file from the bundle.
    ///
    /// - Parameter filename: Filename for the JSON file.
    /// - Returns: The JSON file content as string.
    /// - Throws: Throws the error when fetching file and reading the content as string.
    private static func loadJSONFile(_ filename: String) throws -> String {
        guard let path = Bundle.main.path(forResource: filename, ofType: "json") else {
            return ""
        }
        let content = try String(contentsOfFile: path)
        return content
    }
}
