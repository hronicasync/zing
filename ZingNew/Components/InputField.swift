//
//  InputField.swift
//  ZingNew
//
//  Text input/output field with copy button, matching Figma design.
//

import SwiftUI

// MARK: - Preference Key for dynamic height

private struct TextHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

/// Editable input field for source text with dynamic height
struct SourceInputField: View {
    @Binding var text: String
    var placeholder: String = "Введите текст для перевода..."
    var onCopyWithoutSelection: (() -> Void)?

    @State private var textHeight: CGFloat = Constants.UI.inputMinHeight

    private var calculatedHeight: CGFloat {
        min(max(textHeight, Constants.UI.inputMinHeight), Constants.UI.inputMaxHeight)
    }

    var body: some View {
        NativeTextEditor(
            text: $text,
            placeholder: placeholder,
            font: .systemFont(ofSize: 17),
            textColor: .white,
            placeholderColor: .white.withAlphaComponent(0.7),
            padding: Constants.UI.inputPadding,
            onHeightChange: { height in
                textHeight = height
            },
            onCopyWithoutSelection: onCopyWithoutSelection
        )
        .frame(height: calculatedHeight)
        .background(Constants.Colors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.UI.inputCornerRadius))
    }
}

/// Read-only output field for translation with copy button and dynamic height
struct OutputField: View {
    let text: String
    let onCopy: () -> Void
    @Binding var isCopied: Bool

    @State private var textHeight: CGFloat = Constants.UI.inputMinHeight

    private var calculatedHeight: CGFloat {
        min(max(textHeight, Constants.UI.inputMinHeight), Constants.UI.inputMaxHeight)
    }

    var body: some View {
        HStack(alignment: .top, spacing: Constants.UI.inputSpacing) {
            ZStack(alignment: .topLeading) {
                // Hidden text for height calculation
                Text(text.isEmpty ? " " : text)
                    .font(Constants.Typography.inputFont)
                    .foregroundColor(.clear)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: TextHeightPreferenceKey.self,
                                value: geometry.size.height
                            )
                        }
                    )

                // Visible text or placeholder
                if text.isEmpty {
                    Text("Перевод")
                        .font(Constants.Typography.inputFont)
                        .foregroundColor(Constants.Colors.secondaryText)
                } else {
                    Text(text)
                        .font(Constants.Typography.inputFont)
                        .foregroundColor(Constants.Colors.primaryText)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            // Always show copy button, but disable when empty
            CopyButton(action: onCopy, isCopied: $isCopied)
                .disabled(text.isEmpty)
                .opacity(text.isEmpty ? 0.3 : 1.0)
        }
        .padding(Constants.UI.inputPadding)
        .frame(height: calculatedHeight)
        .background(Constants.Colors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.UI.inputCornerRadius))
        .onPreferenceChange(TextHeightPreferenceKey.self) { height in
            textHeight = height + Constants.UI.inputPadding * 2
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        SourceInputField(text: .constant(""))
        SourceInputField(text: .constant("привет, я Зинг!"))
        OutputField(text: "", onCopy: {}, isCopied: .constant(false))
        OutputField(text: "Hello, I'm Zing!", onCopy: {}, isCopied: .constant(false))
        OutputField(text: "Hello, I'm Zing!", onCopy: {}, isCopied: .constant(true))
    }
    .padding(20)
    .frame(width: 378)
    .background(Color.gray.opacity(0.3))
}
