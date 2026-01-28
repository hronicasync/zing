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
        contentView?.layer?.masksToBounds = false
        guard let layer = contentView?.layer else {
            makeKeyAndOrderFront(nil)
            alphaValue = 1
            return
        }

        let scale = Constants.Animation.showScale

        // Сохраняем оригинальные значения для восстановления после анимации
        let originalAnchor = layer.anchorPoint
        let originalPosition = layer.position
        let bounds = layer.bounds

        // Bottom-center anchor (0.5, 0.0 в macOS координатах - Y растёт вверх)
        let bottomCenterAnchor = CGPoint(x: 0.5, y: 0.0)

        // Корректируем position чтобы визуально view не сдвинулось при смене anchorPoint
        let correctedPosition = CGPoint(
            x: layer.frame.origin.x + bottomCenterAnchor.x * bounds.width,
            y: layer.frame.origin.y + bottomCenterAnchor.y * bounds.height
        )

        // Устанавливаем anchorPoint и начальный scale без анимации
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

        // Spring scale animation (теперь просто scale, без translate - anchorPoint делает всё сам)
        let spring = CASpringAnimation(keyPath: "transform")
        spring.fromValue = CATransform3DMakeScale(scale, scale, 1.0)
        spring.toValue = CATransform3DIdentity
        spring.damping = 15
        spring.stiffness = 300
        spring.duration = spring.settlingDuration
        layer.add(spring, forKey: "scaleIn")
        layer.transform = CATransform3DIdentity

        // Восстанавливаем оригинальный anchorPoint после завершения анимации
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
        guard let layer = contentView?.layer else {
            orderOut(nil)
            completion?()
            return
        }

        let scale = Constants.Animation.showScale

        // Сохраняем оригинальные значения
        let originalAnchor = layer.anchorPoint
        let originalPosition = layer.position
        let bounds = layer.bounds

        // Bottom-center anchor (0.5, 0.0 в macOS координатах)
        let bottomCenterAnchor = CGPoint(x: 0.5, y: 0.0)

        // Корректируем position
        let correctedPosition = CGPoint(
            x: layer.frame.origin.x + bottomCenterAnchor.x * bounds.width,
            y: layer.frame.origin.y + bottomCenterAnchor.y * bounds.height
        )

        // Устанавливаем anchorPoint без анимации
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
