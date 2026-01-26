# Zing

macOS overlay-переводчик с глобальным хоткеем.

## Фичи
- Hotkey: Shift + Option + T
- Overlay поверх всех окон (включая full-screen приложения)
- Перевод через Apple Translation API (RU ↔ EN)
- Минималистичный "liquid glass" дизайн

## Stack
- Swift 5.9+
- SwiftUI + AppKit
- macOS 14.0+

## Зависимости
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) — глобальные хоткеи

## Структура проекта
```
ZingNew/
├── ZingNewApp.swift    # @main entry point
├── Constants.swift     # Константы (хоткеи, настройки)
├── Models/             # Модели данных
├── ViewModels/         # MVVM ViewModels
├── Views/              # SwiftUI Views
├── Components/         # Переиспользуемые UI-компоненты
├── Services/           # Сервисы (Translation, Clipboard)
├── Panels/             # NSPanel wrapper для overlay
├── Extensions/         # Swift extensions
└── Assets.xcassets     # Ассеты (иконки, цвета)
```

## Сборка
1. Откройте `ZingNew.xcodeproj` в Xcode
2. Дождитесь загрузки SPM зависимостей
3. Build & Run (⌘R)

## Дизайн
Figma: https://www.figma.com/design/ucCm9JZJsc0z0JRdYFU1rX/Zing
