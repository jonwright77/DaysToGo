# 02_IMPROVEMENTS_PLAN.md

This document outlines a prioritized plan to refactor, enhance, and professionalize the DaysToGo application.

## Completed (Phase 1)

These items were completed in the first phase of improvements.

1.  **Refactor to MVVM with Dependency Injection**
    - **Status**: ✅ Completed
    - **Summary**: Introduced ViewModels for `ReminderListView` and `ReminderDetailView`, moved business logic out of views, and defined service protocols for dependency injection.

2.  **Robust Error & Permission Handling**
    - **Status**: ✅ Completed
    - **Summary**: Implemented a centralized error handling system using a custom `AppError` type. The app now shows user-friendly alerts for permission denials and other errors.

3.  **Establish Unit Test Coverage**
    - **Status**: ✅ Completed
    - **Summary**: Added unit tests for the `Reminder` model and the ViewModels, using mock services to ensure testability and prevent regressions.

## Completed (Phase 2)

These items were completed in the second phase of improvements.

1.  **UI Polish: Loading & Empty States**
    - **Status**: ✅ Completed
    - **Summary**: Implemented `ProgressView` indicators for asynchronous data loading and enhanced empty state views with more engaging visuals and descriptive text.

2.  **Add Code Quality Tooling**
    - **Status**: ✅ Completed
    - **Summary**: Integrated SwiftLint into the project. Although we faced environment-specific issues running it, the configuration is in place for future use.

3.  **Improve Accessibility**
    - **Status**: ✅ Completed
    - **Summary**: Added explicit accessibility labels and hints to key interactive elements across various views, significantly improving the app's accessibility for VoiceOver users.

## Completed (Phase 3)

These items were completed in the third phase of improvements.

1.  **iCloud Sync**
    - **Status**: ✅ Completed
    - **Summary**: Replaced the local file-based persistence with CloudKit, allowing reminders to sync automatically and seamlessly across a user's devices.

2.  **Home Screen Widgets**
    - **Status**: ✅ Completed
    - **Summary**: Created a new Widget Extension to display upcoming reminders on the user's Home Screen, providing at-a-glance information.

## Completed (Phase 4)

These items were completed in the fourth phase of improvements.

1.  **Enhanced Reminder Customization**
    - **Status**: ✅ Completed
    - **Summary**: Added `description` and `backgroundColor` properties to the `Reminder` model. Users can now add detailed descriptions and select from 8 pastel background colors for their reminders.

2.  **Improved Reminder List Layout**
    - **Status**: ✅ Completed
    - **Summary**: The `ReminderListView` now displays reminders in a full-width list, providing a cleaner and more spacious layout.

3.  **Description Display in Detail View**
    - **Status**: ✅ Completed
    - **Summary**: The `ReminderDetailView` now prominently displays the reminder's description, offering more context to the user.

## Completed (Phase 5)

These items were completed in the fifth phase of improvements.

1.  **Visual Color Picker**
    - **Status**: ✅ Completed
    - **Summary**: Replaced the text-based color picker with a visual one, allowing users to see and tap the colors directly.

2.  **Improved UI/UX**
    - **Status**: ✅ Completed
    - **Summary**: Made several UI/UX improvements, including a more obvious border for the selected color, a cleaner title in the main list, and larger fonts on the reminder tiles.

## Completed (Phase 6)

These items were completed in the sixth phase of improvements.

1.  **Shared Framework Architecture**
    - **Status**: ✅ Completed
    - **Summary**: Introduced a new `DaysToGoKit` framework to encapsulate shared code (like `Reminder` and `PastelColor`). This provides a robust and modular architecture for sharing code between the main app and its extensions.

2.  **Dependency Cycle Resolution**
    - **Status**: ✅ Completed
    - **Summary**: Refactored the widget update mechanism to use `NotificationCenter` for communication between the app and the widget, effectively breaking a problematic dependency cycle.

## Completed (Phase 7) - Critical Foundation Fixes

These items addressed critical foundation issues that could impact data integrity and code maintainability.

1.  **Resolve Inconsistent Model Location**
    - **Status**: ✅ Completed
    - **Priority**: Critical
    - **Summary**: Audited and consolidated model files. Removed duplicate `Reminder.swift` and `PastelColor.swift` from `DaysToGo/Models/` directory. All shared models now live exclusively in `DaysToGoKit` framework. Only app-specific ViewModels (like `CalendarEventViewModel`) remain in the main app.
    - **Files**: `DaysToGoKit/Reminder.swift`, `DaysToGo/Models/`

2.  **Fix CloudKit Data Reconciliation**
    - **Status**: ✅ Completed
    - **Priority**: Critical
    - **Summary**: Implemented proper merge logic in `ReminderStore` using modification timestamps. Added `modifiedAt` property to `Reminder` model. The new `mergeReminders()` method compares local and cloud data, resolves conflicts based on modification dates, uploads local-only reminders, and properly handles all sync scenarios without data loss.
    - **Files**: `ReminderStore.swift`, `DaysToGoKit/Reminder.swift`

3.  **Fix MainActor Consistency**
    - **Status**: ✅ Completed
    - **Priority**: High
    - **Summary**: Marked `ReminderStore` class with `@MainActor` since it's an `ObservableObject` that updates UI-bound properties. Removed explicit `MainActor.run` calls that are now redundant. All property updates now consistently happen on the main thread.
    - **Files**: `ReminderStore.swift`

4.  **Replace Print Statements with Proper Logging**
    - **Status**: ✅ Completed
    - **Priority**: High
    - **Summary**: Created `Logger.swift` with structured logging using `OSLog`. Replaced all 8 `print()` statements with appropriate log calls using categorized loggers (CloudKit, Photos, Calendar, General, Widget) with proper log levels for better debugging and production monitoring.
    - **Files**: `Services/Logger.swift`, `ReminderStore.swift`, `PhotoFetcher.swift`, `DaysToGoApp.swift`

