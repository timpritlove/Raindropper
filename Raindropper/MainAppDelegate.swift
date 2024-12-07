import Cocoa

class MainAppDelegate: NSObject, NSApplicationDelegate {
    private var authWindow: NSWindow?
    private let raindropAPI = RaindropAPI()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
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
    
    func application(_ application: NSApplication, open urls: [URL]) {
        print("Received URLs: \(urls)")
        
        guard let url = urls.first,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("Failed to get authorization code")
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
} 