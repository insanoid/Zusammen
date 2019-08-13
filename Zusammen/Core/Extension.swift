//
//  Extension.swift
//
//  Created by Karthikeya Udupa on 08/08/2019
//  Copyright (c) Karthik. All rights reserved.
//

import Foundation

struct Extension: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case downloadType = "download_type"
        case descriptionValue = "description"
        case readmeUrl = "readme_url"
        case downloadUrl = "download_url"
        case sourceUrl = "source_url"
        case tags
    }

    /// Installation type for the extensions.
    enum InstallationType: String {
        case appleStore = "app_store"
        case githubSource = "github_source"
        case githubRelease = "github_release"
    }

    var name: String
    var downloadType: String
    var descriptionValue: String
    var screenshot: String?
    var sourceUrl: String?
    var downloadUrl: String?
    var tags: [String]?
    var readmeUrl: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        downloadType = try container.decode(String.self, forKey: .downloadType)
        descriptionValue = try container.decode(String.self, forKey: .descriptionValue)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        readmeUrl = try container.decodeIfPresent(String.self, forKey: .readmeUrl)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        downloadUrl = try container.decodeIfPresent(String.self, forKey: .downloadUrl)
    }
}
