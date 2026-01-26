//
//  LanguageSelector.swift
//  ZingNew
//
//  Pill-shaped language picker with chevron, matching Figma design.
//

import SwiftUI

struct LanguageSelector: View {
    let language: String
    let action: () -> Void

    @State private var isHovered = false
    @State private var isPressed = false

    private var backgroundColor: Color {
        if isPressed {
            return Constants.Colors.languagePressed
        } else if isHovered {
            return Constants.Colors.languageHover
        }
        return .clear
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 2) {
                Text(language)
                    .font(Constants.Typography.languageFont)
                    .foregroundColor(Constants.Colors.primaryText)

                Image(systemName: "chevron.down")
                    .font(Constants.Typography.chevronFont)
                    .foregroundColor(Constants.Colors.primaryText)
            }
            .padding(.horizontal, Constants.UI.languageSelectorPaddingH)
            .padding(.vertical, Constants.UI.languageSelectorPaddingV)
            .frame(height: Constants.UI.languageSelectorHeight)
            .background(backgroundColor)
            .clipShape(Capsule())
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

/// Language pair component: Source [Swap] Target
struct LanguagePair: View {
    let sourceLanguage: String
    let targetLanguage: String
    let onSourceTap: () -> Void
    let onTargetTap: () -> Void
    let onSwap: () -> Void

    var body: some View {
        HStack(spacing: Constants.UI.languagePairSpacing) {
            LanguageSelector(language: sourceLanguage, action: onSourceTap)

            IconButton(icon: "arrow.left.arrow.right", action: onSwap)

            LanguageSelector(language: targetLanguage, action: onTargetTap)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        LanguageSelector(language: "Russian") {}
        LanguagePair(
            sourceLanguage: "Russian",
            targetLanguage: "English",
            onSourceTap: {},
            onTargetTap: {},
            onSwap: {}
        )
    }
    .padding(40)
    .background(Color.gray.opacity(0.3))
}
