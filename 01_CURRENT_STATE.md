# 01_CURRENT_STATE.md

## Project Overview

- **Targets & Schemes**: The project has three targets: `DaysToGo` (main app), `DaysToGoTests` (unit tests), and `DaysToGoUITests` (UI tests). A new **`DaysToGoKit` framework** has been added to share code between the main app and its extensions. Standard schemes for each target are assumed.
- **Swift/SwiftUI Versions**: The `.xcodeproj` file specifies `SWIFT_VERSION = 5.0`, but the use of modern APIs like `@Environment(\.dismiss)` and `async/await` suggests a Swift 5.5+ environment. The deployment target is set to iOS 18.5. The codebase is **Swift 6 concurrency-compliant**, with proper MainActor isolation and no data race warnings.
- **Third-Party Dependencies**: There are no third-party dependencies evident from the project structure or `project.pbxproj` file.
- **App Architecture**: The architecture has been refactored to a clean **MVVM (Model-View-ViewModel)** pattern with Dependency Injection.
    - **ViewModels**: `ReminderListViewModel` and `ReminderDetailViewModel` now contain the business logic and state management for their respective views.
    - **Services**: Service protocols (`PhotoFetching`, `CalendarFetching`, `ReminderStoring`, `HistoricalEventFetching`) are defined in `DaysToGoKit/Protocols.swift` with comprehensive documentation. Concrete services (`PhotoService`, `CalendarService`, `ReminderStore`, `WikipediaService`) implement these protocols.
    - **Dependency Injection**: A centralized `ServiceContainer` class manages all service dependencies. Services can be injected via the container's shared instance or through custom instances for testing. ViewModels provide convenience initializers that use the service container by default.
- **Data Model & Persistence**:
    - The primary data models are the `Reminder`, `CalendarEventViewModel`, `HistoricalEvent`, and `UserProfile` structs.
    - The `Reminder` model includes a `modifiedAt` timestamp property used for conflict resolution during sync operations.
    - The `UserProfile` model stores user's firstName, surname, and country, with helper properties (fullName, greeting) for personalization.
    - **Persistence is handled by a hybrid approach**: Reminders are saved immediately to a local JSON file within a **shared App Group container** for quick access and offline support. These local changes are then asynchronously synchronized with **CloudKit** for iCloud synchronization across devices.
    - **CloudKit Sync Strategy**: The app uses intelligent merge logic that compares local and cloud reminders by modification timestamp, uploads local-only changes, downloads new cloud reminders, and resolves conflicts by choosing the most recently modified version. This prevents data loss during offline/online transitions.
    - **Sync State Tracking**: `ReminderStore` publishes a `syncState` property (synced, syncing, offline, error) that tracks the current CloudKit synchronization status, providing visibility into network connectivity and sync issues.
    - **User Profile Management**: `UserProfileStore` manages user profile data (firstName, surname, country) via UserDefaults, with automatic persistence and onboarding status tracking.
    - Calendar preferences are stored in `UserDefaults` by `CalendarPreferences`.
    - All app-wide constants (App Group ID, widget kind, notification names) are centralized in `DaysToGoKit/Constants.swift`.

## Features Implemented vs. Intended

