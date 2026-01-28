# Changelog

All notable changes to Zing will be documented in this file.

## [0.3.8] - 2026-01-28

### Fixed
- **Animation clipping (actual fix)** — панель больше не обрезается при spring overshoot
  - Корневая причина: NSPanel всегда обрезает контент по своим границам, независимо от `masksToBounds`
  - Решение: wrapper NSView с padding 20pt вокруг контента
  - Scale анимация теперь применяется к `hostingView` внутри wrapper'а
  - Spring overshoot расширяется в область padding без обрезки

### Technical
- `FloatingPanel.animationPadding = 20` — запас для spring overshoot
- `FloatingPanel.create()` — wrapper NSView вокруг NSHostingView
- `showAnimated()` / `hideAnimated()` — анимируют `hostingView.layer` вместо `contentView.layer`

---

## [0.3.7] - 2026-01-28

### Fixed
- **Animation clipping (real fix)** — панель больше не обрезается при spring overshoot
  - Corner radius теперь через `NSVisualEffectView.layer` вместо SwiftUI `clipShape`
  - Убран `clipShape` с внешнего ZStack в `GlassBackground`
  - Overlay клиппится отдельно

- **Animation anchor point** — анимация появления теперь корректно идёт от нижнего центра
  - Явная установка `anchorPoint = (0.5, 0.0)` (bottom-center в macOS координатах)
  - Корректировка `position` при смене anchorPoint чтобы view не сдвигалось
  - Восстановление оригинального anchorPoint после завершения анимации

### Technical
- `VisualEffectBlur.makeNSView()` — corner radius через `layer.cornerRadius` + `cornerCurve = .continuous`
- `GlassBackground` — убран внешний `clipShape`, overlay клиппится отдельно
- `FloatingPanel.showAnimated()` / `hideAnimated()` — переписаны с правильным anchorPoint

---

## [0.3.6] - 2026-01-28

### Fixed
- **Output field text wrapping** — текст в поле вывода теперь переносится на новые строки
  - Добавлен `.fixedSize(horizontal: false, vertical: true)` к Text элементам
  - Текст больше не уходит в одну строку

- **Animation clipping (final fix)** — панель больше не обрезается при spring анимации
  - Добавлен `contentView?.layer?.masksToBounds = false` в FloatingPanel

### Changed
- **Input max height doubled** — максимальная высота инпутов увеличена с 120pt до 240pt
  - Теперь помещается больше текста (~8-10 строк вместо 4-5)

### Technical
- `OutputField` — `.fixedSize()` для корректного переноса строк в SwiftUI Text
- `FloatingPanel.showAnimated()` — явное отключение masksToBounds на layer

---

## [0.3.5] - 2026-01-27

### Fixed
- **Text alignment in input fields** — replaced SwiftUI TextEditor with custom NSTextView wrapper (`NativeTextEditor`)
  - Full control over `textContainerInset` and `lineFragmentPadding`
  - Text now aligns perfectly with placeholder

- **Rectangle artifact around panel** — removed `masksToBounds = true` from `NSVisualEffectView` layer
  - Clipping now handled solely by SwiftUI `.clipShape()` in `GlassBackground`

- **Panel shadow not visible** — switched from SwiftUI shadow to native NSPanel shadow
  - Set `hasShadow = true` on FloatingPanel
  - Removed `.shadow()` modifier from TranslatorView

- **Animation clipping** — panel no longer clips during scale animation
  - Fixed by removing `masksToBounds` from VisualEffectBlur

- **Animation anchor point** — corrected center-bottom anchor point formula
  - Changed `+offsetY` to `-offsetY` in transform calculation
  - Panel now grows from bottom-center instead of top-center

- **Output field placeholder** — added "Перевод" placeholder text when output is empty

### Technical
- New file: `Components/NativeTextEditor.swift` — NSTextView wrapper with placeholder support
- `PlaceholderTextView` custom class with dynamic height calculation
- Simplified `VisualEffectBlur` — removed layer configuration (handled by SwiftUI)

---

## [0.3.4] - 2026-01-27

### Fixed
- **Panel positioning bug** — панель больше не "уезжает" после повторных показов
  - Убраны некорректные манипуляции с `anchorPoint` layer'а
  - Анимация из центра снизу теперь через `scale + translate` transform

- **Close button (X)** — крестик снова работает корректно

- **Animation origin** — анимация появления теперь из центра снизу (не из угла)
  - Используется комбинация scale + translateY вместо anchorPoint
  - Формула: `translateY = bounds.height * (1 - scale) / 2`

- **Input field layout** — исправлено выравнивание текста в полях ввода/вывода
  - Одинаковые padding'и для hidden text и TextEditor
  - Отключен scroll в TextEditor (`scrollDisabled`)

### Technical
- `FloatingPanel.showAnimated()` использует CATransform3D вместо anchorPoint
- `SourceInputField` переработан для корректного расчёта высоты

---

## [0.3.3] - 2026-01-27

### Fixed
- **Dynamic output height** — поле вывода перевода теперь расширяется при многострочном тексте
  - Добавлен `TextHeightPreferenceKey` механизм (как у `SourceInputField`)
  - Минимальная высота 44pt, максимальная 120pt
  - Текст больше не уходит в скролл

