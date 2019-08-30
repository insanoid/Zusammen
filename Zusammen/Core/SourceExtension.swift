//
//  SourceExtension.swift
//
//  Created by Karthikeya Udupa on 08/08/2019
//  Copyright (c) Karthik. All rights reserved.
//

import Foundation

/// Installation type for the extensions.
///
/// - appleStore: Is a link for apple store - it will be opened in the browser.
/// - githubSource: The source code is on github - it can be cloned to the tmp folder.
/// - githubRelease: A zipped version of the extension .app file is in the github. Pull and install the latest release.
/// - unknown: In case there is a future release type or a wrong one, app shouldn't break.
enum InstallationType: String, Codable {
    case appleStore = "app_store_link"
    case githubSource = "github_source"
    case githubRelease = "github_release"
    case unknown

    /// Provide the installation button title based on the installation Type.
    ///
    /// - Returns: Installation button title value.
    func installationText() -> String {
        switch self {
        case .appleStore:
            return "Install (Store)"
        case .githubSource:
            return "Install (Xcode Project)"
        case .githubRelease:
            return "Install (Download Ext.)"
        default:
            return "Cannot Install"
        }
    }
}

/// A structure to store information about Xcode source extension.
struct SourceExtension: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case installationType = "installation_type"
        case descriptionValue = "description"
        case readmeUrl = "readme_url"
        case downloadUrl = "download_url"
        case sourceUrl = "source_url"
        case swiftVersion = "swift_version"
        case tags
    }

    /// Name of the extension (used for searching)
    var name: String
    /// How to install this extension on the user's machine.
    var installationType: InstallationType
    /// Brief description of the extension and what it does (used for searching).
    var descriptionValue: String
    /// Source code URL, this can be nil when the app is on the store.
    var sourceUrl: String?
    /// URL to download the extension from, this is used in combination with `installationType`.
    var downloadUrl: String?
    /// Tags to categorise extensions (used for searching)
    var tags: [String]?
    /// Readme file URL, in some cases this is not present, in which case it can just be the app store page or the website.
    var readmeUrl: String?
    /// Version of Swift that was used to create this extension.
    /// This is important in case of `githubSource` kind of installation. As older versions can't be build.
    var swiftVersion: String?

    /// Initialise the object with the decoder (from JSON).
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        // Installation type needs to be converted from string to enum of `InstallationType`.
        do {
            installationType = try container.decode(InstallationType.self, forKey: .installationType)
        } catch {
            installationType = .unknown
        }
        descriptionValue = try container.decode(String.self, forKey: .descriptionValue)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        readmeUrl = try container.decodeIfPresent(String.self, forKey: .readmeUrl)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        downloadUrl = try container.decodeIfPresent(String.self, forKey: .downloadUrl)
        swiftVersion = try container.decodeIfPresent(String.self, forKey: .swiftVersion)
    }

    /// Is the source extension a positive match for string that is provided.
    /// We match the string with the name, description, and tags of the source extension.
    ///
    /// - Parameter forString: String which needs to be in the name, description, or tags.
    /// - Returns: Is the extension a match or nor for the provided string.
    func isAMatch(forString: String) -> Bool {
        let searchString = forString.uppercased()
        let tagContainsString = tags != nil ? tags!.contains(where: { (value) -> Bool in
            value.contains(forString)
        }) : true
        return name.uppercased().contains(searchString) || descriptionValue.uppercased().contains(searchString) ||
            tagContainsString
    }

    /// Check if the source extension's swift version matches the string that is provided.
    ///
    /// - Parameter baseSwiftVersion: Swift version that the extension must start from.
    /// - Returns: Boolean indicating if the swift version of the extension contains the version provided.
    func swiftVersionStartsWith(baseSwiftVersion: String) -> Bool {
        return swiftVersion != nil ? swiftVersion!.hasPrefix(baseSwiftVersion) : false
    }

    /// Combine all the strings in the tags array into 1 single string.
    ///
    /// - Returns: A single string containing all the tags seperated by a centered dot.
    func combineTags() -> String {
        guard let tagsValue = self.tags else {
            return ""
        }
        return tagsValue.map { $0.uppercased() }.joined(separator: " · ")
    }
}
