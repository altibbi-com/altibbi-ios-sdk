import Foundation
// MARK: For initiating the service with a user token, baseUrl and optional language
public struct AltibbiService {
    private(set) public static var token: String?
    private(set) public static var baseUrl: String?
    private(set) public static var sinaEndpoint: String?
    private(set) public static var language: String = "ar"
    public static var enableDebugLog: Bool = false

    public static func initService(token: String, baseUrl: String, language: String?, sinaModelEndPoint: String = "") {
        AltibbiService.token = token
        AltibbiService.baseUrl = baseUrl
        AltibbiService.sinaEndpoint = sinaModelEndPoint.isEmpty ? nil : sinaModelEndPoint
        if language != nil {
            AltibbiService.language = language!
        }
    }
}
