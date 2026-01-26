//
//  IconButton.swift
//  ZingNew
//
//  Filled icon button with hover/press states matching Figma design.
//

import SwiftUI

struct IconButton: View {
    let icon: String
    let action: () -> Void
    var size: CGSize = Constants.UI.swapButtonSize

    @State private var isHovered = false
    @State private var isPressed = false

    private var backgroundColor: Color {
        if isPressed {
            return Constants.Colors.buttonPressed
        } else if isHovered {
            return Constants.Colors.buttonHover
        }
        return Constants.Colors.buttonDefault
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(Constants.Typography.iconFont)
                .foregroundColor(Constants.Colors.primaryText)
                .frame(width: size.width, height: size.height)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: Constants.UI.buttonCornerRadius))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

/// Close button variant (no background, just icon)
struct CloseButton: View {
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: Constants.UI.closeIconSize, weight: .semibold))
                .foregroundColor(Constants.Colors.primaryText.opacity(isHovered ? 1.0 : 0.7))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

/// Copy button with checkmark animation on success
struct CopyButton: View {
    let action: () -> Void
    @Binding var isCopied: Bool

    @State private var isHovered = false

    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                .font(.system(size: Constants.UI.iconSize, weight: .medium))
                .foregroundColor(isCopied ? .green : Constants.Colors.primaryText.opacity(isHovered ? 1.0 : 0.6))
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        IconButton(icon: "arrow.left.arrow.right") {}
        CloseButton {}
        CopyButton(action: {}, isCopied: .constant(false))
        CopyButton(action: {}, isCopied: .constant(true))
    }
    .padding(40)
    .background(Color.gray.opacity(0.3))
}
