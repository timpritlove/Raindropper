//
//  RaindropperApp.swift
//  Raindropper
//
//  Created by Tim Pritlove on 07.12.24.
//

import SwiftUI

struct RaindropperApp: App {
    @NSApplicationDelegateAdaptor(MainAppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
