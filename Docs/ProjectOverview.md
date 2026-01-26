# Zing — Project Overview

## Архитектура

Zing использует MVVM архитектуру с четким разделением на слои:

```
ZingNew/
├── ZingNewApp.swift          # Entry point + AppDelegate
├── Constants.swift           # UI, Animation, Translation constants
├── Services/
│   ├── TranslationService.swift   # Apple Translation API wrapper
│   └── ClipboardService.swift     # NSPasteboard wrapper
├── ViewModels/
│   └── TranslatorViewModel.swift  # Business logic + state
├── Views/
│   └── TranslatorView.swift       # Main UI composition
├── Components/
│   ├── InputField.swift           # Source/Output fields
│   ├── LanguageSelector.swift     # Language picker
│   ├── IconButton.swift           # Swap, Close, Copy buttons
│   └── HotkeyHint.swift           # Keyboard shortcut display
├── Panels/
│   └── FloatingPanel.swift        # NSPanel + FloatingPanelManager
└── Extensions/
    └── VisualEffectBlur.swift     # NSVisualEffectView wrapper
```

## Компоненты

### App Entry Point
- `ZingNewApp.swift` — точка входа SwiftUI App
- `AppDelegate` — управляет:
  - Регистрацией глобального хоткея (KeyboardShortcuts)
  - Иконкой в Menu Bar (NSStatusItem)
  - Жизненным циклом приложения

### Overlay Panel
- `FloatingPanel` — NSPanel subclass с настройками:
  - `.borderless`, `.nonactivatingPanel` — без рамки, не крадет фокус
  - `.floating` level — поверх обычных окон
  - `.canJoinAllSpaces`, `.fullScreenAuxiliary` — работает на всех Spaces и поверх fullscreen
  - `hidesOnDeactivate = false` — не скрывается при потере фокуса
  - Анимации показа/скрытия через NSAnimationContext

- `FloatingPanelManager` — singleton для управления панелью:
  - Создает ViewModel один раз и переиспользует
  - Методы `showPanel()`, `hidePanel()`, `togglePanel()`

### Translation Service
- `TranslationService` — обертка над Apple Translation API (macOS 15+)
  - Использует `TranslationSession(installedSource:target:)`
  - Поддерживает только Russian ↔ English (MVP)
  - Async/await интерфейс

### UI Components
- `TranslatorView` — композиция всех UI элементов
- `SourceInputField` — TextEditor для ввода текста
- `OutputField` — Text + CopyButton для результата
- `LanguagePair` — два LanguageSelector + SwapButton
- `CopyButton` — копирование с анимацией checkmark

## Технические детали

### Agent App (LSUIElement)
Приложение настроено как UI Element (LSUIElement = YES):
- Нет иконки в Dock
- Работает через глобальный хоткей Shift+Option+T
- Иконка в Menu Bar для доступа

### Глобальный хоткей
Используется библиотека KeyboardShortcuts:
```swift
KeyboardShortcuts.setShortcut(.init(.t, modifiers: [.shift, .option]), for: .toggleTranslator)
KeyboardShortcuts.onKeyUp(for: .toggleTranslator) { ... }
```

### Apple Translation API
Требует macOS 15.0+ (Sequoia):
```swift
@available(macOS 15.0, *)
let session = TranslationSession(installedSource: source.locale, target: target.locale)
let response = try await session.translate(text)
```

### State Management
- `TranslatorViewModel` создается один раз в `FloatingPanelManager`
- Передается в `TranslatorView` через `@ObservedObject`
- Состояние сохраняется между hide/show панели
- Auto-translate с debounce 0.5s через Combine

### Menu Bar
- `NSStatusItem` с SF Symbol `character.bubble`
- Меню: "Open Zing (⇧⌥T)" и "Quit (⌘Q)"

## Зависимости

- **KeyboardShortcuts** (SPM) — глобальные хоткеи
- **Translation** (Apple) — машинный перевод (macOS 15+)
- **SwiftUI** — UI framework
- **AppKit** — NSPanel, NSStatusItem, NSPasteboard
- **Combine** — реактивное программирование
