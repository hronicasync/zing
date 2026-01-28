//
//  TranslatorViewModel.swift
//  ZingNew
//
//  State management for the translator panel with Apple Translation API.
//

import SwiftUI
import Combine
import AppKit

@MainActor
class TranslatorViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var sourceText: String = ""
    @Published var translatedText: String = ""
    @Published var isTranslating: Bool = false
    @Published var isCopied: Bool = false
    @Published var errorMessage: String?

    // Language selection using TranslationService types (macOS 15+)
    @Published var sourceLang: SupportedLanguage = .russian
    @Published var targetLang: SupportedLanguage = .english

    // MARK: - Language Enum (fallback for older macOS)

    enum SupportedLanguage: Equatable {
        case russian
        case english

        var displayName: String {
            switch self {
            case .russian: return "Russian"
            case .english: return "English"
            }
        }
    }

    // MARK: - Private Properties

    private var translateTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    private let clipboardService = ClipboardService.shared

    // MARK: - Initialization

    init() {
        setupTextObserver()
    }

    private func setupTextObserver() {
        $sourceText
            .debounce(for: .seconds(Constants.Translation.debounceInterval), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.performTranslation()
            }
            .store(in: &cancellables)
    }

    // MARK: - Translation

    func performTranslation() {
        // Cancel previous task
        translateTask?.cancel()

        // Clear error
        errorMessage = nil

        guard !sourceText.isEmpty else {
            translatedText = ""
            isTranslating = false
            return
        }

        isTranslating = true

        translateTask = Task {
            do {
                guard !Task.isCancelled else { return }

                if #available(macOS 15.0, *) {
                    let service = TranslationService.shared

                    // Convert local SupportedLanguage to TranslationService.SupportedLanguage
                    let source: TranslationService.SupportedLanguage = sourceLang == .russian ? .russian : .english
                    let target: TranslationService.SupportedLanguage = targetLang == .russian ? .russian : .english

                    let result = try await service.translate(
                        sourceText,
                        from: source,
                        to: target
                    )

                    guard !Task.isCancelled else { return }

                    translatedText = result
                    isTranslating = false
                } else {
                    // Fallback for older macOS
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    guard !Task.isCancelled else { return }
                    translatedText = "[Translation requires macOS 15+] \(sourceText)"
                    isTranslating = false
                }
            } catch {
                guard !Task.isCancelled else { return }

                errorMessage = error.localizedDescription
                isTranslating = false
            }
        }
    }

    // MARK: - Actions

    /// Swap source and target languages (and their texts)
    func swapLanguages() {
        withAnimation(.easeInOut(duration: 0.2)) {
            swap(&sourceLang, &targetLang)
            swap(&sourceText, &translatedText)
        }

        // Invalidate translation session since direction changed
        if #available(macOS 15.0, *) {
            TranslationService.shared.invalidateSession()
        }

        // Clear error on swap
        errorMessage = nil
    }

    /// Copy translation to clipboard
    func copyTranslation() {
        guard !translatedText.isEmpty else { return }

        clipboardService.copy(translatedText)

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

    /// Clear input field (Opt+X shortcut)
    func clearInput() {
        sourceText = ""
        // translatedText will be cleared automatically via debounced observer
    }

    /// Reset all state
    func reset() {
        sourceText = ""
        translatedText = ""
        errorMessage = nil
        isTranslating = false
        isCopied = false
    }
}
