//
//  Constants.swift
//  ZingNew
//
//  Created for Zing overlay translator.
//

import Foundation
import SwiftUI
import KeyboardShortcuts

// MARK: - Keyboard Shortcuts

extension KeyboardShortcuts.Name {
    /// Global hotkey to toggle the translator overlay (Shift + Option + T)
    static let toggleTranslator = Self("toggleTranslator")
}

// MARK: - App Constants

enum Constants {
    /// Default hotkey display string
    static let defaultHotkey = "⇧⌥T" // Shift + Option + T

    /// Supported language pair
    static let sourceLanguage = "ru" // Russian
    static let targetLanguage = "en" // English

    /// UI Constants (from Figma)
    enum UI {
        // Panel dimensions
        static let panelWidth: CGFloat = 378
        static let panelMinHeight: CGFloat = 224
        static let panelCornerRadius: CGFloat = 24
        static let panelPadding: CGFloat = 20
        static let panelItemSpacing: CGFloat = 16

        // Input field
        static let inputMinHeight: CGFloat = 44
        static let inputCornerRadius: CGFloat = 12
        static let inputPadding: CGFloat = 12
        static let inputSpacing: CGFloat = 8

        // Buttons
        static let buttonCornerRadius: CGFloat = 10
        static let swapButtonSize: CGSize = CGSize(width: 32, height: 28)
        static let languageSelectorHeight: CGFloat = 28
        static let languageSelectorPaddingH: CGFloat = 8
        static let languageSelectorPaddingV: CGFloat = 4

        // Hotkey badge
        static let hotkeyBadgeCornerRadius: CGFloat = 4
        static let hotkeyBadgeHeight: CGFloat = 20

        // Top bar
        static let topBarHeight: CGFloat = 36
        static let topBarSpacing: CGFloat = 12
        static let languagePairSpacing: CGFloat = 4

        // Icon sizes
        static let iconSize: CGFloat = 20
        static let closeIconSize: CGFloat = 16
    }

    /// Colors (Dark Theme from Figma)
    enum Colors {
        // Backgrounds with opacity
        static let panelOverlay = Color.black.opacity(0.10)
        static let inputBackground = Color.black.opacity(0.25)
        static let buttonDefault = Color.black.opacity(0.35)
        static let buttonHover = Color.black.opacity(0.40)
        static let buttonPressed = Color.black.opacity(0.50)
        static let languageHover = Color.black.opacity(0.20)
        static let languagePressed = Color.black.opacity(0.30)
        static let hotkeyBadge = Color.black.opacity(0.15)

        // Text
        static let primaryText = Color.white
        static let secondaryText = Color.white.opacity(0.7)
    }

    /// Typography (SF Pro Display from Figma)
    enum Typography {
        static let languageFont = Font.system(size: 14, weight: .medium)
        static let inputFont = Font.system(size: 17, weight: .regular)
        static let hintFont = Font.system(size: 13, weight: .regular)
        static let hotkeyFont = Font.system(size: 15, weight: .regular)
        static let iconFont = Font.system(size: 16, weight: .semibold)
        static let chevronFont = Font.system(size: 10, weight: .semibold)
    }

    /// Shadow (from Figma)
    enum Shadow {
        static let color = Color.black.opacity(0.25)
        static let radius: CGFloat = 12
        static let y: CGFloat = 8
    }

    /// Animation timing
    enum Animation {
        static let showDuration: TimeInterval = 0.2
        static let hideDuration: TimeInterval = 0.12
        static let showScale: CGFloat = 0.95
    }

    /// Translation settings
    enum Translation {
        static let debounceInterval: TimeInterval = 0.5
    }
}
