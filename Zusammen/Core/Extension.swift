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
        case screenshot
        case url
        case tags
    }

    var name: String
    var downloadType: String
    var descriptionValue: String
    var screenshot: String?
    var url: String?
    var downloadUrl: String?
    var tags: [String]?
    var readmeUrl: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        downloadType = try container.decode(String.self, forKey: .downloadType)
        descriptionValue = try container.decode(String.self, forKey: .descriptionValue)
        screenshot = try container.decodeIfPresent(String.self, forKey: .screenshot)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        readmeUrl = try container.decodeIfPresent(String.self, forKey: .readmeUrl)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        downloadUrl = try container.decodeIfPresent(String.self, forKey: .downloadUrl)
    }
}
