import Cocoa
@preconcurrency import WebKit

class AuthViewController: NSViewController {
    private let webView = WKWebView()
    
    override func loadView() {
        // Create the main view
        view = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        
        // Configure WebView
        webView.frame = view.bounds
        webView.autoresizingMask = [.width, .height]
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        // Load the auth page immediately
        loadAuthPage()
    }
    
    private func loadAuthPage() {
        let authURL = "https://raindrop.io/oauth/authorize"
        var components = URLComponents(string: authURL)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: RaindropConfig.clientId),
            URLQueryItem(name: "redirect_uri", value: RaindropConfig.redirectUri),
            URLQueryItem(name: "response_type", value: "code")
        ]
        
        if let url = components.url {
            print("Loading URL: \(url)") // Add this for debugging
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

// Make sure we have the navigation delegate
extension AuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Page loaded")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Navigation failed: \(error)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Provisional navigation failed: \(error)")
    }
} 