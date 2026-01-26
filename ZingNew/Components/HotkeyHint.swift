//
//  HotkeyHint.swift
//  ZingNew
//
//  Keyboard shortcut hint display, matching Figma design.
//

import SwiftUI

/// Single hotkey badge (e.g., ⌘, C)
struct HotkeyBadge: View {
    let key: String

    var body: some View {
        Text(key)
            .font(Constants.Typography.hotkeyFont)
            .foregroundColor(Constants.Colors.primaryText)
            .frame(minWidth: 24, minHeight: Constants.UI.hotkeyBadgeHeight)
            .padding(.horizontal, 6)
            .background(Constants.Colors.hotkeyBadge)
            .clipShape(RoundedRectangle(cornerRadius: Constants.UI.hotkeyBadgeCornerRadius))
    }
}

/// Hotkey hint with badges and description text
struct HotkeyHint: View {
    let keys: [String]
    let description: String

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(keys.enumerated()), id: \.offset) { index, key in
                HotkeyBadge(key: key)

                if index < keys.count - 1 {
                    Text("+")
                        .font(Constants.Typography.hintFont)
                        .foregroundColor(Constants.Colors.primaryText)
                }
            }

            Text(description)
                .font(Constants.Typography.hintFont)
                .foregroundColor(Constants.Colors.primaryText)
        }
    }
}

/// Pre-configured hint for copy action
struct CopyHotkeyHint: View {
    var body: some View {
        HotkeyHint(keys: ["⌘", "C"], description: "to copy translation")
    }
}

#Preview {
    VStack(spacing: 20) {
        HotkeyBadge(key: "⌘")
        HotkeyBadge(key: "C")
        HotkeyHint(keys: ["⌘", "C"], description: "to copy translation")
        CopyHotkeyHint()
    }
    .padding(40)
    .background(Color.gray.opacity(0.3))
}
