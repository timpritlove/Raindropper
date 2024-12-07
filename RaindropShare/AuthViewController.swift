import Cocoa
@preconcurrency import WebKit

class AuthViewController: NSViewController {
    private let webView = WKWebView()
    private let clientId = "YOUR_CLIENT_ID" // Get this from Raindrop.io
    private let redirectUri = "raindrop-share://oauth-callback"
    
    override func loadView() {
        view = NSView()
        view.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
        
        webView.navigationDelegate = self
        webView.frame = view.bounds
        webView.autoresizingMask = [.width, .height]
        view.addSubview(webView)
        
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
        
        let request = URLRequest(url: components.url!)
        webView.load(request)
    }
}

extension AuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
           url.scheme == "raindrop-share" {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
} 