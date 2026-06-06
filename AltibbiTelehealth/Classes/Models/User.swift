//
//  User.swift
//  AltibbiIOS
//
//  Created by Mahmoud Johar on 29/11/2023.
//

import Foundation

public struct User: Codable {
    public var id: Int?
    public var name: String?
    public var email: String?
    public var phone: String?
    public var dateOfBirth: String?
    public var gender: String?
    public var insuranceId: String?
    public var policyNumber: String?
    public var tpaCode: String?
    public var payerName: String?
    public var nationalityNumber: String?
    public var height: Double?
    public var weight: Double?
    public var bloodType: String?
    public var smoker: String?
    public var alcoholic: String?
    public var maritalStatus: String?
    public var relationType: String?
    public var avatarMediaId: String?
    private(set) public var createdAt: String?
    private(set) public var updatedAt: String?
    private(set) public var avatar: String?

    public init(id: Int) {
        self.id = id
    }

    public init(
        name: String?,
        email: String? = nil,
        phone: String? = nil,
        dateOfBirth: String? = nil,
        gender: String? = nil,
        insuranceId: String? = nil,
        policyNumber: String? = nil,
        tpaCode: String? = nil,
        payerName: String? = nil,
        nationalityNumber: String? = nil,
        height: Double? = nil,
        weight: Double? = nil,
        bloodType: String? = nil,
        smoker: String? = nil,
        alcoholic: String? = nil,
        maritalStatus: String? = nil,
        relationType: String? = nil,
        avatarMediaId: String? = nil
    ) {
        self.name = name
        self.email = email
        self.phone = phone
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.insuranceId = insuranceId
        self.policyNumber = policyNumber
        self.tpaCode = tpaCode
        self.payerName = payerName
        self.nationalityNumber = nationalityNumber
        self.height = height
        self.weight = weight
        self.bloodType = bloodType
        self.smoker = smoker
        self.alcoholic = alcoholic
        self.maritalStatus = maritalStatus
        self.relationType = relationType
        self.avatarMediaId = avatarMediaId
    }

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case email = "email"
        case phone = "phone_number"
        case dateOfBirth = "date_of_birth"
        case gender = "gender"
        case nationalityNumber = "nationality_number"
        case height = "height"
        case weight = "weight"
        case bloodType = "blood_type"
        case smoker = "smoker"
        case alcoholic = "alcoholic"
        case maritalStatus = "marital_status"   // was wrongly "maritalStatus" — API returns snake_case
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case avatar = "avatar"
        case relationType = "relation_type"
        case insuranceId = "insurance_id"
        case policyNumber = "policy_number"
        case tpaCode = "tpa_code"
        case payerName = "payer_name"
        case avatarMediaId = "avatar_media_id"
    }

    public func fromJSON(_ jsonData: Data) throws -> User {
        let decoder = JSONDecoder()
        return try decoder.decode(User.self, from: jsonData)
    }

    public func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}
