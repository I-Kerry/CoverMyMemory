# CoverMyMemory

![Platform](https://img.shields.io/badge/Platform-iOS%2018.0%2B-blue.svg)
![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![UI](https://img.shields.io/badge/UI-UIKit%20%2B%20SwiftUI-purple.svg)
![Persistence](https://img.shields.io/badge/Persistence-SwiftData-green.svg)
![Dependencies](https://img.shields.io/badge/Dependencies-None%20(100%25%20Native)-brightgreen.svg)

**CoverMyMemory** is a native iOS reminder and accountability app designed around visual proof and people-first organization. Schedule single-day, multi-date, or recurring reminders, link them to contacts, attach photo proof upon completion, and receive smart local notifications that automatically clear once tasks are done.

---

## Key Features

- **Daily Timeline & Calendar Navigation**
  - Browse reminders day-by-day with quick previous/next navigation and a calendar date picker (`Today`, `Yesterday`, `Tomorrow`, or full date headers).
  - Filter tasks (`All`, `Completed`, `Not completed`) and sort by time (`By time`, `Completed first`, `Not completed first`) using `hour:minute` comparison.
  - Per-day completion state tracking (`completedDates`) with protection against prematurely completing tasks scheduled for future dates.

- **Flexible Multi-Date & Recurring Scheduling**
  - Assign one or multiple specific dates to a reminder via SwiftUI `MultiDatePicker`.
  - Optional inline `.wheel` time picker and `Deadline Mode` urgency highlighting.
  - Weekday recurrence selector (`None` + `Sunday`–`Saturday`) via a persistent multi-select checkmark `Menu`.

- **Photo-Proof Completion**
  - Tapping an incomplete reminder opens the completion sheet to capture a live camera photo or select one from the Photo Library.
  - Quick checkmark toggle on the card and a `"Photo"` leading swipe action to attach or replace proof anytime.
  - Full-resolution JPEGs and thumbnails are managed on disk with automatic orphan-file cleanup on replacement, removal, or deletion.

- **People Library**
  - Create and edit contacts with custom avatars or auto-generated initials (`PersonAvatarView`).
  - View all reminders assigned to a specific person along with their schedule summaries.

- **Smart Local Notifications**
  - Schedules a primary reminder at **12:00** (or the user-chosen time) plus an **end-of-day reminder at 23:00** (skipping duplicates if custom time is `23:00`) strictly for uncompleted scheduled days.
  - Automatically cancels pending and delivered notifications when a task is completed, edited, or deleted, and re-syncs across active occurrences on app launch and foreground transitions.

- **Appearance & Data Management**
  - Switch between `System`, `Light`, and `Dark` themes.
  - Full device data reset (`Notifications → Reminders → People → Photos`) and dynamic app version display sourced from `Bundle`.

---

## Tech Stack

- **Language & Concurrency:** Swift 6 (`@MainActor` isolation, `async/await`)
- **UI Frameworks:** UIKit (`UITabBarController`, `UINavigationController`, `UITableViewDiffableDataSource`) + SwiftUI (`@Observable`, `ObservableObject`, `MultiDatePicker`, `NavigationStack`)
- **Persistence & Storage:** SwiftData (`@Model`, `ModelContainer`) + `FileManager` (`Application Support/Photos`) + `UserDefaults` (abstracted behind `UserPreferencesStorage`)
- **Media & System APIs:** `AVFoundation` (`AVCaptureDevice`), `PhotosUI`, `UserNotifications`, `Combine`
- **Testing:** `XCTest` with in-memory SwiftData `ModelContainer` and mock schedulers
- **Third-Party Dependencies:** None — 100% native Apple frameworks

---

## Architecture

The project follows **MVVM + Coordinator** with **SOLID** principles:

- **Coordinators (`AppCoordinator`, `HomeCoordinator`, `SettingsCoordinator`)** own navigation hierarchies and modal presentations, decoupling screens from routing logic.
- **Protocol-Oriented Data Layer (`ReminderRepository`, `PersonRepository`, `PhotoStorage`, `NotificationScheduler`, `UserPreferencesStorage`)** isolates business logic in ViewModels and services from concrete SwiftData, disk, `UserDefaults`, and `UNUserNotificationCenter` implementations.
- **Modular SwiftUI Components** decompose complex forms (e.g., `ReminderPersonSection`, `ReminderScheduleSection`, `WeekdayRecurrenceMenu`) into focused, reusable views.

### Project Structure

```text
CoverMyMemory_iOS/
├── AppScreens/
│   └── CoverMyMemoryApp.swift           # App entry point, SwiftData container & foreground notification sync
├── Coordinators/
│   ├── Coordinator.swift                # Base coordinator protocol
│   ├── AppCoordinator.swift             # Root tab bar setup (Home & Settings)
│   ├── HomeCoordinator.swift            # Editor & completion sheet flows
│   └── SettingsCoordinator.swift        # Settings navigation flow
├── Data/
│   ├── Models/
│   │   ├── Reminder.swift               # SwiftData @Model with per-day completion & multi-date matching
│   │   └── Person.swift                 # SwiftData @Model for assigned contacts
│   ├── Repositories/
│   │   ├── ReminderRepository.swift
│   │   ├── SwiftDataReminderRepository.swift
│   │   ├── PersonRepository.swift
│   │   ├── SwiftDataPersonRepository.swift
│   │   ├── NotificationScheduler.swift
│   │   ├── UserNotificationsScheduler.swift
│   │   └── NotificationSyncService.swift
│   └── Storage/
│       ├── AppDatabase.swift
│       ├── PhotoStorage.swift
│       ├── FilePhotoStorage.swift
│       ├── UserPreferencesStorage.swift
│       └── UserDefaultsPreferencesStorage.swift
├── Foundation/
│   ├── Constants.swift                  # Spacing, radius, layout, storage & preference keys
│   └── Theme/                           # AssetCatalog tokens, dynamic colors & typography
├── UI/
│   ├── Common/                          # Reusable views (e.g., PersonAvatarView)
│   ├── Completion/                      # CompletionSheetView, ViewModel & camera/picker components
│   ├── Editor/                          # ReminderEditorView, ViewModel, PersonPickerView & section components
│   ├── Home/                            # HomeViewController, HomeViewModel, ReminderCell & floating menus
│   ├── People/                          # PersonLibraryView, PersonEditorView & ViewModels
│   ├── Settings/                        # SettingsView, SettingsViewController & SettingsViewModel
│   └── TabBar/                          # MainTabBarController & SwiftUI wrapper
├── Tests/
│   ├── DataLayerTests.swift
│   ├── HomeViewModelTests.swift
│   ├── ReminderEditorViewModelTests.swift
│   ├── PersonLibraryViewModelTests.swift
│   ├── CompletionSheetViewModelTests.swift
│   └── SnapshotTestingSupport.swift
└── Info.plist                           # Camera, Photo Library & scene manifest configuration
```

---

## Requirements & Setup

### Requirements
- **Xcode:** 18.0 or later
- **iOS Deployment Target:** iOS 18.0+
- **Hardware Note:** Camera capture requires a physical iOS device (the iOS Simulator uses the Photo Library fallback or synthetic image data in tests).

### Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/I-Kerry/CoverMyMemory.git
   cd CoverMyMemory
   ```
2. Open the `.xcodeproj` / `.xcworkspace` in Xcode.
3. Select an iOS 18+ Simulator or a connected iPhone as the run destination.
4. Build and run (`Cmd + R`).

---

## Permissions (`Info.plist`)

The app requests system permissions only when relevant features are used:
- `NSCameraUsageDescription` — capturing photo proof when completing a reminder.
- `NSPhotoLibraryUsageDescription` / `NSPhotoLibraryAddUsageDescription` — selecting contact avatars or saving/picking completion photos.
- Local Notifications (`UNUserNotificationCenter`) — delivering scheduled and end-of-day task alerts.

---

## Running Tests

Unit tests use in-memory `SwiftData` containers and mocked notification schedulers so they run quickly without modifying device state.

- In Xcode, press **`Cmd + U`** to run the full `CoverMyMemoryTests` suite:
  - `DataLayerTests` — SwiftData CRUD for `Person`/`Reminder` and `FilePhotoStorage` disk operations.
  - `HomeViewModelTests` — filtering, sorting, per-day completion isolation, and future-date completion guard.
  - `ReminderEditorViewModelTests` — validation, creation, editing, and weekday recurrence toggling.
  - `PersonLibraryViewModelTests` — contact sorting, deletion cleanup, and reminder association.
  - `CompletionSheetViewModelTests` — photo-proof attachment, removal, and notification cancellation.

---

## Screenshots

| Home | Multi-Date Editor | Photo Proof | People |
| :---: | :---: | :---: | :---: | <img width="1206" height="2622" alt="Home screen" src="https://github.com/user-attachments/assets/63c6fd87-36d7-4fb1-a0e2-507a05acaf84" /> |
<img width="1206" height="2622" alt="Settings" src="https://github.com/user-attachments/assets/398989b5-c2bd-4f7b-9293-88c0e9a0fdd0" /> | <img width="1206" height="2622" alt="Person Library" src="https://github.com/user-attachments/assets/2b283e2a-65f9-43d3-bae8-67d0aac9d074" /> | <img width="1206" height="2622" alt="Create a new person" src="https://github.com/user-attachments/assets/615f221a-4f70-4290-824d-36126e03a128" /> | <img width="1206" height="2622" alt="Create a new Reminder" src="https://github.com/user-attachments/assets/25b72d7a-b848-435b-8750-ae61f70d6363" /> | <img width="1206" height="2622" alt="A completion task sheet" src="https://github.com/user-attachments/assets/002a38d7-5150-4470-912a-f78759ceb059" />







## Author

Created by **Kirill Maidanovich**
