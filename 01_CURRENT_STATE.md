# 01_CURRENT_STATE.md

## Project Overview

- **Targets & Schemes**: The project has three targets: `DaysToGo` (main app), `DaysToGoTests` (unit tests), and `DaysToGoUITests` (UI tests). A new **`DaysToGoKit` framework** has been added to share code between the main app and its extensions. Standard schemes for each target are assumed.
- **Swift/SwiftUI Versions**: The `.xcodeproj` file specifies `SWIFT_VERSION = 5.0`, but the use of modern APIs like `@Environment(\.dismiss)` and `async/await` suggests a Swift 5.5+ environment. The deployment target is set to iOS 18.5. The codebase is **Swift 6 concurrency-compliant**, with proper MainActor isolation and no data race warnings.
- **Third-Party Dependencies**: There are no third-party dependencies evident from the project structure or `project.pbxproj` file.
- **App Architecture**: The architecture has been refactored to a clean **MVVM (Model-View-ViewModel)** pattern with Dependency Injection.
    - **ViewModels**: `ReminderListViewModel` contains business logic for filtering reminders into future and past lists, with a `selectedView` published property to manage the Reminders/History view mode. `ReminderDetailViewModel` manages state for the detail view.
    - **Services**: Service protocols (`PhotoFetching`, `CalendarFetching`, `ReminderStoring`, `HistoricalEventFetching`, `LocationFetching`) are defined in `DaysToGoKit/Protocols.swift` with comprehensive documentation. Concrete services (`PhotoService`, `CalendarService`, `ReminderStore`, `WikipediaService`, `LocationService`) implement these protocols.
    - **Dependency Injection**: A centralized `ServiceContainer` class manages all service dependencies. Services can be injected via the container's shared instance or through custom instances for testing. ViewModels provide convenience initializers that use the service container by default.
- **Data Model & Persistence**:
    - The primary data models are the `Reminder`, `CalendarEventViewModel`, `HistoricalEvent`, `UserProfile`, and `LocationPoint` structs.
    - The `Reminder` model includes a `modifiedAt` timestamp property used for conflict resolution during sync operations.
    - The `HistoricalEvent` model represents Wikipedia events with year, text, eventType (event/birth/death/selected), url, imageUrl, and optional aiSummary. Holiday events are excluded from the app.
    - The `UserProfile` model stores user's firstName, surname, and country, with helper properties (fullName, greeting) for personalization.
    - The `LocationPoint` model stores latitude, longitude, timestamp, and accuracy data for location history tracking.
    - **Persistence is handled by a hybrid approach**: Reminders are saved immediately to a local JSON file within a **shared App Group container** for quick access and offline support. These local changes are then asynchronously synchronized with **CloudKit** for iCloud synchronization across devices.
    - **CloudKit Sync Strategy**: The app uses intelligent merge logic that compares local and cloud reminders by modification timestamp, uploads local-only changes, downloads new cloud reminders, and resolves conflicts by choosing the most recently modified version. This prevents data loss during offline/online transitions.
    - **Sync State Tracking**: `ReminderStore` publishes a `syncState` property (synced, syncing, offline, error) that tracks the current CloudKit synchronization status, providing visibility into network connectivity and sync issues.
    - **User Profile Management**: `UserProfileStore` manages user profile data (firstName, surname, country) via UserDefaults, with automatic persistence and onboarding status tracking.
    - **Display Preferences**: `ReminderDisplayPreferences` manages user preferences for which data types are visible in reminder details (Photos, Calendar Events, On This Day, Location). Preferences are stored in UserDefaults and default to all enabled.
    - Calendar preferences are stored in `UserDefaults` by `CalendarPreferences`.
    - All app-wide constants (App Group ID, widget kind, notification names) are centralized in `DaysToGoKit/Constants.swift`.

## Features Implemented vs. Intended