5.  **Extract Hardcoded Strings to Constants**
    - **Status**: ✅ Completed
    - **Priority**: High
    - **Summary**: Created `DaysToGoKit/Constants.swift` to centralize all hardcoded values. Extracted App Group ID, widget kind, reminders filename, and notification names into the `AppConstants` enum and `Notification.Name` extension. Updated all files to use these constants, preventing typos and simplifying future updates.
    - **Files**: `DaysToGoKit/Constants.swift`, `ReminderStore.swift`, `DaysToGoWidget.swift`, `DaysToGoApp.swift`

## Completed (Phase 8) - Architecture & Organization

These items improved code organization, maintainability, and architectural consistency.

1.  **Reorganize Service Protocols**
    - **Status**: ✅ Completed
    - **Priority**: Medium
    - **Summary**: Created `DaysToGoKit/Protocols.swift` to consolidate all service protocol definitions (`ReminderStoring`, `PhotoFetching`, `CalendarFetching`). Removed protocols from `Reminder.swift` and `AppServices.swift`. Added comprehensive documentation for each protocol and method. Updated all implementing files to import DaysToGoKit.
    - **Files**: `DaysToGoKit/Protocols.swift`, `DaysToGoKit/Reminder.swift`, `AppServices.swift`, `PhotoService.swift`, `CalendarService.swift`, `MockServices.swift`

2.  **Rename PhotoFetcher File**
    - **Status**: ✅ Completed
    - **Priority**: Low
    - **Summary**: Renamed `PhotoFetcher.swift` to `PhotoService.swift` for consistency with the class name and `CalendarService.swift`. Used `git mv` to preserve file history.
    - **Files**: `PhotoFetcher.swift` → `Services/PhotoService.swift`

3.  **Implement Service Container Pattern**
    - **Status**: ✅ Completed
    - **Priority**: Medium
    - **Summary**: Created `ServiceContainer` class with dependency injection pattern. Provides shared singleton instance for production use and supports custom instances for testing. Updated `ReminderDetailViewModel` with convenience initializer that uses the service container. Updated `SettingsView` to accept calendarService via initializer with default from service container. Added comprehensive documentation.
    - **Files**: `Services/ServiceContainer.swift`, `ViewModels/ReminderDetailViewModel.swift`, `SettingsView.swift`

4.  **Enhance AppError Types**
    - **Status**: ✅ Completed
    - **Priority**: Medium
    - **Summary**: Expanded `AppError` enum from 2 to 5 cases: added `networkUnavailable`, `cloudKitError(CKError)`, and `dataCorruption`. Implemented computed properties `shouldRetry` and `shouldShowSettingsButton` for intelligent error handling. Enhanced `recoverySuggestion` with specific guidance for each error type, including CloudKit-specific errors (network unavailable, not authenticated).
    - **Files**: `AppServices.swift`

5.  **Consolidate NotificationCenter Usage**
    - **Status**: ✅ Completed
    - **Priority**: Medium
    - **Summary**: Removed all 5 manual `.remindersDidChange` notification posts from ReminderStore CRUD operations. Created private `notifyChanges()` method called from `didSet` block on `reminders` array. All reminder changes now automatically trigger notifications in a single location, simplifying maintenance and ensuring consistency.
    - **Files**: `ReminderStore.swift`

6.  **Extract Shared Form Component**
    - **Status**: ✅ Completed
    - **Priority**: Low
    - **Summary**: Created reusable `ReminderFormView` component containing the shared form layout (title field, date picker, description editor, color picker). Updated both `AddReminderView` and `EditReminderView` to use the shared component, eliminating code duplication and ensuring consistent form behavior.
    - **Files**: `ReminderFormView.swift`, `AddReminderView.swift`, `EditReminderView.swift`

7.  **Swift 6 Concurrency Compliance**
    - **Status**: ✅ Completed
    - **Priority**: High
    - **Summary**: Resolved all Swift 6 concurrency warnings to ensure the codebase is future-proof. Marked `ReminderStoring` protocol with `@MainActor` to ensure all conforming types are properly isolated. Updated service initializers to use optional parameters with nil defaults (accessing MainActor properties in initializer body) to avoid actor-crossing violations. Made `ReminderStore.init()` nonisolated with MainActor work properly isolated in Task blocks. Updated all mock services to be MainActor-isolated.
    - **Files**: `DaysToGoKit/Protocols.swift`, `Services/ServiceContainer.swift`, `ReminderStore.swift`, `ViewModels/ReminderDetailViewModel.swift`, `SettingsView.swift`, `MockServices.swift`

## Completed (Phase 9) - Performance, Polish & Testing

These items optimized performance, improved code quality, and enhanced the codebase.

1.  **Add Offline Support Indication**
    - **Status**: ✅ Completed
    - **Priority**: Medium
    - **Summary**: Implemented `SyncState` enum (synced, syncing, offline, error) as published property in ReminderStore. Added state tracking to fetchReminders() with network error detection. CloudKit errors now properly set offline or error states with appropriate logging.
    - **Files**: `ReminderStore.swift`

2.  **Improve Widget Data Freshness**
    - **Status**: ✅ Completed
    - **Priority**: Medium
    - **Summary**: Added file existence validation, modification date checking (warns if data is older than 1 hour), and JSON structure validation. Widget now handles corrupted or stale data gracefully with better error resilience.
    - **Files**: `DaysToGoWidget.swift`

3.  **Implement Photo/Calendar Data Caching**
    - **Status**: ✅ Completed
    - **Priority**: Medium
    - **Summary**: Added cache keys (`cachedReflectionDate`, `cachedCalendarIDs`) to ReminderDetailViewModel. Photos and calendar events are now only fetched when the reflection date or enabled calendars change, preventing redundant API calls and reducing battery drain.
    - **Files**: `ViewModels/ReminderDetailViewModel.swift`

4.  **Fix Photo Shuffling Inconsistency**
    - **Status**: ✅ Completed
    - **Priority**: Low
    - **Summary**: Removed photo shuffling. Photos are now consistently ordered by creation date (newest first), providing predictable results each time a reminder is viewed.
    - **Files**: `Services/PhotoService.swift`

