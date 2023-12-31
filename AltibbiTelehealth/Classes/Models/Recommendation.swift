//
//  Recommendation.swift
//  AltibbiIOS
//
//  Created by Mahmoud Johar on 06/12/2023.
//

import Foundation

public struct Recommendation: Codable {
    private(set) public var id: Int?
    private(set) public var consultationId: Int?
    private(set) public var createdAt: String?
    private(set) public var updatedAt: String?
    private(set) public var data: [RecommendationData]?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case consultationId = "consultation_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case data = "data"
    }
}

public struct RecommendationData: Codable {
    private(set) public var lab: RecommendationLab?
    private(set) public var drug: RecommendationDrug?
    private(set) public var icd10: RecommendationICD10?
    private(set) public var doctorReferral: RecommendationDoctorReferral?
    private(set) public var followUp: [RecommendationFollowUp]?
    private(set) public var postCallAnswer: [RecommendationPostCallAnswer]?
}

public struct RecommendationLab: Codable {
    private(set) public var lab: [RecommendationLabItem]?
    private(set) public var panel: [RecommendationLabItem]?
}

public struct RecommendationLabItem: Codable {
    private(set) public var name: String?
}

public struct RecommendationDrug: Codable {
    private(set) public var fdaDrug: [RecommendationFdaDrug]?
}

public struct RecommendationFdaDrug: Codable {
    private(set) public var name: String?
    private(set) public var dosage: String?
    private(set) public var duration: Int?
    private(set) public var howToUse: String?
    private(set) public var frequency: String?
    private(set) public var tradeName: String?
    private(set) public var dosageForm: String?
    private(set) public var dosageUnit: String?
    private(set) public var packageSize: String?
    private(set) public var packageType: String?
    private(set) public var strengthValue: String?
    private(set) public var relationWithFood: String?
    private(set) public var specialInstructions: String?
    private(set) public var routeOfAdministration: String?
}

public struct RecommendationICD10: Codable {
    private(set) public var symptom: RecommendationSymptom?
    private(set) public var diagnosis: RecommendationDiagnosis?
}

public struct RecommendationSymptom: Codable {
    private(set) public var code: String?
    private(set) public var name: String?
}

public struct RecommendationDiagnosis: Codable {
    private(set) public var code: String?
    private(set) public var name: String?
}

public struct RecommendationFollowUp: Codable {
    private(set) public var name: String?
}

public struct RecommendationDoctorReferral: Codable {
    private(set) public var name: String?
}

public struct RecommendationPostCallAnswer: Codable {
    private(set) public var answer: String?
    private(set) public var question: String?
}

