//
//  ZingNewApp.swift
//  ZingNew
//
//  Created by 067 on 26.01.2026.
//

import SwiftUI
import AppKit
import KeyboardShortcuts

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

/// AppDelegate to manage the floating panel lifecycle, hotkey, and menu bar icon
class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup global hotkey
        setupKeyboardShortcut()

        // Setup menu bar icon
        setupStatusItem()

        // Show the floating panel on launch
        FloatingPanelManager.shared.showPanel()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't terminate when panel is closed (it's hidden, not closed)
        return false
    }

    // MARK: - Keyboard Shortcut

    private func setupKeyboardShortcut() {
        // Set default shortcut (Shift + Option + T)
        KeyboardShortcuts.setShortcut(.init(.t, modifiers: [.shift, .option]), for: .toggleTranslator)

        // Register handler
        KeyboardShortcuts.onKeyUp(for: .toggleTranslator) { [weak self] in
            self?.togglePanel()
        }
    }

    @objc private func togglePanel() {
        FloatingPanelManager.shared.togglePanel()
    }

    // MARK: - Status Item (Menu Bar Icon)

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            // Use SF Symbol for icon
            button.image = NSImage(systemSymbolName: "character.bubble", accessibilityDescription: "Zing Translator")
            button.image?.size = NSSize(width: 18, height: 18)
            button.image?.isTemplate = true // Adapts to menu bar style (light/dark)
        }

        // Create menu
        let menu = NSMenu()

        let openItem = NSMenuItem(
            title: "Open Zing",
            action: #selector(openPanel),
            keyEquivalent: ""
        )
        openItem.target = self
        // Add hotkey hint as subtitle
        openItem.attributedTitle = createMenuItemTitle("Open Zing", hint: "⇧⌥T")
        menu.addItem(openItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.keyEquivalentModifierMask = .command
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    private func createMenuItemTitle(_ title: String, hint: String) -> NSAttributedString {
        let fullString = NSMutableAttributedString()

        // Main title
        let titleAttr = NSAttributedString(
            string: title,
            attributes: [
                .font: NSFont.menuFont(ofSize: 0)
            ]
        )
        fullString.append(titleAttr)

        // Hint (grayed out)
        let hintAttr = NSAttributedString(
            string: "  \(hint)",
            attributes: [
                .font: NSFont.menuFont(ofSize: 0),
                .foregroundColor: NSColor.secondaryLabelColor
            ]
        )
        fullString.append(hintAttr)

        return fullString
    }

    @objc private func openPanel() {
        FloatingPanelManager.shared.showPanel()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