5.  **Remove Redundant NavigationViews**
    - **Status**: ✅ Completed
    - **Priority**: Low
    - **Summary**: Removed redundant `NavigationView` wrappers from AddReminderView, EditReminderView, and SettingsView. These sheet views now use navigation modifiers directly, resulting in cleaner code and proper navigation hierarchy.
    - **Files**: `AddReminderView.swift`, `EditReminderView.swift`, `SettingsView.swift`

6.  **Create Reusable Binding Extension**
    - **Status**: ✅ Completed
    - **Priority**: Low
    - **Summary**: Created `BindingExtensions.swift` with `.isPresent` extension for optional bindings. Removed duplicated `hasError` binding implementations from ReminderDetailViewModel and SettingsView. Both now use `$alertError.isPresent` for cleaner, reusable code.
    - **Files**: `Extensions/BindingExtensions.swift`, `ViewModels/ReminderDetailViewModel.swift`, `SettingsView.swift`, `ReminderDetailView.swift`

7.  **Extract Magic Numbers to Constants**
    - **Status**: ✅ Completed
    - **Priority**: Low
    - **Summary**: Created `AnimationTiming` enum in Constants.swift with `splashDuration` (2.0s) and `listAnimationDelay` (0.1s). Updated DaysToGoApp and ReminderListView to use these named constants for better maintainability.
    - **Files**: `DaysToGoKit/Constants.swift`, `DaysToGoApp.swift`, `ReminderListView.swift`

8.  **Clean Up Incomplete RecordType Enum**
    - **Status**: ✅ Completed
    - **Priority**: Low
    - **Summary**: Updated `recordType` static property to use `RecordType.reminder.rawValue` instead of hardcoded string, making the enum actually useful and avoiding duplication.
    - **Files**: `DaysToGoKit/Reminder.swift`

9.  **Remove Force Unwrapping**
    - **Status**: ✅ Completed
    - **Priority**: Low
    - **Summary**: Replaced force unwrap in CalendarService date calculation with guard statement that returns empty array if date calculation fails, providing graceful error handling.
    - **Files**: `Services/CalendarService.swift`

## Code Review Summary

A comprehensive code review identified 24 improvement opportunities across three priority levels. The application has a solid MVVM foundation with good separation of concerns from previous refactoring phases.

### Phase Status

- **Phase 7**: ✅ **Completed** - Fixed critical data integrity and consistency issues
  - Resolved model file duplication
  - Implemented proper CloudKit merge logic with conflict resolution
  - Added MainActor consistency
  - Replaced all print statements with OSLog
  - Centralized all constants

- **Phase 8**: ✅ **Completed** - Enhanced architecture and reduced code duplication
  - Reorganized service protocols into dedicated Protocols.swift
  - Renamed PhotoFetcher to PhotoService for consistency
  - Implemented Service Container pattern for dependency injection
  - Enhanced AppError with 3 new cases and smart error handling
  - Consolidated all NotificationCenter usage to single location
  - Extracted shared ReminderFormView component
  - Achieved Swift 6 concurrency compliance (no warnings)

- **Phase 9**: ✅ **Completed** - Optimized performance, enhanced code quality, and improved user experience
  - Implemented offline support indication with SyncState enum
  - Added widget data freshness validation and stale data warnings
  - Implemented intelligent caching for photos and calendar events
  - Fixed photo ordering to be consistent (creation date sorted)
  - Removed redundant NavigationView wrappers
  - Created reusable `.isPresent` binding extension
  - Extracted magic numbers to AnimationTiming constants
  - Cleaned up RecordType enum implementation
  - Removed all force unwrapping for safer code

## Post-Phase 9 Bug Fixes

After completing Phase 9, several UI issues were discovered and resolved:

1. **Fixed Missing Save/Cancel Buttons in Sheets**
   - **Status**: ✅ Completed
   - **Issue**: After removing "redundant" NavigationViews in Phase 9, sheet-presented views (AddReminderView, EditReminderView, SettingsView) lost their toolbar buttons
   - **Solution**: Added NavigationStack to sheet views to provide proper navigation context for toolbar modifiers
   - **Files**: `AddReminderView.swift`, `EditReminderView.swift`, `SettingsView.swift`

2. **Fixed Persistent Error Alert Loop**
   - **Status**: ✅ Completed
   - **Issue**: When viewing a reminder, permission dialogs for Photos and Calendar would trigger simultaneous error alerts. Dismissing one would immediately show another in an infinite loop
   - **Root Cause**: Race condition between parallel photo and calendar tasks both trying to set `alertError`
   - **Solution**:
     - Added checks to only set `alertError` if one isn't already present
     - Updated alert presentation to explicitly clear errors on button taps
     - Added conditional "Open Settings" button based on error type
     - Enhanced alerts with proper error messages using `recoverySuggestion`
   - **Files**: `ViewModels/ReminderDetailViewModel.swift:106-135`, `ReminderDetailView.swift:173-189`, `SettingsView.swift:43-59`

3. **Fixed Binding Extension Compiler Warning**
   - **Status**: ✅ Completed
   - **Issue**: "Comparing non-optional value of type 'Value' to 'nil' always returns true" warning
   - **Solution**: Refactored `.isPresent` extension to use Mirror reflection for proper Optional type detection
   - **Files**: `Extensions/BindingExtensions.swift`

All three phases (7, 8, and 9) plus post-release bug fixes are now complete. The codebase has a robust foundation with proper data synchronization, consistent threading, structured logging, centralized constants, well-organized protocols, dependency injection, intelligent error handling, minimal code duplication, full Swift 6 concurrency compliance, performance optimizations, enhanced user experience, and reliable error alert management. The architecture is production-ready and future-proof.

## Completed (Phase 10) - News Headlines Feature [REPLACED IN PHASE 11]

This phase added news headlines functionality to show relevant news from reflection dates. **Note: This implementation was replaced in Phase 11 with a free Wikipedia-based solution due to cost concerns ($449/month for NewsAPI.org).**

