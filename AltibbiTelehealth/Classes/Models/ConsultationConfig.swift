//
//  ConsultationConfig.swift
//  AltibbiIOS
//
//  Created by Mahmoud Johar on 06/12/2023.
//

import Foundation

public struct ChatConfig: Codable {
    private(set) public var id: Int?
    private(set) public var consultationId: Int?
    private(set) public var groupId: String?
    private(set) public var chatUserId: String?
    private(set) public var appId: String?
    private(set) public var chatUserToken: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case consultationId = "consultation_id"
        case groupId = "group_id"
        case appId = "app_id"
        case chatUserId = "chat_user_id"
        case chatUserToken = "chat_user_token"
    }
    
}

public struct VoipConfig: Codable {
    private(set) public var id: Int?
    private(set) public var consultationId: Int?
    private(set) public var apiKey: String?
    private(set) public var callId: String?
    private(set) public var token: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case consultationId = "consultation_id"
        case apiKey = "api_key"
        case callId = "call_id"
        case token = "token"
    }
}
