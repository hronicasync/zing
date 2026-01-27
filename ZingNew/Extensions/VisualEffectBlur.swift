//
//  VisualEffectBlur.swift
//  ZingNew
//
//  Glass blur effect for the translator panel background.
//

import SwiftUI
import AppKit

/// NSVisualEffectView wrapper for SwiftUI to create glass blur effect
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var state: NSVisualEffectView.State
    var cornerRadius: CGFloat

    init(
        material: NSVisualEffectView.Material = .popover,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        state: NSVisualEffectView.State = .active,
        cornerRadius: CGFloat = 0
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.state = state
        self.cornerRadius = cornerRadius
    }

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        view.wantsLayer = true
        view.layer?.cornerRadius = cornerRadius
        view.layer?.masksToBounds = true
        view.layer?.cornerCurve = .continuous
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
        nsView.layer?.cornerRadius = cornerRadius
    }
}

/// View modifier for applying glass blur background
struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    VisualEffectBlur(
                        material: .popover,
                        blendingMode: .behindWindow,
                        state: .active,
                        cornerRadius: cornerRadius
                    )
                    Constants.Colors.panelOverlay
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
    }
}

extension View {
    /// Apply glass blur background with optional corner radius
    func glassBackground(cornerRadius: CGFloat = Constants.UI.panelCornerRadius) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }
}
