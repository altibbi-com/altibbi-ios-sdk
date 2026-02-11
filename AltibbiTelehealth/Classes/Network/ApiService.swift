//
//  ApiService.swift
//  AltibbiIOS
//
//  Created by Mahmoud Johar on 19/12/2023.
//

import Foundation

public struct ApiService {

    public static func uploadMedia(jsonFile: Data, type: String, completion: @escaping (Media?, Data?, Error?) -> Void) -> Void {
        let boundary = "Boundary-\(UUID().uuidString)"

        let normalizedType = type.lowercased()

        let (ext, contentType): (String, String) = {
            switch normalizedType {
            case "jpg", "jpeg":
                return ("jpg", "image/jpeg")
            case "png":
                return ("png", "image/png")
            case "gif":
                return ("gif", "image/gif")
            case "pdf":
                return ("pdf", "application/pdf")
            case "xls":
                return ("xls", "application/vnd.ms-excel")
            case "xlsx":
                return ("xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
            case "csv":
                return ("csv", "text/csv")
            default:
                return (normalizedType.isEmpty ? "bin" : normalizedType, "application/octet-stream")
            }
        }()

        let fileName = "file-\(UUID().uuidString).\(ext)"
        let jsonData = NetworkRequest.fileToData(jsonFile: jsonFile, name: "file", fileName: "\(fileName)", boundary: boundary, type: contentType)

        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/media",
            method: "POST",
            params: [:],
            jsonBody: jsonData,
            fileBoundary: boundary
        ) {
            NetworkRequest.sendApiRequest(httpRequest, expectedType: Media.self, completion: {media, failure, error in
                completion(media, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }

    }

    public static func createConsultation(consultation: Consultation,forceWhiteLabelingPartnerName: String? = nil, completion: @escaping (Consultation?, Data?, Error?) -> Void) -> Void {

        do {
            if let forceWhiteLabelingPartnerName = forceWhiteLabelingPartnerName, !forceWhiteLabelingPartnerName.isEmpty {
                consultation.question += " ~\(forceWhiteLabelingPartnerName)~"
            }
            if let httpRequest = NetworkRequest.prepareRequest(
                link: "/consultations",
                method: "POST",
                params: [
                    "expand": "pusherAppKey,parentConsultation,consultations,user,media,pusherChannel,chatConfig,chatHistory,voipConfig,videoConfig,recommendation"
                ],
                jsonBody: try consultation.toJSON(),
                fileBoundary: nil
            ) {
                NetworkRequest.sendApiRequest(httpRequest, expectedType: Consultation.self, completion: {createdConsultation, failure, error in
                    completion(createdConsultation, failure, error)
                })
            } else {
                completion(nil, nil, nil)
            }
        } catch {
            completion(nil, nil, error)
        }
    }

    public static func cancelConsultation(id: Int, completion: @escaping (CancelledConsultation?, Data?, Error?) -> Void) -> Void {
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/consultations/\(id)/cancel",
            method: "POST",
            params: [:],
            jsonBody: nil
        ) {
            NetworkRequest.sendApiRequest(httpRequest, expectedType: CancelledConsultation.self, completion: {cancelled, failure, error in
                completion(cancelled, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }

    public static func deleteConsultation(id: Int, completion: @escaping (String?, Data?, Error?) -> Void) -> Void {
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/consultations/\(id)",
            method: "DELETE",
            params: [:],
            jsonBody: nil
        ) {
            NetworkRequest.sendApiRequest(httpRequest, expectedType: String.self, completion: {success, failure, error in
                completion(success, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }

    public static func getConsultationInfo(id: Int, completion: @escaping (Consultation?, Data?, Error?) -> Void) -> Void {
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/consultations/\(id)",
            method: "GET",
            params: [
                "expand": "pusherAppKey,parentConsultation,consultations,user,media,pusherChannel,chatConfig,chatHistory,voipConfig,videoConfig,recommendation"
            ],
            jsonBody: nil
        ) {
            NetworkRequest.sendApiRequest(httpRequest, expectedType: Consultation.self, completion: {consultation, failure, error in
                completion(consultation, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }

    public static func getConsultationList(userId: Int? = nil, page: Int, perPage: Int, completion: @escaping ([Consultation]?, Data?, Error?) -> Void) -> Void {
        var requestParams: Dictionary<String, Any> = [
            "page": String(page),
            "per-page": String(perPage),
            "sort": "-id",
            "expand": "pusherAppKey,parentConsultation,consultations,user,media,pusherChannel,chatConfig,chatHistory,voipConfig,videoConfig,recommendation"
        ]
        if userId != nil {
            requestParams["filter[user_id]"] = userId
        }
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/consultations",
            method: "GET",
            params: requestParams,
            jsonBody: nil
        ) {
            NetworkRequest.sendApiRequest(httpRequest, expectedType: [Consultation].self, completion: {consultations, failure, error in
                completion(consultations, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }

    public static func getLastConsultation(completion: @escaping (Consultation?, Data?, Error?) -> Void) -> Void {
        let requestParams = [
            "per-page": "1",
            "sort": "-id",
            "expand": "pusherAppKey,parentConsultation,consultations,user,media,pusherChannel,chatConfig,chatHistory,voipConfig,videoConfig,recommendation"
        ]
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/consultations",
            method: "GET",
            params: requestParams,
            jsonBody: nil
        ) {
            NetworkRequest.sendApiRequest(httpRequest, expectedType: [Consultation].self, completion: {consultations, failure, error in
                completion(consultations?.first as? Consultation, failure, error)

            })
        } else {
            completion(nil, nil, nil)
        }
    }

    public static func getPrescription(id: Int, completion: @escaping (URL?, Data?, Error?) -> Void) -> Void {
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/consultations/\(id)/download-prescription",
            method: "GET",
            params: [:],
            jsonBody: nil
        ) {
            NetworkRequest.sendApiRequest(httpRequest, download: true, expectedType: URL.self, completion: {pathUrl, failure, error in
                completion(pathUrl, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }

    public static func getUser(id: Int, completion: @escaping (User?, Data?, Error?) -> Void) -> Void {
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/users/\(id)",
            method: "GET",
            params: ["expand":"avatar"],
            jsonBody: nil
        ) {
            print("Request: \(String(describing: httpRequest))")
            NetworkRequest.sendApiRequest(httpRequest, expectedType: User.self, completion: {user, failure, error in
                completion(user, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }

    public static func deleteUser(id: Int, completion: @escaping (String?, Data?, Error?) -> Void) -> Void {
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/users/\(id)",
            method: "DELETE",
            params: [:],
            jsonBody: nil
        ) {
            NetworkRequest.sendApiRequest(httpRequest, expectedType: String.self, completion: {success, failure, error in
                completion(success, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }

    public static func getUsers(page: Int, perPage: Int, completion: @escaping ([User]?, Data?, Error?) -> Void) -> Void {
        let requestParams = [
            "page": String(page),
            "per-page": String(perPage),
            "expand": "avatar"
        ]
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/users",
            method: "GET",
            params: requestParams,
            jsonBody: nil
        ) {
            NetworkRequest.sendApiRequest(httpRequest, expectedType: [User].self, completion: {users, failure, error in
                completion(users, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }

    public static func updateUser(id: Int, userData: User, completion: @escaping (User?, Data?, Error?) -> Void) -> Void {
        do {
            print("From ApiService on Calling updateUser, the JSON data to be sent:")
            NetworkRequest.printJsonData(try userData.toJSON())
            if let httpRequest = try NetworkRequest.prepareRequest(
                link: "/users/\(id)",
                method: "PUT",
                params: [:],
                jsonBody: userData.toJSON()
            ) {
                print("Request: \(String(describing: httpRequest))")
                NetworkRequest.sendApiRequest(httpRequest, expectedType: User.self, completion: {user, failure, error in
                    completion(user, failure, error)
                })
            } else {
                completion(nil, nil, nil)
            }
        } catch {
            completion(nil, nil, error)
        }

    }

    public static func createUser(userData: User, completion: @escaping (User?, Data?, Error?) -> Void) -> Void {
        do {
            if let httpRequest = try NetworkRequest.prepareRequest(
                link: "/users",
                method: "POST",
                params: [:],
                jsonBody: userData.toJSON()
            ) {
                NetworkRequest.sendApiRequest(httpRequest, expectedType: User.self, completion: {user, failure, error in
                    completion(user, failure, error)
                })
            } else {
                completion(nil, nil, nil)
            }
        } catch {
            completion(nil, nil, error)
        }
    }

    public static func rateConsultation(id: Int,score: Int, completion: @escaping (String?, Data?, Error?) -> Void) -> Void {
        let jsonData = try? JSONSerialization.data(withJSONObject: ["score": score], options: [])

        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/consultations/\(id)/rate",
            method: "POST",
            params: [:],
            jsonBody: jsonData
        ) {
            NetworkRequest.sendApiRequest(httpRequest, expectedType: String.self, completion: {success, failure, error in
                completion(success, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }

    public static func getPredictSummary(id: Int, completion: @escaping (PredictSummary?, Data?, Error?) -> Void) -> Void {
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/consultations/\(id)/predict-summary",
            method: "GET",
            params: [:],
            jsonBody: nil
        ) {
            NetworkRequest.sendApiRequest(httpRequest, download: true, expectedType: PredictSummary.self, completion: {predictSummary, failure, error in
                completion(predictSummary, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }

    public static func getSoapSummary(id: Int, completion: @escaping (Soap?, Data?, Error?) -> Void) -> Void {
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/consultations/\(id)/soap-summary",
            method: "GET",
            params: [:],
            jsonBody: nil
        ) {
            NetworkRequest.sendApiRequest(httpRequest, download: true, expectedType: Soap.self, completion: {soapSummary, failure, error in
                completion(soapSummary, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }

    public static func getTranscription(id: Int, completion: @escaping (Transcription?, Data?, Error?) -> Void) -> Void {
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/consultations/\(id)/getTranscription",
            method: "GET",
            params: [:],
            jsonBody: nil
        ) {
            NetworkRequest.sendApiRequest(httpRequest, download: true, expectedType: Transcription.self, completion: {transcription, failure, error in
                completion(transcription, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }

    public static func getPredictSpecialty(id: Int, completion: @escaping (PredictSpecialty?, Data?, Error?) -> Void) -> Void {
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/consultations/\(id)/predict-specialty",
            method: "GET",
            params: [:],
            jsonBody: nil
        ) {
            NetworkRequest.sendApiRequest(httpRequest, download: true, expectedType: PredictSpecialty.self, completion: {speciality, failure, error in
                completion(speciality, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }

    public static func getMediaList(page: Int, perPage: Int, completion: @escaping ([Media]?, Data?, Error?) -> Void) -> Void {
        var requestParams: Dictionary<String, Any> = [
            "page": String(page),
            "per-page": String(perPage)
        ]
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/media",
            method: "GET",
            params: requestParams,
            jsonBody: nil
        ) {
            NetworkRequest.sendApiRequest(httpRequest, expectedType: [Media].self, completion: {mediaList, failure, error in
                completion(mediaList, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }

    public static func deleteMedia(id: Int, completion: @escaping (String?, Data?, Error?) -> Void) -> Void {
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "/media/\(id)",
            method: "DELETE",
            params: [:],
            jsonBody: nil
        ) {
            NetworkRequest.sendApiRequest(httpRequest, expectedType: String.self, completion: {success, failure, error in
                completion(success, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }


    public static func getArticlesList(subcategoryIds: [Int], page: Int, perPage: Int, completion: @escaping ([Article]?, Data?, Error?) -> Void) -> Void {
        let requestParams: Dictionary<String, Any> = [
            "page": String(page),
            "per-page": String(perPage),
            "filter[sub_category_id][in]": subcategoryIds,
            "sort": "-article_id",
        ]
        if let httpRequest = NetworkRequest.prepareRequest(
            link: "https://rest-api.altibbi.com/active/v1/articles",
            method: "GET",
            params: requestParams,
            jsonBody: nil
        ) {
            NetworkRequest.sendApiRequest(httpRequest, expectedType: [Article].self, completion: {articlesList, failure, error in
                completion(articlesList, failure, error)
            })
        } else {
            completion(nil, nil, nil)
        }
    }
}
