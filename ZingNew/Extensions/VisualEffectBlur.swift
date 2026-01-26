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

    init(
        material: NSVisualEffectView.Material = .hudWindow,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        state: NSVisualEffectView.State = .active
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.state = state
    }

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        view.wantsLayer = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
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
                        material: .hudWindow,
                        blendingMode: .behindWindow,
                        state: .active
                    )
                    Constants.Colors.panelOverlay
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            )
    }
}

extension View {
    /// Apply glass blur background with optional corner radius
    func glassBackground(cornerRadius: CGFloat = Constants.UI.panelCornerRadius) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }
}
