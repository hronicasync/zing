//
//  Constants.swift
//  ZingNew
//
//  Created for Zing overlay translator.
//

import Foundation
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

    /// UI Constants
    enum UI {
        static let overlayWidth: CGFloat = 400
        static let overlayHeight: CGFloat = 200
        static let cornerRadius: CGFloat = 16
        static let blurRadius: CGFloat = 20
    }
}
