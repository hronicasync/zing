# Changelog

All notable changes to Zing will be documented in this file.

## [0.2.0] - 2026-01-27

### Added
- **FloatingPanel** — NSPanel wrapper для overlay окна переводчика
  - Borderless, transparent background
  - Glass blur effect (NSVisualEffectView)
  - Floating window level
  - Works across all spaces and fullscreen apps

- **TranslatorView** — главный UI переводчика (dark theme)
  - Top bar с language selectors и swap button
  - Source input field с placeholder
  - Output field с copy button
  - Hotkey hint (⌘ + C to copy)

- **UI Components** (matching Figma design):
  - `LanguageSelector` — pill-shaped language picker с chevron
  - `IconButton` — filled button с hover/press states
  - `CopyButton` — copy button с checkmark animation
  - `CloseButton` — close button (xmark)
  - `InputField` — source/output text fields
  - `HotkeyHint` — keyboard shortcut display

- **TranslatorViewModel** — state management
  - Mock translation с 0.3s delay
  - Language swap functionality
  - Copy to clipboard

- **VisualEffectBlur** — NSVisualEffectView wrapper для glass blur

### Changed
- **Constants.swift** — обновлены UI константы из Figma:
  - Panel: 378x224px, corner radius 24px, padding 20px
  - Input fields: corner radius 12px, padding 12px
  - Typography: SF Pro Display (14px, 17px, 13px)
  - Colors: dark theme с opacity-based backgrounds

- **ZingNewApp.swift** — интеграция с FloatingPanel через AppDelegate

### Design Specs (from Figma)
- Panel size: 378 x 224 px (adaptive height)
- Corner radius: 24px
- Glass blur + black 10% overlay
- Shadow: y=8, blur=12, black 25%
- SF Symbols: xmark, arrow.left.arrow.right, doc.on.doc, checkmark, chevron.down

---

## [0.1.0] - 2026-01-27

### Added
- **Project scaffold** — базовая структура Xcode проекта
- **Folder structure** — создана архитектура MVVM:
  - `Models/` — модели данных
  - `ViewModels/` — view models
  - `Views/` — SwiftUI views
  - `Components/` — переиспользуемые UI-компоненты
  - `Services/` — сервисы (Translation, Clipboard)
  - `Panels/` — NSPanel wrapper для overlay
  - `Extensions/` — Swift extensions
- **Constants.swift** — конфигурация глобального хоткея (Shift+Option+T)
- **KeyboardShortcuts** — SPM зависимость для глобальных хоткеев
- **LSUIElement** — приложение работает как agent (без иконки в Dock)
- **Bundle ID** — `com.zing.translator`
- **Documentation** — README.md, ProjectOverview.md, Skills.md
- **.gitignore** — стандартный для Xcode/Swift проектов

### Technical
- macOS 14.0+ (Sonoma)
- Swift 5.9+
- Xcode 26.2

### Repository
- GitHub: https://github.com/hronicasync/zing
