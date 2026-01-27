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
                    .padding(.leading, 5)
                    .padding(.top, 8)
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: TextHeightPreferenceKey.self,
                                value: geometry.size.height
                            )
                        }
                    )

                // Placeholder
                if text.isEmpty {
                    Text(placeholder)
                        .font(Constants.Typography.inputFont)
                        .foregroundColor(Constants.Colors.secondaryText)
                        .padding(.leading, 5)
                        .padding(.top, 8)
                }

                // Actual TextEditor
                TextEditor(text: $text)
                    .font(Constants.Typography.inputFont)
                    .foregroundColor(Constants.Colors.primaryText)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
            }

            Spacer(minLength: 0)
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

/// Read-only output field for translation with copy button
struct OutputField: View {
    let text: String
    let onCopy: () -> Void
    @Binding var isCopied: Bool

    var body: some View {
        HStack(alignment: .top, spacing: Constants.UI.inputSpacing) {
            if text.isEmpty {
                Text(" ")
                    .font(Constants.Typography.inputFont)
                    .foregroundColor(Constants.Colors.secondaryText)
            } else {
                Text(text)
                    .font(Constants.Typography.inputFont)
                    .foregroundColor(Constants.Colors.primaryText)
                    .textSelection(.enabled)
            }

            Spacer(minLength: 0)

            // Always show copy button, but disable when empty
            CopyButton(action: onCopy, isCopied: $isCopied)
                .disabled(text.isEmpty)
                .opacity(text.isEmpty ? 0.3 : 1.0)
        }
        .padding(Constants.UI.inputPadding)
        .frame(minHeight: Constants.UI.inputMinHeight)
        .background(Constants.Colors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.UI.inputCornerRadius))
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
