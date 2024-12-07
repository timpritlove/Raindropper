import Cocoa
@preconcurrency import WebKit  // Need this for AuthViewController

class ShareExtensionDelegate: NSObject, NSApplicationDelegate {
    private var authWindow: NSWindow?
    private let raindropAPI = RaindropAPI()

    func applicationDidFinishLaunching(_ notification: Notification) {
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
    
    @objc private func handleOAuthCallback(_ notification: Notification) {
        guard let code = notification.userInfo?["code"] as? String else {
            return
        }
        
        Task {
            do {
                try await raindropAPI.exchangeCodeForToken(code)
                await MainActor.run {
                    authWindow?.close()
                    authWindow = nil
                    NSApp.terminate(nil)
                }
            } catch {
                print("Error exchanging code: \(error)")
            }
        }
    }
} 