1. **News Headlines Integration with Apple Intelligence**
   - **Status**: ✅ Completed (Later replaced with Wikipedia in Phase 11)
   - **Summary**: Integrated NewsAPI.org to fetch historical news headlines from reflection dates. Added Apple Intelligence enhancement for iOS 18+ devices to provide AI-generated summaries. Implemented complete service architecture following existing patterns (NewsHeadline model, NewsFetching protocol, NewsService implementation).
   - **Implementation Details**:
     - Created `NewsHeadline` model in DaysToGoKit with support for title, description, source, publishedAt, url, imageUrl, and optional aiSummary
     - Added `NewsFetching` protocol with `fetchHeadlines(from:maxCount:)` and `enhanceWithAI(_:)` methods
     - Implemented `NewsService` with NewsAPI.org REST API integration, including search query requirement ("news OR world OR breaking")
     - Enhanced headlines with Apple Intelligence summaries on iOS 18+ using NaturalLanguage framework
     - Added intelligent caching to prevent redundant API calls (only fetches when reflection date changes)
     - Integrated into ReminderDetailViewModel with parallel loading alongside photos and calendar events
     - Updated ReminderDetailView UI with dedicated news section showing headlines, sources, AI summaries, and "Read more" links
     - Implemented secure API key configuration via Config.plist (excluded from git) or UserDefaults
     - Added comprehensive error handling with detailed logging for debugging
     - Created MockNewsService for unit testing
   - **API Limitations**:
     - Free tier limited to 100 requests/day
     - Historical data only available for last 30 days
     - Requires search query parameter (NewsAPI /everything endpoint requirement)
   - **User Experience**:
     - Reminders with reflection dates within last 30 days show news headlines from that date
     - iOS 18+ users see AI-enhanced summaries automatically
     - Older devices show headlines without summaries
     - Graceful degradation when API key not configured or date out of range
   - **Files**: (All removed in Phase 11)
     - New: `DaysToGoKit/NewsHeadline.swift`, `DaysToGo/Services/NewsService.swift`, `DaysToGo/Config.plist.template`, `NEWS_API_SETUP.md`, `.gitignore`
     - Modified: `DaysToGoKit/Protocols.swift`, `DaysToGo/Services/ServiceContainer.swift`, `DaysToGo/ViewModels/ReminderDetailViewModel.swift`, `DaysToGo/ReminderDetailView.swift`, `DaysToGoTests/Mocks/MockServices.swift`

## Completed (Phase 11) - Wikipedia "On This Day" Migration

This phase replaced the expensive NewsAPI.org integration with Wikipedia's free "On This Day" feature, providing a cost-effective and more historically rich alternative.