- **Implemented**:
    - **Onboarding Flow**: First-time users see a beautiful 3-page onboarding experience that collects firstName, surname, and country via structured inputs. Page 2 features separate text fields for first name (required) and surname (optional). Page 3 provides a wheel-style country picker with 40+ countries sorted alphabetically. The onboarding uses a full-screen modal with smooth page transitions, validation, and proper completion tracking.
    - **User Profile Management**: Users can view and edit their profile (firstName, surname, country) through Settings → Profile. The profile form includes separate name fields and a country picker matching the onboarding experience. Profile data is persisted via UserDefaults and displayed throughout the app for personalization (fullName in Settings menu, firstName in greetings).
    - **iCloud Sync**: Reminders are automatically synced across devices using CloudKit.
    - **Pull-to-Refresh**: Users can manually refresh the reminder list by pulling down, triggering a CloudKit sync with visual feedback.
    - **Home Screen Widget**: A widget is available to show upcoming reminders, fetching data from the **shared App Group container** for fast, offline-capable display. The widget includes data freshness validation and warns when data is stale (over 1 hour old).
    - **CRUD for Reminders**: Users can create, view, edit, and delete reminders.
    - **Reminder List**: `ReminderListView` displays reminders in a full-width list, sorted by date.
    - **Reminder Detail**: `ReminderDetailView` shows details for a selected reminder, including an optional description.
    - **Countdown Calculation**: The `Reminder` model includes a `daysRemaining` computed property.
    - **Past-Date Logic**: A `reflectionDate` computed property calculates the date in the past corresponding to the "days remaining" count.
    - **Photo Fetching**: `PhotoService` fetches images from the user's photo library for the calculated `reflectionDate`.
    - **Calendar Fetching**: `CalendarService` fetches calendar events for the `reflectionDate`.
    - **Historical Events**: `WikipediaService` fetches "On This Day" historical events from Wikipedia's free API for the `reflectionDate`, showing events, births, deaths, and holidays from throughout history. No API key required, completely free with unlimited access.
    - **Settings Menu**: A hierarchical `SettingsView` with organized sections for Personal (Profile) and Data Sources (Calendars), plus app version information.
    - **Customizable Reminder Appearance**: Reminders can now have an optional description and a customizable background color selected from 8 pastel options.
    - **Splash Screen**: A custom splash screen is displayed on app launch.
- **Gaps & TODOs**: 
    - The UI test target (`DaysToGoUITests`) contains only boilerplate code.

## Code Quality & Structure

- **File/Folder Structure**: The project structure has been improved with the addition of `Models`, `ViewModels`, and `Services` directories, providing better organization. Shared code (like `Reminder`, `PastelColor`, `Constants`, and `Protocols`) is now located in the `DaysToGoKit` framework. The `Models` directory in the main app now only contains app-specific ViewModels like `CalendarEventViewModel`.
- **Naming Conventions**: Naming generally follows Swift standard conventions. File names match their contained types (e.g., `PhotoService.swift` contains `PhotoService` class).
- **Separation of Concerns**: The MVVM architecture enforces a strong separation of concerns. Views are now primarily responsible for layout and user interaction, while business logic resides in the ViewModels. Reusable UI components like `ReminderFormView` eliminate code duplication between Add and Edit views.
- **State Management**: The app uses a combination of `@StateObject`, `@ObservedObject`, `@EnvironmentObject`, and `@State` for managing state. `ReminderStore` explicitly conforms to `ObservableObject` and is marked with `@MainActor` to ensure all UI updates happen consistently on the main thread. All reminder change notifications are centralized in a single `notifyChanges()` method.
- **Concurrency & Thread Safety**: The codebase is fully Swift 6 concurrency-compliant with proper actor isolation:
    - `ReminderStoring` protocol is marked `@MainActor` ensuring all conforming types are properly isolated
    - Service initializers use optional parameters with nil defaults to avoid actor-crossing in default parameter values
    - `ReminderStore.init()` is `nonisolated` with MainActor work properly isolated in Task blocks
    - All mock services for testing are also properly MainActor-isolated
