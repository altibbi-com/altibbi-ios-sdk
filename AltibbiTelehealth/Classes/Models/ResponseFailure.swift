//
//  OtherResponses.swift
//  AltibbiIOS
//
//  Created by Mahmoud Johar on 06/12/2023.
//

import Foundation

public struct ResponseFailure {
    public static func decodeResponse(jsonData: Data) -> APIErrorsArray? {
        do {
            let apiErrors = try JSONDecoder().decode(APIErrorsArray.self, from: jsonData)
            return apiErrors
        } catch {
            return nil
        }
    }
    
    public static func printJsonData(_ data: Data) -> Void {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyPrintedData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            if let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
                print(prettyPrintedString)
            } else {
                print("Unable to convert JSON data to string")
            }
        } catch {
            print("Error converting JSON data: \(error)")
        }
    }
}

public struct APIError: Decodable {
    var message: String
    var status: Int?
    var field: String?
}

public struct APIErrorsArray: Decodable {
    var errors: [APIError]

    public init(from decoder: Decoder) throws {
        // Try decoding as an array
        do {
            let container = try decoder.singleValueContainer()
            errors = try container.decode([APIError].self)
        } catch DecodingError.typeMismatch {
            // If decoding as an array fails, try decoding as a single object
            let singleError = try APIError(from: decoder)
            errors = [singleError]
        }
    }
}


