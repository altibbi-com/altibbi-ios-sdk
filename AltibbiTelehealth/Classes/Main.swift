import Foundation
// Service
public struct AltibbiService {
    private(set) public static var token: String?
    private(set) public static var baseUrl: String?
    private(set) public static var language: String = "ar"
    // Rename to init
    public static func initService(token: String, baseUrl: String, language: String?) {
        AltibbiService.token = token
        AltibbiService.baseUrl = baseUrl
        if language != nil {
            AltibbiService.language = language!
        }
    }
}
