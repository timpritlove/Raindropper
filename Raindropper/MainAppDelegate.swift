import Cocoa

class MainAppDelegate: NSObject, NSApplicationDelegate {
    private var authWindow: NSWindow?
    private let raindropAPI = RaindropAPI()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register for OAuth callback notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOAuthCallback(_:)),
            name: Notification.Name("RaindropOAuthCallback"),
            object: nil
        )
        
        if !raindropAPI.isAuthenticated {
            showAuthWindow()
        }
    }
    
    @objc private func handleOAuthCallback(_ notification: Notification) {
        guard let code = notification.userInfo?["code"] as? String else {
            return
        }
        
        print("Got authorization code: \(code)")
        
        Task {
            do {
                try await raindropAPI.exchangeCodeForToken(code)
                print("Successfully exchanged code for token")
                await MainActor.run {
                    authWindow?.close()
                    authWindow = nil
                }
            } catch {
                print("Error exchanging code: \(error)")
            }
        }
    }
    
    private func showAuthWindow() {
        let authVC = AuthViewController()
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.contentViewController = authVC
        window.title = "Login to Raindrop.io"
        
        authWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
} 