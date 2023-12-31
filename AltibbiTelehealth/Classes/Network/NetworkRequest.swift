//
//  NetworkRequest.swift
//  AltibbiIOS
//
//  Created by Mahmoud Johar on 29/11/2023.
//

import Foundation

struct NetworkRequest {
    public static func sendApiRequest<T: Decodable>(_ httpRequest: URLRequest, download: Bool? = false, expectedType: T.Type, completion: @escaping (T?, Data?, Error?) -> Void) {
        URLSession.shared.dataTask(with: httpRequest) { (data, response, error) in
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(nil, nil, error)
                return
            }

            print("httpResponse.statusCode: \(httpResponse.statusCode)")
            print("From NetworkRequest, Print JSON Response")
            if httpResponse.statusCode >= 400 {
                completion(nil, data, nil)
//                do {
//                    let apiErrors = try JSONDecoder().decode(APIErrorsArray.self, from: data)
//                    let concatenatedMessages = apiErrors.errors.map { $0.message }.joined(separator: "\n")
//                    completion(nil, failure)
//                } catch {
//                    completion(nil, "Failed to decode error response")
//                }
            } else {
                printJsonData(data)
                if download! {
                    let identifier = "AltibbiFile-\(UUID().uuidString)"
                    let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        .appendingPathComponent("\(identifier).pdf")
                    do {
                        try data.write(to: destinationURL, options: Data.WritingOptions.atomic)
                        completion(destinationURL as? T, nil, nil)
                    } catch {
                        completion(nil, nil, error)
                    }
                    return
                }
                if httpRequest.httpMethod == "DELETE" && httpResponse.statusCode == 204 {
                    completion("Success" as? T, nil, nil)
                    return
                }
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    completion(decodedData, nil, nil)
                } catch {
                    completion(nil, nil, error)
                }
            }
        }.resume()
    }
    
    public static func prepareRequest(link: String, method: String, params: Dictionary<String, Any>, jsonBody: Data?, fileBoundary: String? = nil) -> URLRequest? {
        if let host = AltibbiService.baseUrl,
           let token = AltibbiService.token {
            print("TOKEN: \(token)")
            let urlLink = "https://" + host + "/v1\(link)"
            var urlComponents = URLComponents(string: urlLink)!
            
            // MARK: For parameters like expand
            if !params.isEmpty {
                urlComponents.queryItems = params.map { (key, value) in
                    if let intVal = value as? Int {
                        return URLQueryItem(name: key, value: String(intVal))
                    } else {
                        return URLQueryItem(name: key, value: value as? String)
                    }
                }
            }
            
            var httpRequest = URLRequest(url: urlComponents.url!)
            httpRequest.httpMethod = method
            
            // MARK: Main headers
            httpRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            httpRequest.setValue(AltibbiService.language, forHTTPHeaderField: "accept-language")
            
            // MARK: To add POST headers and JSON data to the httpBody
            if method == "POST" || method == "PUT" {
                if fileBoundary != nil {
                    httpRequest.setValue("multipart/form-data; boundary=\(fileBoundary ?? "")", forHTTPHeaderField: "Content-Type")
                } else {
                    httpRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                httpRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                if jsonBody != nil {
                    print("Request Body >>>")
                    printJsonData(jsonBody!)
                    httpRequest.httpBody = jsonBody
                }
            }
            
            return httpRequest
        }
        return nil
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
    
    public static func fileToData(jsonFile: Data, name: String, fileName: String, boundary: String, type: String) -> Data {
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(type)\r\n\r\n".data(using: .utf8)!)
        body.append(jsonFile)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }
    
}



