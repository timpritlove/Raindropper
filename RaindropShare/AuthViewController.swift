import Cocoa
@preconcurrency import WebKit

class AuthViewController: NSViewController {
    private let webView: WKWebView = {
        // Create configuration
        let config = WKWebViewConfiguration()
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs
        
        // Enable password autofill with persistent data store
        let dataStore = WKWebsiteDataStore.default()
        config.websiteDataStore = dataStore
        
        // Create user content controller for scripts
        let userController = WKUserContentController()
        config.userContentController = userController
        
        // Create preferences
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        config.preferences = preferences
        
        // Create web view
        let webView = WKWebView(frame: .zero, configuration: config)
        
        // Enable standard features
        webView.allowsMagnification = true
        webView.allowsBackForwardNavigationGestures = true
        
        return webView
    }()
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        
        webView.frame = view.bounds
        webView.autoresizingMask = [.width, .height]
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        
        // Set UI delegate here
        webView.uiDelegate = self
        
        loadAuthPage()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(webView)
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
            print("Loading URL: \(url)")
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

// Navigation delegate
extension AuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Page loaded")
        view.window?.makeFirstResponder(webView)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Navigation failed: \(error)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Provisional navigation failed: \(error)")
    }
}

// UI delegate for additional functionality
extension AuthViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
} 