- **Implemented**:
    - **Onboarding Flow**: First-time users see a beautiful 3-page onboarding experience that collects firstName, surname, and country via structured inputs. Page 2 features separate text fields for first name (required) and surname (optional). Page 3 provides a wheel-style country picker with 40+ countries sorted alphabetically. The onboarding uses a full-screen modal with smooth page transitions, validation, and proper completion tracking.
    - **User Profile Management**: Users can view and edit their profile (firstName, surname, country) through Settings → Profile. The profile form includes separate name fields and a country picker matching the onboarding experience. Profile data is persisted via UserDefaults and displayed throughout the app for personalization (fullName in Settings menu, firstName in greetings).
    - **Reminders/History Split View**: The main list view features a segmented control at the top to switch between "Reminders" (today and future events) and "History" (past events). Future reminders are sorted earliest to latest, while past reminders are sorted most recent to earliest. Each view has contextual empty states. The view has a clean, minimal design with the segmented control as the primary navigation element.
    - **iCloud Sync**: Reminders are automatically synced across devices using CloudKit.
    - **Pull-to-Refresh**: Users can manually refresh the reminder list by pulling down, triggering a CloudKit sync with visual feedback.
    - **Home Screen Widget**: A widget is available to show upcoming reminders, fetching data from the **shared App Group container** for fast, offline-capable display. The widget includes data freshness validation and warns when data is stale (over 1 hour old).
    - **CRUD for Reminders**: Users can create, view, edit, and delete reminders. Swipe left on any reminder tile to reveal a delete button, or swipe fully for instant deletion.
    - **Reminder List**: `ReminderListView` displays reminders in a full-width list, sorted by date.
    - **Reminder Detail**: `ReminderDetailView` shows details for a selected reminder, including an optional description.
    - **Countdown Calculation**: The `Reminder` model includes a `daysRemaining` computed property.
    - **Past-Date Logic**: A `reflectionDate` computed property calculates the date in the past corresponding to the "days remaining" count.
    - **Smart Date Selection**: `ReminderDetailViewModel` uses different dates based on reminder status - for future/today reminders (Reminders view), it uses the reflection date to show corresponding past data; for past reminders (History view), it uses the actual reminder date to show what happened on that day.
    - **Photo Fetching**: `PhotoService` fetches images from the user's photo library for the appropriate date (reflection date for future events, reminder date for past events).
    - **Calendar Fetching**: `CalendarService` fetches calendar events for the appropriate date (reflection date for future events, reminder date for past events).
    - **Historical Events**: `WikipediaService` fetches "On This Day" historical events from Wikipedia's free API for the appropriate date, showing events, births, and deaths that match the exact year. Recurring holidays are excluded to focus on unique historical events. No API key required, completely free with unlimited access.
    - **Location Tracking**: `LocationService` tracks location changes in the background using CoreLocation, building a detailed history of user movements over time. Location data for the appropriate date is displayed on an interactive map in the reminder detail view. Uses continuous location updates with 20-meter distance filter for detailed tracking, automatically records the first location of each day, stores last 90 days of data locally, and filters poor accuracy locations (except for daily first entries).
    - **Settings Menu**: A hierarchical `SettingsView` with organized sections for Personal (Profile) and Data Sources (Display Options, Calendars), plus an About section with app version, developer information (Jon Wright), and technology stack (SwiftUI & CloudKit). Display Options allow users to toggle visibility of Photos, Calendar Events, On This Day, and Location sections in reminder details.
    - **Customizable Reminder Appearance**: Reminders can now have an optional description and a customizable background color selected from 12 pastel options displayed in a 2×6 grid layout.
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
- **Layout & Components**: `ReminderTile` is a well-defined, reusable component for the main list, now displayed full-width with larger fonts for the title and date. All text is rendered in black for consistent readability across pastel backgrounds. Colored borders (6pt thick) indicate urgency: red for overdue, yellow for today, green for within 7 days. The detail view is a simple vertical stack. The main list view has a single, clean title. `ReminderFormView` provides a shared, reusable form component used by both Add and Edit views.
- **UI Polish**: Loading indicators (`ProgressView`) are now displayed during asynchronous data fetching in `ReminderDetailView`. Empty states for photos and calendar events have been improved with more engaging visuals and descriptive text. The widget uses the `containerBackground` API for proper display with black text on pastel backgrounds. The color picker for reminders is now a visual, tappable row of colored circles. Error alerts display context-appropriate messages with proper recovery suggestions.
- **Accessibility**: Explicit accessibility labels and hints have been added to key interactive elements across `ReminderListView`, `ReminderDetailView`, `ReminderTile`, `AddReminderView`, and `EditReminderView`, improving the experience for VoiceOver users.
- **Localization**: All user-facing strings are hardcoded in English. The project is not set up for localization.
- **Assets**: The project includes an `AppIcon` and an `AccentColor` in `Assets.xcassets`.

## Privacy & Permissions

