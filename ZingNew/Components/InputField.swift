//
//  InputField.swift
//  ZingNew
//
//  Text input/output field with copy button, matching Figma design.
//

import SwiftUI

/// Editable input field for source text
struct SourceInputField: View {
    @Binding var text: String
    var placeholder: String = "Введите текст для перевода..."

    var body: some View {
        HStack(alignment: .top, spacing: Constants.UI.inputSpacing) {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(Constants.Typography.inputFont)
                        .foregroundColor(Constants.Colors.secondaryText)
                        .padding(.top, 0)
                }

                TextEditor(text: $text)
                    .font(Constants.Typography.inputFont)
                    .foregroundColor(Constants.Colors.primaryText)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .frame(minHeight: 20)
            }

            Spacer(minLength: 0)
        }
        .padding(Constants.UI.inputPadding)
        .frame(minHeight: Constants.UI.inputMinHeight)
        .background(Constants.Colors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.UI.inputCornerRadius))
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