- **Error Handling & Logging**: A formal error handling strategy has been implemented. The app uses an enhanced `AppError` type with 5 specific error cases (`permissionDenied`, `networkUnavailable`, `cloudKitError`, `dataCorruption`, `underlying`) and smart computed properties (`shouldRetry`, `shouldShowSettingsButton`) for intelligent error handling. All logging now uses **OSLog** with structured, categorized loggers (`AppLogger.cloudKit`, `AppLogger.photos`, `AppLogger.calendar`, etc.) defined in `Services/Logger.swift`. Error alerts now display context-appropriate messages using `recoverySuggestion` and conditionally show the "Open Settings" button only when relevant. Race conditions in concurrent error handling have been resolved to prevent alert loops.
- **Constants Management**: All hardcoded strings (App Group ID, widget kind, notification names, file names) have been extracted to `DaysToGoKit/Constants.swift` for centralized management and type safety. Animation timing values are also centralized in the `AnimationTiming` enum.
- **Protocol Organization**: All service protocols are consolidated in `DaysToGoKit/Protocols.swift` with comprehensive documentation, making them easily discoverable and reusable across targets.
- **Dependency Management**: The `ServiceContainer` class provides centralized dependency injection, managing all service instances with support for both production (shared singleton) and testing (custom instances) scenarios.
- **Reusable Extensions**: The codebase includes helpful extensions like `BindingExtensions.swift` which provides the `.isPresent` computed property for Optional bindings, enabling cleaner alert presentation code with proper nil-checking using Mirror reflection.
- **Performance Optimizations**: ViewModels implement intelligent caching (e.g., `cachedReflectionDate`, `cachedCalendarIDs`) to prevent redundant API calls when data hasn't changed. Photo fetching is consistently ordered by creation date without shuffling.
- **Test Coverage**: Unit test coverage has been established. There are now tests for the `Reminder` model's date logic and for the `ReminderListViewModel` and `ReminderDetailViewModel`, using mock services to isolate them from external dependencies.

## UX/UI Snapshot

- **SwiftUI Patterns**: The app uses standard SwiftUI components like `NavigationView`, `NavigationStack`, `LazyVStack`, `Form`, and presents modal sheets for adding/editing reminders. Sheet-presented views (AddReminderView, EditReminderView, SettingsView) properly use NavigationStack to provide navigation context for toolbar buttons.
- **Layout & Components**: `ReminderTile` is a well-defined, reusable component for the main list, now displayed full-width with larger fonts for the title and date. The detail view is a simple vertical stack. The main list view has a single, clean title. `ReminderFormView` provides a shared, reusable form component used by both Add and Edit views.
- **UI Polish**: Loading indicators (`ProgressView`) are now displayed during asynchronous data fetching in `ReminderDetailView`. Empty states for photos and calendar events have been improved with more engaging visuals and descriptive text. The widget now uses the `containerBackground` API for proper display. The color picker for reminders is now a visual, tappable row of colored circles. Error alerts display context-appropriate messages with proper recovery suggestions.
- **Accessibility**: Explicit accessibility labels and hints have been added to key interactive elements across `ReminderListView`, `ReminderDetailView`, `ReminderTile`, `AddReminderView`, and `EditReminderView`, improving the experience for VoiceOver users.
- **Localization**: All user-facing strings are hardcoded in English. The project is not set up for localization.
- **Assets**: The project includes an `AppIcon` and an `AccentColor` in `Assets.xcassets`.

## Privacy & Permissions

- **Photo/Calendar Access**: The app correctly uses `PHPhotoLibrary.requestAuthorization` and `EKEventStore.requestFullAccessToEvents` to request permissions.
- **Permission Prompts**: Permissions are requested when the features are first used. The app now gracefully handles permission denial by showing an alert.
- **Privacy Manifest**: The `Info.plist` file contains the necessary usage descriptions: `NSPhotoLibraryUsageDescription` and `NSCalendarsUsageDescription`.

## Build/Tooling

- **Linters/Formatters**: **SwiftLint** has been integrated into the project with a `.swiftlint.yml` configuration file to enforce code style and conventions.
- **Build Settings**: The project has standard Debug and Release configurations. **App Groups** have been configured to enable data sharing between the main app and the widget extension. A new **`DaysToGoKit` framework** has been added to encapsulate shared code, resolving dependency issues between the main app and its extensions.
- **CI/CD**: There is no evidence of a Continuous Integration or Continuous Deployment pipeline.