- **Photo/Calendar Access**: The app correctly uses `PHPhotoLibrary.requestAuthorization` and `EKEventStore.requestFullAccessToEvents` to request permissions.
- **Location Access**: The app uses `CLLocationManager.requestAlwaysAuthorization` to enable background location tracking. Location tracking uses continuous updates with 20-meter distance filter for detailed movement history. The first location of each day is always recorded. Data is stored locally and automatically cleaned up after 90 days.
- **Permission Prompts**: Permissions are requested on app launch (location) or when features are first used (photos/calendar). The app gracefully handles permission denial by showing alerts with helpful recovery suggestions.
- **Privacy Manifest**: The `Info.plist` file contains the necessary usage descriptions: `NSPhotoLibraryUsageDescription`, `NSCalendarsUsageDescription`, `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`, and `NSLocationAlwaysUsageDescription`. Background location updates are declared in `UIBackgroundModes`.

## Build/Tooling

- **Linters/Formatters**: **SwiftLint** has been integrated into the project with a `.swiftlint.yml` configuration file to enforce code style and conventions.
- **Build Settings**: The project has standard Debug and Release configurations. **App Groups** have been configured to enable data sharing between the main app and the widget extension. A new **`DaysToGoKit` framework** has been added to encapsulate shared code, resolving dependency issues between the main app and its extensions.
- **CI/CD**: There is no evidence of a Continuous Integration or Continuous Deployment pipeline.

## Recent Changes

### November 2025 - Historical Events Filtering Enhancement

**Wikipedia "On This Day" Exact Year Matching**
- Modified `WikipediaService` to filter events by exact year match (not just day/month)
- Excluded recurring holidays entirely from historical events display
- Events now show only what happened on that specific date in that specific year
- Provides more relevant, personalized historical context for reflection dates
- See `02_IMPROVEMENTS_PLAN.md` → "Post-Phase 14 Enhancements" for detailed documentation

### November 2025 - Enhanced Location Tracking

**More Detailed Movement History**
- Switched from significant location changes (~500m) to continuous updates (20m distance filter)
- Implemented daily first location recording - always captures where the day started
- Improved accuracy from 100m to Best for more precise tracking
- First location of each day is always recorded regardless of accuracy
- Subsequent locations still filter for good accuracy (< 100m)
- Provides much more detailed movement history throughout each day
- See `02_IMPROVEMENTS_PLAN.md` → "Post-Phase 14 Enhancements" for detailed documentation

### November 2025 - Display Options Settings

**Customizable Reminder Data Visibility**
- Added new Display Options settings submenu (Settings → Data Sources → Display Options)
- Users can toggle visibility of 4 data types: Photos, Calendar Events, On This Day, Location
- When toggled off, sections are completely hidden (no placeholders, no empty states)
- Preferences persist via UserDefaults and default to all enabled
- Provides privacy and customization control over reminder detail views
- See `02_IMPROVEMENTS_PLAN.md` → "Post-Phase 14 Enhancements" for detailed documentation

### November 2025 - UI Improvements for Reminder Tiles and Widgets

**Enhanced Visual Consistency and Readability**
- **Reminder Tiles**: All text now renders in black for consistent readability on pastel backgrounds
- **Reminder Tiles**: Colored borders increased from 3pt to 6pt for better urgency visibility
- **Reminder Tiles**: Border colors indicate urgency (red=overdue, yellow=today, green=within 7 days)
- **Home Screen Widget**: Text changed to black for consistent appearance
- **Home Screen Widget**: No borders for cleaner, simpler widget design
- Improved contrast and readability across both light and dark mode

### November 2025 - Reminders/History Split View

**Organized List View with Timeline Separation**
- Added segmented control to switch between "Reminders" and "History" views
- **Reminders view**: Shows today and future events (daysRemaining >= 0), sorted earliest to latest
- **History view**: Shows past events (daysRemaining < 0), sorted most recent to earliest
- Contextual empty states for each view mode
- Current day events (daysRemaining = 0) appear in Reminders list
- View selection managed by ReminderListViewModel with published selectedView property
- See `02_IMPROVEMENTS_PLAN.md` → "Post-Phase 14 Enhancements" for detailed documentation

### November 2025 - Smart Date Selection for History View

**Context-Aware Data Fetching**
- **Reminders view**: Uses reflection date to show what happened X days ago (unchanged)
- **History view**: Uses actual reminder date to show what happened on that day
- ReminderDetailViewModel.dateForDataFetching computed property intelligently selects appropriate date
- Affects all data types: Photos, Calendar Events, Historical Events, Location
- ReminderDetailView displays different date layouts for past vs future reminders
- Past reminders show "Showing data from this day" caption for clarity
- Makes History view meaningful by showing actual event day data instead of calculated future dates
- See `02_IMPROVEMENTS_PLAN.md` → "Post-Phase 14 Enhancements" for detailed documentation

