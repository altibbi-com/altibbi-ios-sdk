//
//  ChatHistory.swift
//  AltibbiIOS
//
//  Created by Mahmoud Johar on 06/12/2023.
//

import Foundation

public struct ChatHistory: Codable {
    private(set) public var id: Int?
    private(set) public var consultationId: Int?
    private(set) public var createdAt: String?
    private(set) public var updatedAt: String?
    private(set) public var data: [ChatData]?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case consultationId = "consultation_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case data = "data"
    }
}

public struct ChatData: Codable {
    private(set) public var id: String?
    private(set) public var message: String?
    private(set) public var sentAt: String?
    private(set) public var chatUserId: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case message = "message"
        case sentAt = "sent_at"
        case chatUserId = "chat_user_id"
    }
}
