//
//  TranslatorView.swift
//  ZingNew
//
//  Main translator panel UI composing all components.
//

import SwiftUI

struct TranslatorView: View {
    @ObservedObject var viewModel: TranslatorViewModel

    var body: some View {
        VStack(spacing: Constants.UI.panelItemSpacing) {
            // Top bar: Language pair + Close button
            topBar

            // Input/Output fields with loading and error states
            VStack(spacing: Constants.UI.inputSpacing) {
                SourceInputField(text: $viewModel.sourceText)

                // Output field with ProgressView overlay
                ZStack {
                    OutputField(
                        text: viewModel.translatedText,
                        onCopy: viewModel.copyTranslation,
                        isCopied: $viewModel.isCopied
                    )

                    if viewModel.isTranslating {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(0.7)
                                .tint(Constants.Colors.secondaryText)
                            Spacer()
                        }
                    }
                }

                // Error message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(Constants.Typography.hintFont)
                        .foregroundColor(.red.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            // Bottom hint
            CopyHotkeyHint()
        }
        .padding(Constants.UI.panelPadding)
        .frame(width: Constants.UI.panelWidth)
        .glassBackground()
        .shadow(
            color: Constants.Shadow.color,
            radius: Constants.Shadow.radius,
            y: Constants.Shadow.y
        )
        // Escape key handler
        .background(
            Button("") {
                FloatingPanelManager.shared.hidePanel()
            }
            .keyboardShortcut(.escape, modifiers: [])
            .hidden()
        )
    }

    private var topBar: some View {
        HStack(spacing: Constants.UI.topBarSpacing) {
            // Spacer for centering the language pair
            Spacer()
                .frame(width: Constants.UI.closeIconSize)

            Spacer()

            LanguagePair(
                sourceLanguage: viewModel.sourceLang.displayName,
                targetLanguage: viewModel.targetLang.displayName,
                onSourceTap: {
                    // Language selection (placeholder for future)
                },
                onTargetTap: {
                    // Language selection (placeholder for future)
                },
                onSwap: viewModel.swapLanguages
            )

            Spacer()

            CloseButton {
                FloatingPanelManager.shared.hidePanel()
            }
        }
        .frame(height: Constants.UI.topBarHeight)
    }
}

#Preview {
    TranslatorView(viewModel: TranslatorViewModel())
        .frame(width: 400, height: 300)
        .background(Color.gray)
}
