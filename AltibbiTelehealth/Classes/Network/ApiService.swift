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
        let ext = type == "pdf" ? "pdf" : "jpg"
        let fileName = "file-\(UUID().uuidString).\(ext)"
        let contentType = type == "pdf" ? "application/pdf" : "image/jpeg"
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
    
    public static func createConsultation(consultation: Consultation, completion: @escaping (Consultation?, Data?, Error?) -> Void) -> Void {
        
        do {
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
                completion(consultations?[0] as? Consultation, failure, error)

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
    
}