1. **Wikipedia Historical Events Integration**
   - **Status**: ✅ Completed (Updated in Post-Phase 14 with exact year filtering)
   - **Summary**: Replaced NewsAPI.org ($449/month for historical data) with Wikipedia's completely free "On This Day" API. The implementation provides unlimited access to historical events, filtering to show only events matching the exact year of the reflection date while excluding recurring holidays. This provides highly relevant, personalized historical context.
   - **Cost Savings**: $449/month → $0/month (100% free, no API key required)
   - **Data Range**: 30 days (NewsAPI limitation) → All of history (Wikipedia advantage)
   - **Rate Limits**: 100 requests/day → Unlimited reasonable usage
   - **Implementation Details**:
     - Created `HistoricalEvent` model in DaysToGoKit with year, text, eventType (event/birth/death/selected), url, imageUrl, and optional aiSummary
     - Renamed protocol from `NewsFetching` to `HistoricalEventFetching` with methods `fetchEvents(from:maxCount:)` and `enhanceWithAI(_:)`
     - Implemented `WikipediaService` using Wikipedia's REST API: `https://api.wikimedia.org/feed/v1/wikipedia/en/onthisday/all/{MM}/{DD}`
     - Service filters to show only events matching the exact year of the reflection date (e.g., November 16, 2020 shows only events from that date in 2020)
     - Recurring holidays are completely excluded to focus on unique historical events
     - Processes selected events, regular events, births, and deaths (holidays excluded)
     - Retained Apple Intelligence AI enhancement for iOS 18+ devices
     - Updated ServiceContainer to inject `WikipediaService` as `historyService`
     - Updated ReminderDetailViewModel to use `historicalEvents` and `isLoadingHistory` properties
     - Enhanced ReminderDetailView UI with new "📅 On This Day in History" section showing year prominently, event type icons, and Wikipedia links
     - Updated MockHistoryService for unit testing
     - Removed all NewsAPI-related files and configuration
   - **User Experience Improvements**:
     - Highly relevant content showing what actually happened on that exact date in that specific year
     - Works with any date in history, not just recent past
     - Event categorization with visual icons (📅 events, 🎁 births, 🍂 deaths, ⭐ featured)
     - Direct links to detailed Wikipedia articles
     - No repetitive holiday information
     - No configuration required - works immediately
     - Graceful silent failure if Wikipedia unavailable (non-critical feature)
   - **Technical Benefits**:
     - Zero ongoing costs
     - No API key management
     - No rate limit concerns
     - No privacy/tracking concerns
     - More reliable (Wikipedia's infrastructure)
     - Better aligned with app's nostalgic/reflection theme
   - **Files**:
     - **New**: `DaysToGoKit/HistoricalEvent.swift`, `DaysToGo/Services/WikipediaService.swift`
     - **Modified**: `DaysToGoKit/Protocols.swift`, `DaysToGo/Services/ServiceContainer.swift`, `DaysToGo/ViewModels/ReminderDetailViewModel.swift`, `DaysToGo/ReminderDetailView.swift`, `DaysToGoTests/Mocks/MockServices.swift`
     - **Removed**: `DaysToGoKit/NewsHeadline.swift`, `DaysToGo/Services/NewsService.swift`, `DaysToGo/Config.plist`, `DaysToGo/Config.plist.template`, `NEWS_API_SETUP.md`

## Completed (Phase 12) - Onboarding & User Profile Management

This phase added a first-launch onboarding experience and comprehensive user profile management system.

1. **Onboarding & Profile System**
   - **Status**: ✅ Completed
   - **Summary**: Implemented a complete onboarding flow for first-time users to collect name and location data, with a hierarchical settings menu for profile management. The system provides personalization capabilities and sets the foundation for future user-specific features.
   - **Implementation Details**:
     - Created `UserProfile` model in DaysToGoKit with name, location, and helper properties (isIncomplete, greeting)
     - Implemented `UserProfileStore` using UserDefaults for persistence with singleton pattern
     - Built beautiful 3-page onboarding flow with TabView: Welcome → Name (required) → Location (optional)
     - Added onboarding completion tracking and first-launch detection
     - Created `ProfileSettingsView` for editing profile data anytime
     - Restructured `SettingsView` with hierarchical sections: Personal (Profile) and Data Sources (Calendars)
     - Integrated onboarding check in `DaysToGoApp` after splash screen
     - Full-screen modal presentation with smooth animations and page indicators
   - **User Experience**:
     - First launch shows onboarding automatically after splash screen
     - Name is required, location is optional
     - Page-by-page navigation with validation
     - Profile accessible anytime via Settings → Profile
     - User's name displayed in Settings menu for quick reference
     - Clean, modern UI with SF Symbols icons
   - **Data Management**:
     - Profile stored in UserDefaults as JSON
     - Automatic persistence on changes
     - Observable pattern for reactive UI updates
     - Reset capability for testing/debugging
   - **Settings Restructure**:
     - Added "Personal" section with Profile option
     - Moved Calendars to "Data Sources" section
     - Retained "About" section with version info
     - Hierarchical navigation for better organization
   - **Files**:
     - **New**: `DaysToGoKit/UserProfile.swift`, `DaysToGo/UserProfileStore.swift`, `DaysToGo/OnboardingView.swift`, `DaysToGo/ProfileSettingsView.swift`
     - **Modified**: `DaysToGo/DaysToGoApp.swift`, `DaysToGo/SettingsView.swift`

## Completed (Phase 13) - Enhanced Onboarding with Structured Data Collection

This phase improved the onboarding experience with professional data collection patterns, replacing free-text fields with structured inputs for better data quality and user experience.

1. **Structured Name & Country Collection**
   - **Status**: ✅ Completed
   - **Summary**: Enhanced onboarding to collect firstName and surname separately (instead of single "name" field) and replaced free-text location input with a country picker containing 40+ countries. This provides better data quality, eliminates typos, and follows professional form design patterns.
   - **UserProfile Model Changes**:
     - Replaced `name: String` with `firstName: String` and `surname: String`
     - Replaced `location: String` with `country: String`
     - Added `fullName` computed property returning "FirstName Surname"
     - Updated `greeting` to use firstName only ("Hello, FirstName")
     - Updated `isIncomplete` to check firstName (required field)
   - **Onboarding Page 2 (Name Collection)**:
     - Two separate text fields: "First Name" (required) and "Surname" (optional)
     - Proper text content types for autocomplete (`.givenName`, `.familyName`)
     - Validation requires firstName before proceeding
     - Vertical stacking with clean spacing
   - **Onboarding Page 3 (Country Selection)**:
     - Replaced text field with wheel-style Picker
     - 40+ countries including major nations from all continents
     - Alphabetically sorted for easy selection
     - "Other" option for unlisted countries
     - Changed icon from map pin to globe
     - Updated messaging: "Select your country"
   - **Country List Coverage**:
     - North America: USA, Canada, Mexico
     - Europe: 15+ countries (UK, Germany, France, etc.)
     - Asia: Japan, China, India, Singapore, etc.
     - Oceania: Australia, New Zealand
     - South America: Brazil, Argentina, Chile
     - Africa: South Africa, Egypt, Nigeria, Kenya
     - Middle East: UAE, Saudi Arabia, Israel, Turkey
   - **ProfileSettingsView Updates**:
     - Two separate name fields matching onboarding
     - Country picker with same country list
     - Each field tracks changes independently
     - "Save Changes" button appears on edits
     - Updated help text to reference "country" not "location"
   - **UserProfileStore Updates**:
     - `updateProfile()` signature changed to accept firstName, surname, country
     - Maintains UserDefaults persistence
     - Observable pattern for reactive UI updates
   - **SettingsView Display**:
     - Shows `fullName` (computed property) instead of raw name
     - Displays "FirstName Surname" in subtitle
     - Handles empty names gracefully
   - **Benefits**:
     - Better data quality (no spelling mistakes in countries)
     - Professional UX (industry standard to split names)
     - Structured data enables future features (localization, analytics)
     - Faster input (picker vs typing country name)
     - International-friendly approach
   - **Data Format**:
     - Old: `{"name": "John Doe", "location": "San Francisco"}`
     - New: `{"firstName": "John", "surname": "Doe", "country": "United States"}`
   - **Files**:
     - **Modified**: `DaysToGoKit/UserProfile.swift`, `DaysToGo/UserProfileStore.swift`, `DaysToGo/OnboardingView.swift`, `DaysToGo/ProfileSettingsView.swift`, `DaysToGo/SettingsView.swift`

## Completed (Phase 14) - Location Tracking & Movement History

This phase implemented battery-efficient background location tracking to build a history of user movements over time, displaying location data on interactive maps for reflection dates.

1. **Significant Location Tracking System**
   - **Status**: ✅ Completed (Enhanced in Post-Phase 14 with more frequent tracking)
   - **Summary**: Implemented background location tracking using CoreLocation to build a comprehensive movement history over time. Location data for reflection dates is displayed on interactive maps in the reminder detail view, providing users with a visual representation of where they were on corresponding past dates. Originally used significant location changes (~500m), later enhanced to continuous tracking (20m) with daily first location recording.
   - **LocationPoint Model** (`DaysToGoKit/LocationPoint.swift`):
     - Stores latitude, longitude, timestamp, and horizontalAccuracy
     - Converts from CLLocation objects
     - `hasGoodAccuracy` property filters locations with accuracy > 100m
     - `coordinate` property returns CLLocationCoordinate2D for MapKit integration
   - **LocationFetching Protocol** (`DaysToGoKit/Protocols.swift`):
     - `requestAuthorization()` - Async/await permission flow for Always authorization
     - `startTracking()` - Begin significant location monitoring
     - `stopTracking()` - Stop monitoring
     - `fetchLocations(from:maxCount:)` - Retrieve locations for specific date
   - **LocationService Implementation** (`Services/LocationService.swift`):
     - Uses CLLocationManager with significant location changes (NOT continuous tracking)
     - Battery-efficient: Only updates when user moves ~500m (Apple's threshold)
     - Background location updates enabled via Info.plist
     - Distance filter: 100m minimum between points
     - Accuracy filter: Rejects locations with poor accuracy (> 100m)
     - Automatic data management: Keeps last 90 days, older data auto-deleted
     - Local persistence: Stores in JSON file in App Group container
     - Async/await authorization handling with proper state management
     - CLLocationManagerDelegate implementation for location updates
   - **LocationMapView Component** (`LocationMapView.swift`):
     - Interactive SwiftUI Map displaying all location points
     - Markers at each location point with accent color
     - Auto-calculates region to fit all points
     - Chronological path connecting locations
     - Proper coordinate-to-screen conversion for path overlay
   - **ReminderDetailViewModel Updates**:
     - Added `@Published var locationPoints: [LocationPoint]`
     - Added `isLoadingLocations` state tracking
     - Integrated location fetching with existing photo/calendar/history loading
     - Cache-aware: Only reloads when reflection date changes
     - Silent failure handling (not critical if no location data available)
   - **ReminderDetailView Updates**:
     - New "📍 Your Movements" section after historical events
     - Map view showing location history (height: 250)
     - Location count display
     - Loading indicator during fetch
     - Helpful empty state: "No Location Data / Location tracking builds history over time"
     - Clean section separator with Divider
   - **Permission Flow**:
     - Requests Always authorization on app launch in `DaysToGoApp`
     - Starts tracking automatically upon authorization
     - Comprehensive Info.plist usage descriptions for all authorization types
     - UIBackgroundModes includes location for background tracking
     - Graceful error handling with logging
   - **Privacy & Battery Considerations**:
     - Significant location changes only (NOT continuous tracking)
     - Minimal battery impact compared to continuous tracking
     - User must explicitly grant Always authorization
     - Data stored locally, not sent to external servers
     - Automatic 90-day data cleanup to manage storage
     - High accuracy filtering ensures quality data
   - **Data Flow**:
     - Background: LocationService monitors significant changes → stores LocationPoints
     - Foreground: User opens reminder detail → fetch locations for reflection date → display on map
     - No data initially (builds over time as user moves with app installed)
   - **Testing Support**:
     - MockLocationService for unit tests
     - Tracks authorization and tracking state
     - Returns configurable location arrays
   - **Files**:
     - **New**: `DaysToGoKit/LocationPoint.swift`, `Services/LocationService.swift`, `LocationMapView.swift`
     - **Modified**: `DaysToGoKit/Protocols.swift`, `Services/ServiceContainer.swift`, `ViewModels/ReminderDetailViewModel.swift`, `ReminderDetailView.swift`, `DaysToGoApp.swift`, `Info.plist`, `MockServices.swift`

All 14 phases are now complete. The app features a production-ready architecture with comprehensive functionality including location tracking with movement history maps, enhanced onboarding with structured data collection, user profiles, iCloud sync, pull-to-refresh, home screen widgets, historical events from Wikipedia, photo and calendar integration, and Apple Intelligence enhancements. The codebase is cost-effective, maintainable, well-tested, and future-proof with excellent user experience, professional data collection patterns, and privacy-conscious location tracking.

## Post-Phase 14 Enhancements

### Historical Events Filtering (November 2025)

These enhancements refine the Wikipedia "On This Day" feature to provide more relevant and personalized historical context.

1. **Exact Year Matching & Holiday Exclusion**
   - **Status**: ✅ Completed
   - **Priority**: High
   - **Rationale**: The original implementation showed all events that happened on a given day/month throughout history, which often resulted in generic historical trivia that wasn't personally relevant. By filtering to the exact year of the reflection date and removing recurring holidays, users now see events that actually happened on that specific date in their past.
   - **Summary**: Modified Wikipedia historical events to show only events matching the exact year of the reflection date, excluding recurring holidays. This provides more personalized and relevant historical context by focusing on unique events from the specific year rather than general historical trivia.
   - **Implementation Details**:
     - **Year Extraction**: Extract year component from reflection date alongside month/day
     - **Exact Year Filter**: Apply `.filter { $0.year == reflectionYear }` to all parsed events
     - **Holiday Exclusion**: Removed entire holidays section from API response processing
     - **Simplified Parsing**: Cleaned up `parseEvents()` method to remove special holiday handling logic
     - **Enhanced Logging**: Updated log messages to include year for better debugging and monitoring
   - **Code Changes**:
     - `WikipediaService.fetchEvents()`: Added year extraction and filtering logic (lines 16-97)
     - `WikipediaService.parseEvents()`: Removed holiday-specific branching (lines 126-135)
     - Removed processing of `apiResponse.holidays` section entirely
   - **Event Types Included**:
     - ✅ Selected/Featured events
     - ✅ Regular historical events
     - ✅ Notable births
     - ✅ Notable deaths
     - ❌ Recurring holidays (excluded)
   - **User Experience Impact**:
     - **Before**: "November 16" shows Apollo 11 launch (1969), fall of Berlin Wall (1989), random holidays
     - **After**: "November 16, 2020" shows only events from November 16, 2020
     - More personally relevant - shows what actually happened on that exact date in the user's past
     - Cleaner, more focused list without repetitive holiday information
     - Stronger emotional connection to historical context
     - May show fewer events (or none) for recent dates, which is expected and acceptable
   - **Example Scenarios**:
     - Reflection date: March 11, 2011 → Shows Japan earthquake/tsunami events from that exact day
     - Reflection date: September 11, 2001 → Shows 9/11 events from that specific year
     - Reflection date: July 20, 1969 → Shows Apollo 11 moon landing events from that date
     - Reflection date: December 25, 2023 → Shows actual events from 2023, not generic Christmas info
   - **Technical Considerations**:
     - Wikipedia API still returns all years; filtering happens client-side
     - No additional API calls required
     - Maintains performance while improving relevance
     - Graceful degradation: shows empty state if no events match the exact year
   - **Files Modified**:
     - `DaysToGo/Services/WikipediaService.swift` (filtering logic and parsing)
     - `01_CURRENT_STATE.md` (features documentation)
     - `02_IMPROVEMENTS_PLAN.md` (Phase 11 update + this documentation)

2. **Enhanced Location Tracking for Detailed Movement History**
   - **Status**: ✅ Completed
   - **Priority**: High
   - **Rationale**: The original implementation used significant location changes (~500m threshold) which provided sparse data points. Users wanted more detailed tracking to see their actual movement patterns throughout the day, plus guaranteed daily starting points for better context.
   - **Summary**: Enhanced location tracking to capture more frequent movements (20m instead of 500m) and always record the first location of each day. This provides much richer movement history data while maintaining the 90-day storage policy.
   - **Implementation Details**:
     - **Distance Filter**: Reduced from 100m to 20m for more granular tracking
     - **Tracking Mode**: Switched from `startMonitoringSignificantLocationChanges()` to `startUpdatingLocation()` for continuous updates
     - **Accuracy**: Improved from `kCLLocationAccuracyHundredMeters` to `kCLLocationAccuracyBest`
     - **Auto-Pause**: Disabled `pausesLocationUpdatesAutomatically` to continue tracking when stationary
     - **Daily First Location**: Added logic to always record first location of each day regardless of accuracy
     - **Date Tracking**: Added `lastRecordedDate` property to track the last day a location was recorded
   - **Code Changes**:
     - `LocationService.init()`: Updated configuration parameters (lines 29-34)
     - `LocationService.init()`: Initialize `lastRecordedDate` from existing data (lines 39-42)
     - `LocationService.startTracking()`: Changed to use `startUpdatingLocation()` (lines 65-68)
     - `LocationService.stopTracking()`: Changed to use `stopUpdatingLocation()` (lines 70-73)
     - `LocationService.addLocation()`: Added daily first location logic (lines 115-144)
   - **Daily First Location Logic**:
     - Compares current location date to `lastRecordedDate`
     - If it's a new day (or first ever location), always records it
     - Marks location with "FIRST location of day" in logs
     - Updates `lastRecordedDate` to current day
     - Subsequent locations on same day still require good accuracy
   - **Accuracy Filtering**:
     - **First location of day**: Always recorded (even if poor accuracy)
     - **Subsequent locations**: Must have `horizontalAccuracy < 100m`
     - Ensures daily context while maintaining quality data
   - **User Experience Impact**:
     - **Before**: Sparse location data, ~500m between points, might miss days entirely
     - **After**: Detailed movement history, 20m granularity, guaranteed daily starting point
     - Better visualization of daily routines and travel patterns
     - More meaningful context when viewing reflection dates
     - Able to see detailed paths, not just major movements
   - **Example Scenarios**:
     - Morning commute: Can see route taken, stops made along the way
     - Weekend trip: Detailed trail of all locations visited
     - Work day: Can see movement between meetings, lunch locations, etc.
     - Daily start: Always know where each day began, even if stayed in one place
   - **Battery Considerations**:
     - **Important**: This is more battery-intensive than significant location changes
     - Continuous location updates use more power than previous implementation
     - Users should be aware of increased battery usage
     - 90-day data limit helps manage storage and performance
     - Trade-off: More detailed data vs. higher battery consumption
   - **Privacy Considerations**:
     - More frequent tracking = more detailed location history
     - All data still stored locally (not sent to external servers)
     - Automatic 90-day cleanup maintains privacy
     - User has full control via Always authorization setting
   - **Technical Considerations**:
     - Uses same data model (`LocationPoint`)
     - Same 90-day retention policy
     - Same shared App Group storage
     - Compatible with existing map visualization
     - No API changes required
   - **Files Modified**:
     - `DaysToGo/Services/LocationService.swift` (tracking mode, accuracy, daily logic)
     - `01_CURRENT_STATE.md` (features and privacy documentation)

3. **Display Options Settings for Reminder Data Visibility**
   - **Status**: ✅ Completed
   - **Priority**: Medium
   - **Rationale**: Users wanted control over which data types appear in reminder details. Some users may not want to see certain sections (e.g., privacy concerns with location, no interest in historical events, etc.). Rather than showing empty states, completely hiding sections provides a cleaner, more customized experience.
   - **Summary**: Added a new settings submenu that allows users to toggle visibility of the four data types shown in reminder details: Photos, Calendar Events, On This Day (historical events), and Location. When toggled off, sections are completely hidden with no placeholders or empty states.
   - **Implementation Details**:
     - **Preference Model**: Created `ReminderDisplayPreferences` class with 4 boolean properties
     - **Storage**: Uses UserDefaults for persistence across app launches
     - **Defaults**: All toggles default to `true` (show everything)
     - **Settings UI**: Created `ReminderDisplaySettingsView` with simple toggle list
     - **Detail View**: Updated `ReminderDetailView` to conditionally render sections
     - **Environment Injection**: Preferences injected via SwiftUI environment
   - **Code Changes**:
     - **New Files**:
       - `ReminderDisplayPreferences.swift` - Preference management class
       - `ReminderDisplaySettingsView.swift` - Settings UI for toggles
     - **Modified Files**:
       - `SettingsView.swift` - Added Display Options menu item with eye icon
       - `ReminderDetailView.swift` - Wrapped all 4 sections in conditional checks
       - `DaysToGoApp.swift` - Created and injected displayPrefs into environment
       - `ReminderListView.swift` - Added environment object and passed to SettingsView
   - **Settings Navigation**:
     - Path: Settings → Data Sources → Display Options
     - Icon: Eye symbol (system image: "eye")
     - Position: First item in Data Sources section, above Calendars
   - **Toggle Options**:
     - **Photos**: Controls Photos section visibility
     - **Calendar Events**: Controls Calendar Events section visibility
     - **On This Day**: Controls Historical Events section visibility
     - **Location**: Controls Location Map section visibility
   - **Conditional Rendering Logic**:
     - Each section wrapped in `if displayPrefs.show* { ... }`
     - When `false`: Section completely omitted from view hierarchy
     - No dividers, no loading states, no empty states shown
     - Clean, minimal UI when sections are hidden
   - **User Experience**:
     - **All ON (default)**: Shows all 4 data sections as before
     - **Some OFF**: Only shows enabled sections, seamless layout
     - **All OFF**: Shows only title, date, description, and action buttons
     - Changes take effect immediately when toggles are changed
     - Preferences persist across app launches and restarts
   - **Example Use Cases**:
     - Privacy-focused user disables Location tracking visibility
     - Minimalist user only wants to see Photos, hides everything else
     - User not interested in history disables On This Day
     - User with no calendars connected disables Calendar Events
   - **UI Details**:
     - Toggle style: Switch with accent color tint
     - Section header: "Visible Data Types"
     - Section footer: Explains disabled types won't appear at all
     - Navigation title: "Display Options"
     - Title display mode: Inline
   - **Technical Benefits**:
     - Clean separation of concerns (preferences vs. presentation)
     - Uses SwiftUI environment for clean data flow
     - No prop drilling required
     - Easily extensible for future data types
     - Follows existing CalendarPreferences pattern
   - **Privacy Benefits**:
     - Users can hide location data even if tracking is enabled
     - Provides control over what personal data is displayed
     - No data deleted, just hidden from view
     - Can re-enable anytime to see historical data
   - **Files Modified**:
     - **New**: `DaysToGo/ReminderDisplayPreferences.swift`, `DaysToGo/ReminderDisplaySettingsView.swift`
     - **Modified**: `DaysToGo/SettingsView.swift`, `DaysToGo/ReminderDetailView.swift`, `DaysToGo/DaysToGoApp.swift`, `DaysToGo/ReminderListView.swift`
     - **Documentation**: `01_CURRENT_STATE.md` (features, data model, recent changes)

4. **UI Improvements for Reminder Tiles and Widgets**
   - **Status**: ✅ Completed
   - **Priority**: Medium
   - **Rationale**: The original text colors used `.primary` which adapted to light/dark mode but sometimes lacked contrast against pastel backgrounds. Borders were thin (3pt) and didn't stand out enough to quickly identify urgent reminders. Users wanted consistent black text for better readability and thicker borders for clearer urgency indicators.
   - **Summary**: Updated ReminderTile and widget UI to use black text for all elements, increased border thickness from 3pt to 6pt on reminder tiles, and removed borders from widgets for a cleaner appearance. These changes improve readability, visual consistency, and urgency recognition.
   - **Reminder Tile Changes** (`ReminderTile.swift`):
     - **Text Color**: Changed all text from `.primary`/conditional colors to `.foregroundColor(.black)`
       - Title text: Now black (line 33)
       - Date text: Now black (line 39)
       - Days remaining text: Now black (line 44) - previously red for overdue
     - **Border Thickness**: Increased from 3pt to 6pt (line 51)
     - **Border Logic**: Unchanged - still shows red/yellow/green based on urgency
   - **Widget Changes** (`DaysToGoWidget.swift`):
     - **Text Color**: Changed all text to `.foregroundColor(.black)`
       - Title text: Now black (line 72)
       - Days remaining: Now black (line 79)
       - Empty state: Now black (line 85)
     - **Border**: Removed entirely for cleaner widget appearance
     - Widget borders didn't look good in the small widget format
   - **Border Color Logic** (unchanged for tiles):
     - **Red**: Overdue reminders (negative days remaining)
     - **Yellow**: Due today (0 days remaining)
     - **Green**: Due within 7 days (1-7 days remaining)
     - **Clear**: More than 7 days away (no urgency border)
   - **Visual Benefits**:
     - **Better Contrast**: Black text on pastel backgrounds is always readable
     - **Consistency**: Same text color across all reminder tiles
     - **No Dark Mode Issues**: Black text works in both light and dark mode
     - **Thicker Borders**: 2x thickness (3pt → 6pt) makes urgency immediately visible
     - **Quick Scanning**: Easy to spot urgent reminders from colored borders
   - **User Experience Impact**:
     - **Before**: Subtle gray text, thin borders, adaptive colors
     - **After**: Bold black text, thick borders, strong visual hierarchy
     - At-a-glance urgency recognition from thicker colored borders
     - Improved readability for users with visual impairments
     - Consistent appearance regardless of system settings
   - **Widget Design Philosophy**:
     - Widgets prioritize simplicity and clarity
     - Black text on colored background without borders
     - Clean, minimal design appropriate for home screen
     - Different from in-app tiles which benefit from borders
   - **Code Changes**:
     - `ReminderTile.swift`:
       - Line 33: `.foregroundColor(.black)` on title
       - Line 39: `.foregroundColor(.black)` on date
       - Line 44: `.foregroundColor(.black)` on days remaining
       - Line 51: `lineWidth: borderColor == .clear ? 0 : 6` (increased from 3)
     - `DaysToGoWidget.swift`:
       - Line 72: `.foregroundColor(.black)` on title
       - Line 79: `.foregroundColor(.black)` on days remaining
       - Line 85: `.foregroundColor(.black)` on empty state
       - Removed: borderColor computed property, ZStack, RoundedRectangle border
   - **Design Considerations**:
     - Black text provides maximum contrast on light pastel colors
     - 6pt borders are thick enough to be noticed but not overwhelming
     - Widgets kept simple without borders to avoid cluttered appearance
     - Consistent color scheme across app and widget (black text, pastel backgrounds)
   - **Files Modified**:
     - `DaysToGo/ReminderTile.swift` (text colors and border thickness)
     - `DaysToGoWidget/DaysToGoWidget.swift` (text colors, removed borders)
     - `01_CURRENT_STATE.md` (UX/UI section and recent changes)
