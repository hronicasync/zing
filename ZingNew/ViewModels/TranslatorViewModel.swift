//
//  TranslatorViewModel.swift
//  ZingNew
//
//  State management for the translator panel with mock translation.
//

import SwiftUI
import Combine
import AppKit

@MainActor
class TranslatorViewModel: ObservableObject {
    @Published var sourceText: String = ""
    @Published var translatedText: String = ""
    @Published var sourceLang: String = "Russian"
    @Published var targetLang: String = "English"
    @Published var isTranslating: Bool = false
    @Published var isCopied: Bool = false

    private var translateTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Auto-translate when source text changes (with debounce)
        $sourceText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.mockTranslate()
            }
            .store(in: &cancellables)
    }

    /// Mock translation with simulated delay
    func mockTranslate() {
        // Cancel any pending translation
        translateTask?.cancel()

        guard !sourceText.isEmpty else {
            translatedText = ""
            isTranslating = false
            return
        }

        isTranslating = true

        translateTask = Task {
            // Simulate network delay
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s

            guard !Task.isCancelled else { return }

            // Mock translation: just reverse the text direction indicator
            let mockResult: String
            if sourceLang == "Russian" {
                mockResult = "Mock: \(sourceText) → EN"
            } else {
                mockResult = "Mock: \(sourceText) → RU"
            }

            translatedText = mockResult
            isTranslating = false
        }
    }

    /// Swap source and target languages (and their texts)
    func swapLanguages() {
        withAnimation(.easeInOut(duration: 0.2)) {
            swap(&sourceLang, &targetLang)
            swap(&sourceText, &translatedText)
        }
    }

    /// Copy translation to clipboard
    func copyTranslation() {
        guard !translatedText.isEmpty else { return }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(translatedText, forType: .string)

        // Show copied state
        withAnimation(.easeInOut(duration: 0.2)) {
            isCopied = true
        }

        // Reset after delay
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5s
            withAnimation(.easeInOut(duration: 0.2)) {
                isCopied = false
            }
        }
    }

    /// Close the application
    func closeApp() {
        NSApp.terminate(nil)
    }
}
