import Foundation
import AppKit

class RaindropAPI {
    private struct TokenResponse: Codable {
        let access_token: String
        let refresh_token: String
    }
    
    private let baseURL = "https://api.raindrop.io/rest/v1"
    private let keychain = KeychainWrapper()
    
    var isAuthenticated: Bool {
        return keychain.string(forKey: "raindrop_token") != nil
    }
    
    func authenticate() async throws {
        // Open main app for authentication if not logged in
        if !isAuthenticated {
            if let url = URL(string: "raindrop-share://authenticate") {
                NSWorkspace.shared.open(url)
                throw RaindropError.needsAuthentication
            }
        }
    }
    
    func saveBookmark(url: String, title: String?) async throws {
        guard let token = keychain.string(forKey: "raindrop_token") else {
            throw RaindropError.needsAuthentication
        }
        
        let endpoint = "\(baseURL)/raindrop"
        guard let apiURL = URL(string: endpoint) else {
            throw RaindropError.invalidURL
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let bookmark = ["link": url, "title": title ?? url]
        request.httpBody = try JSONSerialization.data(withJSONObject: bookmark)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw RaindropError.saveFailed
        }
    }
    
    func exchangeCodeForToken(_ code: String) async throws {
        let tokenURL = "https://raindrop.io/oauth/access_token"
        guard let url = URL(string: tokenURL) else {
            throw RaindropError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "client_id": RaindropConfig.clientId,
            "client_secret": RaindropConfig.clientSecret,
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": RaindropConfig.redirectUri
        ]
        
        // Debug print request
        print("Token exchange request body:", body)
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug print response
        if let responseString = String(data: data, encoding: .utf8) {
            print("Token exchange response:", responseString)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RaindropError.authenticationFailed
        }
        
        print("HTTP Status Code:", httpResponse.statusCode)
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw RaindropError.authenticationFailed
        }
        
        do {
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            keychain.set(tokenResponse.access_token, forKey: "raindrop_token")
            print("Successfully decoded token response")
        } catch {
            print("Decoding error:", error)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("Raw JSON response:", json)
            }
            throw error
        }
    }
}

enum RaindropError: Error {
    case needsAuthentication
    case invalidURL
    case saveFailed
    case authenticationFailed
} 
