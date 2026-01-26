# Changelog

All notable changes to Zing will be documented in this file.

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
