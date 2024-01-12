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
    public var dateOfBirth: String?
    public var gender: String?
    public var insuranceId: String?
    public var policyNumber: String?
    public var nationalityNumber: String?
    public var height: Double?
    public var weight: Double?
    public var bloodType: String?
    public var smoker: String?
    public var alcoholic: String?
    public var maritalStatus: String?
    private(set) public var createdAt: String?
    private(set) public var updatedAt: String?
    private(set) public var avatar: String?
    
    public init(id: Int) {
        self.id = id
    }
    
    public init(
        name: String?,
        email: String? = nil,
        dateOfBirth: String? = nil,
        gender: String? = nil,
        insuranceId: String? = nil,
        policyNumber: String? = nil,
        nationalityNumber: String? = nil,
        height: Double? = nil,
        weight: Double? = nil,
        bloodType: String? = nil,
        smoker: String? = nil,
        alcoholic: String? = nil,
        maritalStatus: String? = nil
    ) {
        self.name = name
        self.email = email
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.insuranceId = insuranceId
        self.policyNumber = policyNumber
        self.nationalityNumber = nationalityNumber
        self.height = height
        self.weight = weight
        self.bloodType = bloodType
        self.smoker = smoker
        self.alcoholic = alcoholic
        self.maritalStatus = maritalStatus
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case email = "email"
        case dateOfBirth = "date_of_birth"
        case gender = "gender"
        case nationalityNumber = "nationality_number"
        case height = "height"
        case weight = "weight"
        case bloodType = "blood_type"
        case smoker = "smoker"
        case alcoholic = "alcoholic"
        case maritalStatus = "maritalStatus"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case avatar = "avatar"
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
