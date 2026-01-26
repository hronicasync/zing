import Foundation
import Translation

/// Translation service using Apple Translation API (macOS 15+)
@available(macOS 15.0, *)
final class TranslationService {
    static let shared = TranslationService()

    private init() {}

    /// Supported language pair
    enum SupportedLanguage: Equatable {
        case russian
        case english

        var locale: Locale.Language {
            switch self {
            case .russian: return Locale.Language(identifier: "ru")
            case .english: return Locale.Language(identifier: "en")
            }
        }

        var displayName: String {
            switch self {
            case .russian: return "Russian"
            case .english: return "English"
            }
        }
    }

    /// Translate text from source to target language
    func translate(
        _ text: String,
        from source: SupportedLanguage,
        to target: SupportedLanguage
    ) async throws -> String {
        let session = TranslationSession(
            installedSource: source.locale,
            target: target.locale
        )

        let response = try await session.translate(text)
        return response.targetText
    }

    /// Invalidate session when language pair changes (kept for API compatibility)
    func invalidateSession() {
        // Session is created fresh each time
    }
}

/// Translation errors
enum TranslationError: LocalizedError {
    case sessionNotAvailable
    case languageNotSupported
    case translationFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .sessionNotAvailable:
            return "Translation service is not available"
        case .languageNotSupported:
            return "Language pair is not supported"
        case .translationFailed(let error):
            return "Translation failed: \(error.localizedDescription)"
        }
    }
}
