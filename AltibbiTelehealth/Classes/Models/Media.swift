//
//  Media.swift
//  AltibbiIOS
//
//  Created by Mahmoud Johar on 06/12/2023.
//

import Foundation

public struct Media: Codable {
    private(set) public var id: String?
    private(set) public var type: String?
    private(set) public var name: String?
    private(set) public var path: String?
    private(set) public var ext: String?
    private(set) public var size: Int?
    private(set) public var createdAt: String?
    private(set) public var url: String?

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case name = "name"
        case path = "path"
        case ext = "extension"
        case size = "size"
        case createdAt = "created_at"
        case url = "url"

    }
}
