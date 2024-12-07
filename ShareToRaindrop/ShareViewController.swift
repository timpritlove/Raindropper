//
//  ShareViewController.swift
//  ShareToRaindrop
//
//  Created by Tim Pritlove on 07.12.24.
//

import Cocoa

class ShareViewController: NSViewController {
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
        guard let item = self.extensionContext?.inputItems.first as? NSExtensionItem else {
            await cancelShare()
            return
        }
        
        guard let attachments = item.attachments else {
            await cancelShare()
            return
        }
        
        await MainActor.run {
            for attachment in attachments {
                print("Processing attachment: \(attachment)")
            }
        }
    }
    
    @MainActor
    private func cancelShare() {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext?.cancelRequest(withError: cancelError)
    }
    
    @IBAction func send(_ sender: AnyObject?) {
        let outputItem = NSExtensionItem()
        let outputItems = [outputItem]
        self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
    }
    
    @IBAction func cancel(_ sender: AnyObject?) {
        Task {
            await cancelShare()
        }
    }
}
