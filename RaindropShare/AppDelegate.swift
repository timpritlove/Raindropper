import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    private var authWindow: NSWindow?
    private let raindropAPI = RaindropAPI()

    func applicationDidFinishLaunching(_ notification: Notification) {
        if !raindropAPI.isAuthenticated {
            showAuthWindow()
        }
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first,
              url.scheme == "raindrop-share" else {
            return
        }
        
        if url.host == "authenticate" {
            showAuthWindow()
        } else if url.host == "oauth-callback" {
            handleOAuthCallback(url)
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
    
    private func handleOAuthCallback(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            return
        }
        
        Task {
            do {
                try await raindropAPI.exchangeCodeForToken(code)
                authWindow?.close()
                authWindow = nil
                NSApp.terminate(nil)
            } catch {
                // Handle error
            }
        }
    }
} 