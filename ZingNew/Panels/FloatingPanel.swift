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

    /// Reference to hosting view for dynamic resizing
    private var hostingView: NSHostingView<TranslatorView>?

    /// Observer for size changes
    private var sizeObserver: NSObjectProtocol?

    /// Extra padding around content to allow spring overshoot without clipping
    private static let animationPadding: CGFloat = 20

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
        panel.hostingView = hostingView

        let padding = animationPadding

        // Wrapper view with extra padding for spring animation overshoot
        let wrapperView = NSView()
        wrapperView.wantsLayer = true
        wrapperView.layer?.masksToBounds = false  // Critical: allow spring overshoot
        wrapperView.translatesAutoresizingMaskIntoConstraints = false

        // Configure hostingView for Auto Layout
        hostingView.wantsLayer = true
        hostingView.layer?.masksToBounds = false
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.setContentHuggingPriority(.required, for: .horizontal)
        hostingView.setContentHuggingPriority(.required, for: .vertical)

        wrapperView.addSubview(hostingView)

        // Set wrapper as content view
        panel.contentView = wrapperView

        // Auto Layout constraints: hostingView with padding inside wrapper
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: padding),
            hostingView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -padding),
            hostingView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: padding),
            hostingView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -padding)
        ])

        // Initial size
        panel.updatePanelSize()

        // Observe size changes
        panel.setupSizeObserver()

        // Center on main screen
        panel.centerOnMainScreen()

        return panel
    }

    /// Update panel size based on hostingView's fittingSize
    private func updatePanelSize() {
        guard let hostingView = hostingView else { return }

        let fittingSize = hostingView.fittingSize
        let padding = FloatingPanel.animationPadding
        let newSize = NSSize(
            width: fittingSize.width + padding * 2,
            height: fittingSize.height + padding * 2
        )

        if newSize != originalSize {
            setContentSize(newSize)
            originalSize = newSize
        }
    }

    /// Setup observer for hostingView frame changes
    private func setupSizeObserver() {
        guard let hostingView = hostingView else { return }

        hostingView.postsFrameChangedNotifications = true
        sizeObserver = NotificationCenter.default.addObserver(
            forName: NSView.frameDidChangeNotification,
            object: hostingView,
            queue: .main
        ) { [weak self] _ in
            self?.updatePanelSize()
        }
    }

    deinit {
        if let observer = sizeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
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

        // Get hostingView for scale animation
        // This allows spring overshoot to extend into the wrapper padding
        guard let hostingView = self.hostingView,
              let layer = hostingView.layer else {
            makeKeyAndOrderFront(nil)
            alphaValue = 1
            return
        }

        layer.masksToBounds = false

        let scale = Constants.Animation.showScale

        // Save original values for restoration after animation
        let originalAnchor = layer.anchorPoint
        let originalPosition = layer.position
        let bounds = layer.bounds

        // Bottom-center anchor (0.5, 0.0 in macOS coordinates - Y grows upward)
        let bottomCenterAnchor = CGPoint(x: 0.5, y: 0.0)

        // Correct position so view doesn't shift when changing anchorPoint
        let correctedPosition = CGPoint(
            x: layer.frame.origin.x + bottomCenterAnchor.x * bounds.width,
            y: layer.frame.origin.y + bottomCenterAnchor.y * bounds.height
        )

        // Set anchorPoint and initial scale without animation
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.anchorPoint = bottomCenterAnchor
        layer.position = correctedPosition
        layer.transform = CATransform3DMakeScale(scale, scale, 1.0)
        CATransaction.commit()

        // Show window
        makeKeyAndOrderFront(nil)

        // Fade animation
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animator().alphaValue = 1
        }

        // Spring scale animation - anchorPoint handles the grow-from-bottom
        let spring = CASpringAnimation(keyPath: "transform")
        spring.fromValue = CATransform3DMakeScale(scale, scale, 1.0)
        spring.toValue = CATransform3DIdentity
        spring.damping = 15
        spring.stiffness = 300
        spring.duration = spring.settlingDuration
        layer.add(spring, forKey: "scaleIn")
        layer.transform = CATransform3DIdentity

        // Restore original anchorPoint after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + spring.settlingDuration + 0.05) {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.anchorPoint = originalAnchor
            layer.position = originalPosition
            layer.transform = CATransform3DIdentity
            CATransaction.commit()
        }
    }

    /// Hide the panel with fade + scale animation
    func hideAnimated(completion: (() -> Void)? = nil) {
        // Get hostingView for scale animation
        guard let hostingView = self.hostingView,
              let layer = hostingView.layer else {
            orderOut(nil)
            completion?()
            return
        }

        let scale = Constants.Animation.showScale

        // Save original values
        let originalAnchor = layer.anchorPoint
        let originalPosition = layer.position
        let bounds = layer.bounds

        // Bottom-center anchor (0.5, 0.0 in macOS coordinates)
        let bottomCenterAnchor = CGPoint(x: 0.5, y: 0.0)

        // Correct position
        let correctedPosition = CGPoint(
            x: layer.frame.origin.x + bottomCenterAnchor.x * bounds.width,
            y: layer.frame.origin.y + bottomCenterAnchor.y * bounds.height
        )

        // Set anchorPoint without animation
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.anchorPoint = bottomCenterAnchor
        layer.position = correctedPosition
        CATransaction.commit()

        // Fade animation
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Constants.Animation.hideDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            animator().alphaValue = 0
        }

        // Scale down animation
        let anim = CABasicAnimation(keyPath: "transform")
        anim.toValue = CATransform3DMakeScale(scale, scale, 1.0)
        anim.duration = Constants.Animation.hideDuration
        anim.timingFunction = CAMediaTimingFunction(name: .easeIn)
        layer.add(anim, forKey: "scaleOut")

        // Completion after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animation.hideDuration) { [weak self] in
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.anchorPoint = originalAnchor
            layer.position = originalPosition
            layer.transform = CATransform3DIdentity
            CATransaction.commit()

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
