//
//  FloatingPanel.swift
//  ZingNew
//
//  NSPanel wrapper for the floating translator overlay with animations.
//

import SwiftUI
import AppKit

/// Custom NSPanel subclass for the floating translator overlay
class FloatingPanel: NSPanel {

    private var originalSize: NSSize = .zero

    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        configurePanel()
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    private func configurePanel() {
        // Appearance
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true // Native macOS shadow

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

        // Initial alpha for animation
        alphaValue = 0
    }

    /// Create and configure the panel with SwiftUI content and injected ViewModel
    static func create(with viewModel: TranslatorViewModel) -> FloatingPanel {
        let panel = FloatingPanel(
            contentRect: .zero,
            styleMask: [],
            backing: .buffered,
            defer: false
        )

        // Create SwiftUI hosting view with injected ViewModel
        let translatorView = TranslatorView(viewModel: viewModel)
        let hostingView = NSHostingView(rootView: translatorView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false

        // Set the content view
        panel.contentView = hostingView

        // Size to fit content
        let fittingSize = hostingView.fittingSize
        panel.setContentSize(fittingSize)
        panel.originalSize = fittingSize

        // Center on main screen
        panel.centerOnMainScreen()

        return panel
    }

    /// Center the panel on the main screen
    func centerOnMainScreen() {
        guard let screen = NSScreen.main else { return }

        let screenFrame = screen.visibleFrame
        let panelSize = originalSize.width > 0 ? originalSize : frame.size

        let x = screenFrame.midX - (panelSize.width / 2)
        let y = screenFrame.midY - (panelSize.height / 2)

        setFrameOrigin(NSPoint(x: x, y: y))

        // Ensure correct size
        if originalSize.width > 0 {
            setContentSize(originalSize)
        }
    }

    // MARK: - Animated Show/Hide

    /// Show the panel with fade + scale spring animation (from bottom center)
    func showAnimated() {
        centerOnMainScreen()

        // Activate app to ensure proper focus
        NSApp.activate(ignoringOtherApps: true)

        // Initial state for animation
        alphaValue = 0

        // Ensure layer-backing for scale animation
        contentView?.wantsLayer = true
        guard let layer = contentView?.layer else {
            makeKeyAndOrderFront(nil)
            alphaValue = 1
            return
        }

        // Initial transform: scale down + translate down (so bottom center stays fixed)
        let scale = Constants.Animation.showScale
        let offsetY = layer.bounds.height * (1 - scale) / 2
        layer.setAffineTransform(
            CGAffineTransform(scaleX: scale, y: scale)
                .translatedBy(x: 0, y: -offsetY / scale)
        )

        // Show window
        makeKeyAndOrderFront(nil)

        // Fade animation
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animator().alphaValue = 1
        }

        // Spring scale animation
        let spring = CASpringAnimation(keyPath: "transform")
        spring.fromValue = CATransform3DMakeAffineTransform(
            CGAffineTransform(scaleX: scale, y: scale)
                .translatedBy(x: 0, y: -offsetY / scale)
        )
        spring.toValue = CATransform3DIdentity
        spring.damping = 15
        spring.stiffness = 300
        spring.duration = spring.settlingDuration
        layer.add(spring, forKey: "transformIn")
        layer.setAffineTransform(.identity)
    }

    /// Hide the panel with fade + scale animation
    func hideAnimated(completion: (() -> Void)? = nil) {
        guard let layer = contentView?.layer else {
            orderOut(nil)
            completion?()
            return
        }

        // Target transform: scale down + translate down (bottom center stays fixed)
        let scale = Constants.Animation.showScale
        let offsetY = layer.bounds.height * (1 - scale) / 2
        let targetTransform = CGAffineTransform(scaleX: scale, y: scale)
            .translatedBy(x: 0, y: -offsetY / scale)

        // Fade animation
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Constants.Animation.hideDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            animator().alphaValue = 0
        }

        // Scale + translate animation
        let anim = CABasicAnimation(keyPath: "transform")
        anim.toValue = CATransform3DMakeAffineTransform(targetTransform)
        anim.duration = Constants.Animation.hideDuration
        anim.timingFunction = CAMediaTimingFunction(name: .easeIn)
        layer.add(anim, forKey: "transformOut")

        // Completion after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animation.hideDuration) { [weak self] in
            self?.contentView?.layer?.setAffineTransform(.identity)
            self?.orderOut(nil)
            completion?()
        }
    }

    /// Toggle panel visibility with animation
    func toggleAnimated() {
        if isVisible && alphaValue > 0 {
            hideAnimated()
        } else {
            showAnimated()
        }
    }

    // MARK: - Legacy Methods (for compatibility)

    /// Show the panel
    func show() {
        showAnimated()
    }

    /// Hide the panel
    func hide() {
        hideAnimated()
    }

    /// Toggle panel visibility
    func toggle() {
        toggleAnimated()
    }
}

// MARK: - FloatingPanelManager

/// Manager class to hold and control the floating panel
class FloatingPanelManager {
    static let shared = FloatingPanelManager()

    private(set) var panel: FloatingPanel?

    /// Shared ViewModel - created ONCE and reused across show/hide cycles
    let viewModel = TranslatorViewModel()

    private init() {}

    func createPanel() {
        panel = FloatingPanel.create(with: viewModel)
    }

    func showPanel() {
        if panel == nil {
            createPanel()
        }
        panel?.showAnimated()
    }

    func hidePanel() {
        panel?.hideAnimated()
    }

    func togglePanel() {
        if panel == nil {
            createPanel()
        }
        panel?.toggleAnimated()
    }

    /// Check if panel is currently visible
    var isPanelVisible: Bool {
        return panel?.isVisible ?? false
    }
}