- **Shadow parameters** — исправлены параметры тени согласно Figma
  - Opacity: 0.35 → 0.25
  - Radius: 20 → 12
  - Y offset: 10 → 8

- **Animation origin** — анимация появления панели теперь из центра снизу
  - Установлен `anchorPoint` слоя на (0.5, 1.0)
  - Корректный сброс anchor point при скрытии

- **Hotkey hint styling** — исправлена стилизация хинта внизу панели
  - Шрифт: 15pt → 14pt (согласно Figma)
  - Добавлена 50% прозрачность ко всему компоненту

### Technical
- `OutputField` теперь использует `@State` для динамического расчёта высоты
- `FloatingPanel.showAnimated()` и `hideAnimated()` управляют anchor point слоя

---

## [0.3.2] - 2026-01-27

### Fixed
- **Placeholder alignment** — курсор больше не перекрывает текст placeholder
  - Добавлен padding к placeholder (leading: 5pt, top: 8pt)

- **Dynamic input height** — поле ввода теперь расширяется при многострочном тексте
  - Минимальная высота 44pt, максимальная 120pt
  - Используется PreferenceKey для расчёта высоты

- **Corner artifacts** — убраны артефакты на закруглённых углах панели
  - Добавлен cornerRadius к layer NSVisualEffectView
  - Используется cornerCurve: .continuous для плавных углов

- **Swap button stability** — кнопка swap больше не двигается при смене языков
  - Фиксированная минимальная ширина для language selectors (80pt)

### Changed
- **Glass effect** — изменён material с .hudWindow на .popover
  - Более прозрачный и светлый эффект, похожий на Spotlight
  - Overlay изменён на white.opacity(0.05)

- **Shadow enhancement** — усилена тень панели
  - Opacity: 0.25 → 0.35
  - Radius: 12 → 20
  - Y offset: 8 → 10

- **Icon sizes** — уменьшены размеры иконок
  - Swap icon: 16pt → 13pt
  - Copy icon: 20pt → 16pt

- **Panel animation** — анимация появления как у Spotlight (Tahoe)
  - Добавлен scale transform (0.95 → 1.0)
  - Spring animation с damping: 15, stiffness: 300
  - Fade + scale для появления и скрытия

### Technical
- Новые константы: `inputMaxHeight`, `copyIconSize`, `swapIconFont`, `languageSelectorMinWidth`
- `IconButton` теперь принимает параметр `iconFont`
- `VisualEffectBlur` принимает `cornerRadius` параметр

---

## [0.3.1] - 2026-01-27

### Fixed
- **Input focus** — исправлена проблема с неактивными текстовыми полями
  - Удалён `.nonactivatingPanel` из styleMask панели
  - Добавлены `canBecomeKey` и `canBecomeMain` overrides
  - Теперь панель корректно получает фокус клавиатуры

---

## [0.3.0] - 2026-01-27

### Added
- **Apple Translation API** — реальный перевод через Translation framework (macOS 15+)
  - `TranslationService` — async/await обертка над TranslationSession
  - Поддержка Russian ↔ English
  - Fallback сообщение для macOS < 15

- **Global Hotkey** — Shift+Option+T для toggle панели
  - Регистрация через KeyboardShortcuts в AppDelegate
  - Escape для закрытия панели

- **Menu Bar Icon** — иконка в системном меню
  - SF Symbol `character.bubble`
  - Меню: "Open Zing (⇧⌥T)" и "Quit (⌘Q)"

- **Show/Hide Animations** — плавные переходы
  - Fade in: 0.2s easeOut
  - Fade out: 0.12s easeIn
  - NSAnimationContext для анимаций NSPanel

- **ClipboardService** — сервис для работы с буфером обмена
  - `copy(_:)` и `paste()` методы
  - Использует NSPasteboard.general

### Changed
- **TranslatorViewModel** — полная переработка
  - Реальный перевод вместо mock
  - Debounce увеличен до 0.5s
  - Добавлен `errorMessage: String?` для отображения ошибок
  - Типизированные языки через `SupportedLanguage` enum
  - Отмена предыдущего запроса при новом вводе

- **FloatingPanel** — улучшения
  - `showAnimated()` / `hideAnimated()` с анимациями
  - NSApp.activate для правильного фокуса
  - ViewModel создается один раз в FloatingPanelManager

- **TranslatorView** — обновления UI
  - `@ObservedObject` вместо `@StateObject` (ViewModel передается извне)
  - ProgressView overlay при переводе
  - Отображение ошибок красным цветом
  - CloseButton скрывает панель вместо terminate
  - Escape key handler через hidden Button

- **InputField** — OutputField improvements
  - CopyButton всегда видна, но disabled когда текст пуст
  - Opacity 0.3 для disabled состояния

- **Constants** — новые константы
  - `Animation.showDuration`, `hideDuration`, `showScale`
  - `Translation.debounceInterval`

### Technical
- macOS 15.0+ для Translation API (fallback для старых версий)
- Состояние ViewModel сохраняется между hide/show панели

---

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
