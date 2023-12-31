//
//  Consultation.swift
//  AltibbiIOS
//
//  Created by Mahmoud Johar on 05/12/2023.
//

import Foundation

public enum MaritalStatus: String {
    case single = "single"
    case married = "married"
    case divorced = "divorced"
    case widow = "widow"
}

public enum BloodType: String {
    case APositive = "A+"
    case BPositive = "B+"
    case ABPositive = "AB+"
    case OPositive = "O+"
    case ANegative = "A-"
    case BNegative = "B-"
    case ABNegative = "AB-"
    case ONegative = "O-"
}

public enum ConsultationMedium: String {
    case chat = "chat"
    case gsm = "gsm"
    case voip = "voip"
    case video = "video"
}

public enum GenderType: String {
    case male = "male"
    case female = "female"
}

public class Consultation: Codable {
    public var userId: Int
    public var question: String
    public var medium: String
    public var mediaIds: [String]?
    public var parentConsultationId: Int?
    private(set) public var consultationId: Int?
    private(set) public var status: String?
    private(set) public var isFulfilled: Int?
    private(set) public var doctorName: String?
    private(set) public var doctorAvatar: String?
    private(set) public var createdAt: String?
    private(set) public var updatedAt: String?
    private(set) public var closedAt: String?
    private(set) public var user: User?
    private(set) public var parentConsultation: Consultation?
    private(set) public var consultations: [Consultation]?
    private(set) public var socketChannel: String?
    private(set) public var socketKey: String?
    private(set) public var chatConfig: ChatConfig?
    private(set) public var voipConfig: VoipConfig?
    private(set) public var videoConfig: VoipConfig?
    private(set) public var chatHistory: ChatHistory?
    private(set) public var recommendation: Recommendation?
    private(set) public var media: [Media]?
    
    
    // MARK: This init used for creating consultations
    public init(userId: Int, question: String, medium: String, mediaIds: [String]? = nil, parentConsultationId: Int? = nil) {
        self.userId = userId
        self.question = question
        self.medium = medium
        self.mediaIds = mediaIds
        self.parentConsultationId = parentConsultationId
    }
    
    private enum CodingKeys: String, CodingKey {
        case consultationId = "id"
        case status = "status"
        case isFulfilled = "is_fulfilled"
        case userId = "user_id"
        case question = "question"
        case medium = "medium"
        case mediaIds = "media_ids"
        case parentConsultationId = "parent_consultation_id"
        case doctorName = "doctor_name"
        case doctorAvatar = "doctor_avatar"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case closedAt = "closed_at"
        case user = "user"
        case parentConsultation = "parentConsultation"
        case consultations = "consultations"
        case socketChannel = "pusherChannel"
        case socketKey = "pusherAppKey"
        case chatConfig = "chatConfig"
        case voipConfig = "voipConfig"
        case videoConfig = "videoConfig"
        case chatHistory = "chatHistory"
        case recommendation = "recommendation"
        case media = "media"
    }
    
    public func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}

public struct CancelledConsultation: Decodable {
    private(set) public var status: String?
    private(set) public var consultationId: Int?
    
    private enum CodingKeys: String, CodingKey {
        case status = "status"
        case consultationId = "consultation_id"
    }
}
