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

// MARK: - Sina AI Models

public class SinaSession: Codable {
    public var id: String?
    public var createdAt: String?
    public var updatedAt: String?
    public var videoConfig: VoipConfig?
    public var voipConfig: VoipConfig?

    public init() {}

    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case videoConfig = "video_config"
        case voipConfig = "voip_config"
    }
}

public struct SinaLink: Codable {
    public var url: String?
    public var brief: String?
}

public struct SinaMessageExtra: Codable {
    public var generalAnswer: String?

    private enum CodingKeys: String, CodingKey {
        case generalAnswer = "general_answer"
    }
}

public struct SinaMessageData: Codable {
    public var contentType: String?
    public var foundInRag: Bool?
    public var links: [SinaLink]?
    public var extra: SinaMessageExtra?

    private enum CodingKeys: String, CodingKey {
        case contentType = "content_type"
        case foundInRag = "found_in_rag"
        case links
        case extra
    }
}

public struct SinaMessage: Codable {
    public var id: Int?
    public var sender: String?
    public var text: String?
    public var chatId: String?
    public var createdAt: String?
    public var updatedAt: String?
    public var data: SinaMessageData?

    private enum CodingKeys: String, CodingKey {
        case id
        case sender
        case text
        case chatId = "chat_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case data
    }
}

public struct SinaMessagesPage: Codable {
    public var data: [SinaMessage]?
}

public struct SinaResponse: Codable {
    public var userMessage: SinaMessage?
    public var sinaMessage: SinaMessage?

    private enum CodingKeys: String, CodingKey {
        case userMessage = "user_message"
        case sinaMessage = "sina_message"
    }
}
