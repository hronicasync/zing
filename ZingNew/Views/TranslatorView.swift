//
//  TranslatorView.swift
//  ZingNew
//
//  Main translator panel UI composing all components.
//

import SwiftUI

struct TranslatorView: View {
    @StateObject private var viewModel = TranslatorViewModel()

    var body: some View {
        VStack(spacing: Constants.UI.panelItemSpacing) {
            // Top bar: Language pair + Close button
            topBar

            // Input/Output fields
            VStack(spacing: Constants.UI.inputSpacing) {
                SourceInputField(text: $viewModel.sourceText)

                OutputField(
                    text: viewModel.translatedText,
                    onCopy: viewModel.copyTranslation,
                    isCopied: $viewModel.isCopied
                )
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
    }

    private var topBar: some View {
        HStack(spacing: Constants.UI.topBarSpacing) {
            // Spacer for centering the language pair
            Spacer()
                .frame(width: Constants.UI.closeIconSize)

            Spacer()

            LanguagePair(
                sourceLanguage: viewModel.sourceLang,
                targetLanguage: viewModel.targetLang,
                onSourceTap: {
                    // Language selection (placeholder for future)
                },
                onTargetTap: {
                    // Language selection (placeholder for future)
                },
                onSwap: viewModel.swapLanguages
            )

            Spacer()

            CloseButton(action: viewModel.closeApp)
        }
        .frame(height: Constants.UI.topBarHeight)
    }
}

#Preview {
    TranslatorView()
        .frame(width: 400, height: 300)
        .background(Color.gray)
}
