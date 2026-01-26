# Zing — Project Overview

## Архитектура

TODO: После создания архитектуры описать:
- Структуру проекта (MVVM)
- Как работает NSPanel overlay
- Как устроен хоткей (KeyboardShortcuts)
- Apple Translation API integration

## Компоненты

### App Entry Point
- `ZingNewApp.swift` — точка входа, настройка приложения как agent (без иконки в Dock)

### Overlay Panel
- `Panels/` — NSPanel wrapper для создания floating overlay поверх всех окон

### Translation Service
- `Services/` — интеграция с Apple Translation API

### UI Components
- `Views/` — основные SwiftUI экраны
- `Components/` — переиспользуемые UI элементы (liquid glass стиль)

## Технические детали

### Agent App (LSUIElement)
Приложение настроено как UI Element (LSUIElement = YES), что означает:
- Нет иконки в Dock
- Нет меню приложения в menubar
- Работает полностью через глобальный хоткей

### Глобальный хоткей
Используется библиотека KeyboardShortcuts для регистрации Shift+Option+T
