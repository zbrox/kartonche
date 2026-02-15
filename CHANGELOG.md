# Changelog

All notable changes to kartonche will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Miscellaneous Tasks

- Bump version to 2026.02.6

## [2026.02.6] - 2026-02-15

### Bug Fixes

- Add architecture to simulator destination to avoid ambiguity
- Remove -quiet flag to show build errors in CI
- Add comprehensive debugging for CI build failures
- Install librsvg for About icon generation
- Add imagemagick to mise and install librsvg via brew
- Install librsvg and imagemagick via Homebrew
- Remove brittle tests and update merchant validation
- Add ControlIntents and AppIntent to main app target
- Add @MainActor to CardEntityQuery methods for Swift 6
- Search field interaction with SwiftUI .searchable
- Open Settings for Always permission upgrade
- Handle URLs pending before .onChange registers on cold launch
- Dismiss active sheets before handling incoming URLs
- Fix control widget intents not navigating to cards
- Rewrite image crop rendering to fix incorrect crop region
- Move card name to header when strip image present
- Replace deprecated Text concatenation with interpolation
- Use zero-padded month and skip existing What's New entries

### Documentation

- Update CHANGELOG for v2026.02.5
- Update ARCHITECTURE.md to reflect current implementation
- Remove stale test counts, fix dependencies, add CI badges

### Features

- Add automated release workflow with mise
- Add argument support for running specific tests
- Add Quick Look preview and file import for .kartonche files
- Add tap-to-preview for cards during import
- Add Data section with import/export support
- Show card list for multi-card files
- Add Apple Wallet pass generation with on-device signing
- Improve pass appearance and add card image support
- Make storeName optional and add cardholderName field
- Display cardholderName in all card views
- Add required field indicators and fix image button UX
- Include notes in pass back fields
- Add 2026.02.6 release notes

### Miscellaneous Tasks

- Migrate to Swift 6 language mode
- Add localization strings for export and multi-card preview
- Apply Xcode recommended project settings
- Update translations

### Refactoring

- Simplify LaunchAppIntent to rely on openAppWhenRun
- Rename widget target and folder for consistency
- Rename FileImportManager to URLRouter

## [2026.02.5] - 2026-02-08

### Bug Fixes

- Add missing container backgrounds and inline widget for lock screen
- Add complete iOS simulator destination specs
- Remove invalid 'version: latest' from mise-action

### Features

- Add appearance section with color preview and secondary color customization
- Redesign card barcode display with prominent brand colors
- Add control widgets for Control Center and lock screen
- Add swipe actions for edit and favorite in card list
- Switch to macos-26 runner with iPhone 17 Pro simulator

### Miscellaneous Tasks

- Prepare widgets for i18n
- Bump version to 2026.02.5

### Refactoring

- Consolidate Color extensions into shared utility file

## [2026.02.4] - 2026-02-08

### Bug Fixes

- Improve Bulgarian translations for permission views
- Use Apple's official Bulgarian term for widgets
- Add LSSupportsOpeningDocumentsInPlace to Info.plist
- Replace deprecated placemark API and remove unnecessary await
- Remove unnecessary await in CardListView
- Add iOS Simulator destination to build task
- Migrate from deprecated CLGeocoder to MKReverseGeocodingRequest
- Prevent permission sheet content from being cropped at top
- Configure git to use HTTPS for SPM dependencies

### Documentation

- Add TODO for GeocodingService deprecation
- Update README and CHANGELOG for v2026.02
- Update What's New with 2026.02.4 features

### Features

- Overhaul location editor with map picker and flexible search
- Fix nearest location widget and add Always permission flow
- Add card export/import with AirDrop sharing
- Add notification reminders for expiring cards
- Add notification settings UI
- Unify permission request flow with custom explanation views
- Add localized permission descriptions for iOS dialogs
- Add AppIcon.icon bundle
- Add document icon for .kartonche file type
- Add xcbeautify for pretty warnings and errors
- Add 'mise run check' task for comprehensive warning detection
- Add 'mise run check-i18n' task for localization validation
- Refactor to English keys and complete Bulgarian translations
- Add 'Show Expired' filter toggle in card list
- Add location permission request flow in Settings
- Add location-based nearby card notifications
- Add About page, settings refactor, and empty state onboarding
- Add confetti celebration when adding first card
- Run full tests only on tags, unit tests otherwise
- Add collapsible notes section to card display view
- Verify merchant data and add country field
- Generate About icon from SVG layers at build time
- Add merchant template generation as build phase
- Add delete confirmation dialog to card list

### Miscellaneous Tasks

- Remove TODO
- Update CI to use macOS 15 with Xcode 26.2
- Limit app to iPhone only
- Update version to 2026.02.4

### Refactoring

- Simplify CI workflows to use mise tasks
- Make i18n check support multiple languages dynamically

## [2026.02.3] - 2026-02-07

### Bug Fixes

- Resolve deprecation warnings for UIScreen.main
- Ensure consistent card alignment by always showing color bar
- Allow adding locations when creating new cards

### Documentation

- Document UI tests need complete rewrite

### Features

- Add multi-program merchant selection
- Integrate scanning with auto-type-detection
- Add photo barcode scanning capability
- Add expiration date tracking for cards
- Add VoiceOver support to card list rows
- Add VoiceOver support to editor and display views
- Complete VoiceOver support for remaining views
- Add Dynamic Type support
- Add CardLocation model and LocationManager
- Add expiration reminder notifications
- Add home screen and lock screen widgets

### Miscellaneous Tasks

- Add SPRINT-PLAN.md to gitignore
- Location access description

### Refactoring

- Simplify Kaufland and dm merchant entries
- Remove unused 'Attach Photo' button from card editor

### Testing

- Add comprehensive UI tests for merchant selection and card creation
- Add comprehensive LocationManager unit tests

## [2026.02.2] - 2026-02-06

### Bug Fixes

- Correct BarcodeGenerator test method signatures
- Restore missing imports and fix test failures
- Configure SwiftData for local-only storage
- Use CardListView as main view instead of placeholder ContentView
- Merchant selection tap target and sheet transition

### Documentation

- Update TODO.md to reflect actual completion status
- Update TODO.md to reflect testing and localization progress
- Update README and TODO with current progress
- Add MIT license
- Mark favorites system as complete in TODO
- Mark Sprint 7 features as complete in TODO

### Features

- Add Bulgarian localization with String Catalog
- Add PermissionManager for camera and photo access
- Add barcode generation with Core Image
- Add card management UI views
- Add user-friendly error messages for barcode validation
- Add community merchant database with KDL and build-time generation
- Add merchant selection UI with search and pre-fill
- Complete Bulgarian translations for all UI strings
- Add Bulgarian translations for sort options
- Add colored branding and improve merchant selection

### Miscellaneous Tasks

- Configure app for local-only storage and fix build issues

### Testing

- Add unit tests for data models
- Add comprehensive BarcodeGenerator tests
- Add comprehensive unit tests for BarcodeType enum
- Add unit tests for ScreenManager
- Add unit tests for BrightnessManager
- Add unit tests for PermissionManager
- Add tests for colored branding feature

### Ci

- Add GitHub Actions workflows for validation and testing

## [2026.02.1] - 2026-02-06

### Documentation

- Add comprehensive project documentation

### Features

- Add SwiftData models for loyalty cards

### Miscellaneous Tasks

- Initial commit
- Add git-cliff configuration for CHANGELOG
- Configure mise for development workflow
- Add .gitignore for Xcode and generated files

<!-- generated by git-cliff -->