### November 2025 - UI Refinement: Header Removal

**Cleaner List View Design**
- Removed "Your Reminders" large title header from main list view
- Segmented control now appears directly at the top of the view
- More space for reminder content
- Cleaner, more minimal design aesthetic
- Navigation bar already displays "Days To Go" app title

### December 2025 - About Section Enhancement

**Developer Attribution and Technology Information**
- Added Developer row to About section showing "Jon Wright"
- Added Built with row showing "SwiftUI & CloudKit"
- Consistent visual styling with existing About section items
- Professional attribution with system icons (person.circle, hammer.circle)
- Provides transparency about app creator and core technologies

### December 2025 - Color Picker Enhancement

**Expanded Color Palette and Grid Layout**
- Expanded color palette from 8 to 12 pastel colors
- Added 4 new colors: Pastel Teal, Pastel Lavender, Pastel Peach, Pastel Mint
- Changed layout from horizontal scrolling to 2×6 grid (LazyVGrid)
- All colors now visible without scrolling
- Improved color selection experience with organized grid presentation

### December 2025 - App Icon Configuration Fix

**Asset Catalog Correction**
- Fixed app icon not displaying on device/simulator
- Resolved issue where icon images were in "AppIcon 1.appiconset" instead of "AppIcon.appiconset"
- Renamed asset catalog folder to correct name for Xcode recognition
- All 15 icon sizes now properly configured and displaying on devices

### December 2025 - Swipe-to-Delete Functionality

**List Interaction Enhancement**
- Added swipe-to-delete gesture for reminder tiles
- Swipe left to reveal red delete button with trash icon
- Full swipe gesture for instant deletion
- Works in both Reminders and History views
- Uses native iOS List with swipeActions for familiar UX
- Maintains visual design with custom row insets and hidden separators

### December 2025 - "Today" Display Enhancement

**Improved Date Presentation**
- Reminders with 0 days remaining now display "Today" instead of "0 days left"
- Applied to both reminder tiles and home screen widget
- Widget uses appropriately sized font (40pt) for "Today" text
- Provides clearer, more natural indication of current-day events
- Updated accessibility labels to announce "Today" for VoiceOver users

### December 2025 - Enhanced Date Format with Day of Week

**Improved Date Readability**
- All dates now display with day of week (e.g., "Saturday 13 December 2025")
- Applied to reminder tiles in list view
- Applied to both reminder date and reflection date in detail view
- Detail view changed from horizontal to vertical layout for better readability
- Provides better planning context (weekend vs weekday identification)
- Format: weekday (full), day, month (full), year

### December 2025 - History View Border Removal

**Cleaner History Display**
- Removed colored urgency borders from reminder tiles in History view
- History reminders now display with only their pastel background colors
- Reminders view maintains colored borders (red/yellow/green) for urgency indicators
- Added `showUrgencyBorder` parameter to `ReminderTile` component
- Provides cleaner, less visually busy appearance for past events
- Urgency borders are only relevant for upcoming reminders, not historical ones

### December 2025 - History Detail Empty State Fix

**Correct Date Display in Empty States**
- Fixed empty state placeholders in History detail view to show correct date
- Previously showed reflection date (future) instead of actual reminder date (past)
- Updated all four empty state sections: Photos, Calendar Events, Historical Events, Location
- Now uses `dateForDataFetching` computed property from ViewModel
- Empty states for past reminders now correctly reference the actual event date
- Provides consistency with the data being fetched and displayed

### December 2025 - Reminder Form Reorganization

**Cleaner Form Layout with Defined Sections**
- Reorganized reminder form into four clearly defined sections
- Separated Title, Date, Details, and Colour into individual sections
- Each field now has its own dedicated section with clear header
- Updated placeholders: "Enter reminder title" and "Select date" for better clarity
- Applies to both Add Reminder and Edit Reminder views via shared ReminderFormView
- Improved visual hierarchy and easier scanning of form structure
- More consistent with iOS form design patterns

### December 2025 - Positive "Days Ago" for History

**Natural Language for Past Reminders**
- Changed display for past reminders from negative "days left" to positive "days ago"
- History tiles now show "5 days ago" instead of "-5 days left"
- Detail view for past reminders now includes "X days ago" display
- Added `daysText` computed property to ReminderTile for clean formatting logic
- More natural language: past events described as "ago", future events as "left"
- Applied to both reminder tiles and detail view
- Updated accessibility labels to announce correct phrasing
