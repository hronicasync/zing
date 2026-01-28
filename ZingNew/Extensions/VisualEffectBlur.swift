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

        // Corner radius через layer вместо SwiftUI clipShape
        // Это позволяет spring анимации выходить за bounds без обрезки
        if cornerRadius > 0 {
            view.wantsLayer = true
            view.layer?.cornerRadius = cornerRadius
            view.layer?.cornerCurve = .continuous
            view.layer?.masksToBounds = true  // Только для blur background
        }

        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state

        // Обновить corner radius при изменении
        if cornerRadius > 0 {
            nsView.layer?.cornerRadius = cornerRadius
        }
    }
}

/// View modifier for applying glass blur background
struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Corner radius применяется через NSVisualEffectView layer
                    // Это позволяет spring анимации выходить за bounds без обрезки
                    VisualEffectBlur(
                        material: .popover,
                        blendingMode: .behindWindow,
                        state: .active,
                        cornerRadius: cornerRadius
                    )
                    // Overlay клиппим отдельно
                    Constants.Colors.panelOverlay
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
                // НЕ применяем clipShape к ZStack - это вызывало обрезку при spring overshoot
            )
    }
}

extension View {
    /// Apply glass blur background with optional corner radius
    func glassBackground(cornerRadius: CGFloat = Constants.UI.panelCornerRadius) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }
}
