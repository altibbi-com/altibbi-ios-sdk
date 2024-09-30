//
//  AIModels.swift
//  AltibbiIOS
//
//  Created by Shtayyat on 28/09/2024.
//

import Foundation


// Transcription struct
public struct Transcription: Codable {
    public var transcript: String?

    private enum CodingKeys: String, CodingKey {
        case transcript
    }
}

// PredictSpecialty struct
public struct SubCategory: Codable {
    public var subCategoryId: Int
    public var nameEn: String
    public var nameAr: String

    private enum CodingKeys: String, CodingKey {
        case subCategoryId = "sub_category_id"
        case nameEn = "name_en"
        case nameAr = "name_ar"
    }
}

public struct PredictSpecialty: Codable {
    public var specialtyID: Int?
    public var subCategories: [SubCategory]?

    private enum CodingKeys: String, CodingKey {
        case specialtyID = "specialty_id"
        case subCategories = "subCategories"
    }
}

// PredictSummary struct
public struct PredictSummary: Codable {
    public var summary: String?

    private enum CodingKeys: String, CodingKey {
        case summary
    }
}

// Soap struct with nested types
public struct Soap: Codable {
    public var summary: Summary?

    public struct Summary: Codable {
        public var subjective: Subjective?
        public var objective: Objective?
        public var assessment: Assessment?
        public var plan: Plan?

        public struct Subjective: Codable {
            public var symptoms: String?
            public var concerns: String?

            private enum CodingKeys: String, CodingKey {
                case symptoms
                case concerns
            }
        }

        public struct Objective: Codable {
            public var laboratoryResults: String?
            public var physicalExaminationFindings: String?

            private enum CodingKeys: String, CodingKey {
                case laboratoryResults = "laboratory_results"
                case physicalExaminationFindings = "physical_examination_findings"
            }
        }

        public struct Assessment: Codable {
            public var diagnosis: String?
            public var differentialDiagnosis: String?

            private enum CodingKeys: String, CodingKey {
                case diagnosis
                case differentialDiagnosis = "differential_diagnosis"
            }
        }

        public struct Plan: Codable {
            public var nonPharmacologicalIntervention: String?
            public var medications: String?
            public var referrals: String?
            public var followUpInstructions: String?

            private enum CodingKeys: String, CodingKey {
                case nonPharmacologicalIntervention = "non_pharmacological_intervention"
                case medications
                case referrals
                case followUpInstructions = "follow_up_instructions"
            }
        }

        private enum CodingKeys: String, CodingKey {
            case subjective
            case objective
            case assessment
            case plan
        }
    }

    private enum CodingKeys: String, CodingKey {
        case summary
    }
}


public struct Article: Codable {
    let articleId: Int
    let slug: String
    let subCategoryId: Int
    let title: String
    let body: String
    let articleReferences: String
    let activationDate: String
    let publishStatus: String
    let adultContent: Bool
    let featured: Bool
    let dateAdded: String
    let dateModified: String
    let bodyClean: String
    let imageUrl: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case articleId = "article_id"
        case slug
        case subCategoryId = "sub_category_id"
        case title
        case body
        case articleReferences = "article_references"
        case activationDate = "activation_date"
        case publishStatus = "publish_status"
        case adultContent = "adult_content"
        case featured
        case dateAdded = "date_added"
        case dateModified = "date_modified"
        case bodyClean = "body_clean"
        case imageUrl
        case url
    }
}
