//
//  ZingNewApp.swift
//  ZingNew
//
//  Created by 067 on 26.01.2026.
//

import SwiftUI
import AppKit

@main
struct ZingNewApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Empty settings scene (required but hidden)
        Settings {
            EmptyView()
        }
    }
}

/// AppDelegate to manage the floating panel lifecycle
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Show the floating panel on launch
        FloatingPanelManager.shared.showPanel()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't terminate when panel is closed (it's hidden, not closed)
        return false
    }
}
