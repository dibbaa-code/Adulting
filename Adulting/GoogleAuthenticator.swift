import Foundation
import GoogleSignIn
import UIKit

class GoogleAuthenticator: ObservableObject {
    static let shared = GoogleAuthenticator()
    
    @Published var isAuthenticated = false
    
    // Google OAuth scopes
    private let scopes = [
        "https://www.googleapis.com/auth/calendar.readonly",
        "https://www.googleapis.com/auth/calendar.events.readonly"
    ]
    
    // MARK: - Configuration
    static func configure() {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            fatalError("GoogleService-Info.plist not found or CLIENT_ID missing")
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
    }
    
    static func handleURL(_ url: URL) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    private init() {
        // Configuration is handled by the static configure() method
    }
    
    func signIn() async throws -> GIDGoogleUser {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw NSError(domain: "GoogleAuthenticator", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController, hint: nil, additionalScopes: self.scopes) { signInResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let signInResult = signInResult else {
                    continuation.resume(throwing: NSError(domain: "GoogleAuthenticator", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sign in result is nil"]))
                    return
                }
                
                self.isAuthenticated = true
                continuation.resume(returning: signInResult.user)
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isAuthenticated = false
    }
    
    func getAccessToken() -> String? {
        return GIDSignIn.sharedInstance.currentUser?.accessToken.tokenString
    }
    
    func getRefreshToken() -> String? {
        return GIDSignIn.sharedInstance.currentUser?.refreshToken.tokenString
    }
    
    func getEmail() -> String? {
        return GIDSignIn.sharedInstance.currentUser?.profile?.email
    }
    
    func getUserName() -> String? {
        return GIDSignIn.sharedInstance.currentUser?.profile?.name
    }
    
    // MARK: - Calendar API
    func fetchCalendarEvents() async throws -> [String: Any] {
        guard let accessToken = getAccessToken() else {
            throw NSError(domain: "GoogleAuthenticator", code: -1, userInfo: [NSLocalizedDescriptionKey: "No access token available"])
        }
        
        let urlString = "https://www.googleapis.com/calendar/v3/calendars/primary/events"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "GoogleAuthenticator", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "GoogleAuthenticator", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch calendar events"])
        }
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        return jsonObject ?? [:]
    }
}
