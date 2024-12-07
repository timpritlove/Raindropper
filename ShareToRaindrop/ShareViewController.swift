//
//  ShareViewController.swift
//  ShareToRaindrop
//
//  Created by Tim Pritlove on 07.12.24.
//

import Cocoa
import UniformTypeIdentifiers

class ShareViewController: NSViewController {
    private let raindropAPI = RaindropAPI()
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("ShareViewController")
    }
    
    override func loadView() {
        super.loadView()
        
        Task {
            await handleSharedContent()
        }
    }
    
    private func handleSharedContent() async {
        guard let item = self.extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = item.attachments else {
            await cancelShare()
            return
        }
        
        do {
            try await raindropAPI.authenticate()
            
            for attachment in attachments {
                if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    let url = try await attachment.loadItem(forTypeIdentifier: UTType.url.identifier) as? URL
                    let title = try await attachment.loadItem(forTypeIdentifier: UTType.text.identifier) as? String
                    
                    if let urlString = url?.absoluteString {
                        try await raindropAPI.saveBookmark(url: urlString, title: title)
                        await completeShare()
                        return
                    }
                }
            }
        } catch RaindropError.needsAuthentication {
            // The main app will handle authentication
            await cancelShare()
        } catch {
            await showError(message: "Failed to save bookmark: \(error.localizedDescription)")
            await cancelShare()
        }
    }
    
    private func showError(message: String) async {
        await MainActor.run {
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.beginSheetModal(for: self.view.window!) { _ in
                self.cancel(nil)
            }
        }
    }
    
    private func completeShare() async {
        await MainActor.run {
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
    
    private func cancelShare() async {
        await MainActor.run {
            let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
            self.extensionContext?.cancelRequest(withError: cancelError)
        }
    }
    
    @IBAction func cancel(_ sender: AnyObject?) {
        Task {
            await cancelShare()
        }
    }
}
