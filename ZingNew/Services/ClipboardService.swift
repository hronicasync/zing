import AppKit

/// Service for clipboard operations
final class ClipboardService {
    static let shared = ClipboardService()
    private let pasteboard = NSPasteboard.general

    private init() {}

    /// Copy text to clipboard
    func copy(_ text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    /// Paste text from clipboard
    func paste() -> String? {
        return pasteboard.string(forType: .string)
    }
}
