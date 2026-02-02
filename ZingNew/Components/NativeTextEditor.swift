//
//  NativeTextEditor.swift
//  ZingNew
//
//  NSTextView wrapper for precise text alignment control.
//

import SwiftUI
import AppKit

/// NSTextView wrapper that provides full control over text insets
struct NativeTextEditor: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    var font: NSFont = .systemFont(ofSize: 17)
    var textColor: NSColor = .white
    var placeholderColor: NSColor = .white.withAlphaComponent(0.7)
    var padding: CGFloat = 12
    var onHeightChange: ((CGFloat) -> Void)?
    var onCopyWithoutSelection: (() -> Void)?
    var onClearInput: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false

        let textView = PlaceholderTextView()
        textView.isRichText = false
        textView.font = font
        textView.textColor = textColor
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainerInset = NSSize(width: padding, height: padding)
        textView.textContainer?.lineFragmentPadding = 0
        textView.textContainer?.widthTracksTextView = true

        // Placeholder setup
        textView.placeholderString = placeholder
        textView.placeholderColor = placeholderColor
        textView.placeholderFont = font

        // Focus ring
        textView.focusRingType = .none

        // Keyboard shortcut callbacks
        textView.onCopyWithoutSelection = onCopyWithoutSelection
        textView.onClearInput = onClearInput

        textView.delegate = context.coordinator

        scrollView.documentView = textView

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? PlaceholderTextView else { return }

        if textView.string != text {
            textView.string = text
        }
        textView.placeholderString = placeholder
        textView.font = font
        textView.textColor = textColor
        textView.textContainerInset = NSSize(width: padding, height: padding)
        textView.onCopyWithoutSelection = onCopyWithoutSelection
        textView.onClearInput = onClearInput

        // Calculate and report height
        DispatchQueue.main.async {
            let height = textView.contentHeight + (padding * 2)
            onHeightChange?(height)
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: NativeTextEditor

        init(_ parent: NativeTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? PlaceholderTextView else { return }
            parent.text = textView.string

            // Notify height change
            let height = textView.contentHeight + (parent.padding * 2)
            parent.onHeightChange?(height)
        }
    }
}

// MARK: - PlaceholderTextView

/// Custom NSTextView with placeholder support
class PlaceholderTextView: NSTextView {
    var placeholderString: String = "" {
        didSet { needsDisplay = true }
    }
    var placeholderColor: NSColor = .secondaryLabelColor
    var placeholderFont: NSFont = .systemFont(ofSize: 17)
    var onCopyWithoutSelection: (() -> Void)?
    var onClearInput: (() -> Void)?

    // Key codes (layout-independent)
    private static let keyCodeC: UInt16 = 8
    private static let keyCodeX: UInt16 = 7

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // Cmd+C when no selection → copy translation instead
        // Uses keyCode for layout-independent detection (works on any keyboard layout)
        if flags == .command && event.keyCode == Self.keyCodeC {
            if selectedRange().length == 0 {
                onCopyWithoutSelection?()
                return true
            }
        }

        // Opt+X → clear input (layout-independent)
        if flags == .option && event.keyCode == Self.keyCodeX {
            onClearInput?()
            return true
        }

        return super.performKeyEquivalent(with: event)
    }

    var contentHeight: CGFloat {
        guard let layoutManager = layoutManager,
              let textContainer = textContainer else { return 0 }
        layoutManager.ensureLayout(for: textContainer)
        return layoutManager.usedRect(for: textContainer).height
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Draw placeholder when empty and not first responder
        if string.isEmpty && window?.firstResponder != self {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: placeholderFont,
                .foregroundColor: placeholderColor
            ]
            let inset = textContainerInset
            let rect = NSRect(
                x: inset.width,
                y: inset.height,
                width: bounds.width - (inset.width * 2),
                height: bounds.height - (inset.height * 2)
            )
            placeholderString.draw(in: rect, withAttributes: attrs)
        }
    }

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        needsDisplay = true
        return result
    }

    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        needsDisplay = true
        return result
    }
}
