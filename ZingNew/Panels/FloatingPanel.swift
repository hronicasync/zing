//
//  FloatingPanel.swift
//  ZingNew
//
//  NSPanel wrapper for the floating translator overlay.
//

import SwiftUI
import AppKit

/// Custom NSPanel subclass for the floating translator overlay
class FloatingPanel: NSPanel {

    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        configurePanel()
    }

    private func configurePanel() {
        // Appearance
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false // Shadow is handled by SwiftUI

        // Behavior
        level = .floating
        isMovableByWindowBackground = true
        hidesOnDeactivate = false

        // Collection behavior for spaces and fullscreen
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .transient
        ]

        // Don't show in window lists
        isExcludedFromWindowsMenu = true
    }

    /// Create and configure the panel with SwiftUI content
    static func create() -> FloatingPanel {
        let panel = FloatingPanel(
            contentRect: .zero,
            styleMask: [],
            backing: .buffered,
            defer: false
        )

        // Create SwiftUI hosting view
        let hostingView = NSHostingView(rootView: TranslatorView())
        hostingView.translatesAutoresizingMaskIntoConstraints = false

        // Set the content view
        panel.contentView = hostingView

        // Size to fit content
        panel.setContentSize(hostingView.fittingSize)

        // Center on main screen
        panel.centerOnMainScreen()

        return panel
    }

    /// Center the panel on the main screen
    func centerOnMainScreen() {
        guard let screen = NSScreen.main else { return }

        let screenFrame = screen.visibleFrame
        let panelSize = frame.size

        let x = screenFrame.midX - (panelSize.width / 2)
        let y = screenFrame.midY - (panelSize.height / 2)

        setFrameOrigin(NSPoint(x: x, y: y))
    }

    /// Show the panel
    func show() {
        centerOnMainScreen()
        makeKeyAndOrderFront(nil)
    }

    /// Hide the panel
    func hide() {
        orderOut(nil)
    }

    /// Toggle panel visibility
    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }
}

/// Manager class to hold and control the floating panel
class FloatingPanelManager {
    static let shared = FloatingPanelManager()

    private(set) var panel: FloatingPanel?

    private init() {}

    func createPanel() {
        panel = FloatingPanel.create()
    }

    func showPanel() {
        if panel == nil {
            createPanel()
        }
        panel?.show()
    }

    func hidePanel() {
        panel?.hide()
    }

    func togglePanel() {
        if panel == nil {
            createPanel()
        }
        panel?.toggle()
    }
}
