# Changelog

All notable changes to kartonche will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2026.03.1] - 2026-03-25

### Bug Fixes

- Handle nearby-cards deep link
- Avoid false duplicates with missing identity
- Show import and export errors
- Resolve duplicate card editor flow
- Remove background layer from pass icon/logo PNGs
- Add test targets to kartonche scheme
- Improve screenshot tests and seed data
- Explicit SwiftData saves to prevent data loss on app kill
- Consistent tint-colored icons on all About screen rows
- Fix model tests after new barcode support
- Generalize EAN-13 strip image warning for all non-native barcode types
- Aspect-fit barcode images in wallet pass strip
- Less hacky tip showing, fix some animation issues
- Updates of passes with strip images
- Allow pinch-to-zoom by using simultaneousGesture
- Remove storekit file from resource build phase
- Add missing translations for permissions

### Documentation

- Add privacy policy
- Add translator comments
- Add Crowdin localization badge
- Add App Store badge and update status to released

### Features

- Enable iCloud sync with status UI
- Add iCloud sync to What's New
- Reduce GitHub Actions usage with PR/tag/manual triggers
- EAN-13 Apple Wallet fallback via strip image
- Add EAN-13 support to What's New screen
- Add sample data for screenshot mode
- Add --screenshot-mode launch argument
- Add accessibility identifiers for screenshot tests
- Add capture script and mise task
- Show location indicator on card rows
- Custom launch screen matching CardListView background
- TipKit integration with contextual tips for feature discovery
- Debug settings for TipKit
- Third-party license attribution
- Add new barcode symbologies
- Generate EAN-8, Code 39, I2of5, UPC-E barcodes
- Add SwiftDataMatrix dependency and DataMatrix generation
- Add new symbologies to scanner and photo detector
- Live barcode scanner for add card flow
- Photo library scan failure handling
- Scan flow and barcode type improvements entry
- Split Recent into Recently Used and Recently Edited
- Add Home Screen quick action for Scan Barcode
- Add Siri and Shortcuts app intents
- Add Siri Shortcuts and Home Screen Quick Action entries
- Add tip jar with StoreKit 2 in-app purchases
- Add privacy manifests for App Store submission

### Miscellaneous Tasks

- Update translations
- Add missing Bulgarian translations
- Bump version to 2026.03.1
- Add missing Bulgarian translations
- Lock iPhone orientation to portrait
- Correct some Bulgarian translations
- Add shared Xcode schemes
- Remove redundant action extension
- Update localization strings

### Refactoring

- Extract single-card share helper
- Move What's New content to string catalog keys
- Generalize strip image approach for all barcode types
- Unify duplicate detection in CardRepository

### Styling

- Set AccentColor to branded blue (#2196F3)

### Testing

- Remove warning-only assertions and deprecations
- Add UI tests for App Store screenshot capture

## [2026.02.6] - 2026-03-08

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
- Tag version bump commit using jj tag instead of git tag
- Fix card preview row separator width in card editor
- Improve permission modal spacing and layout
- Always show nearby notifications explanation before enabling
- Correct localization description in README
- Guard photo scan continuation resume
- Support ci-backed images in color extraction
- Show scan progress and stabilize color extraction

### Documentation

- Update CHANGELOG for v2026.02.5
- Update ARCHITECTURE.md to reflect current implementation
- Remove stale test counts, fix dependencies, add CI badges
- Update CHANGELOG for v2026.02.6
- Update mise tasks to match actual available tasks
- Remove incorrect manual merchant generation step
- Update project structure diagram
- Update architecture for Quick Scan
- Add Quick Scan to 2026.02.6 what's new

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
- Add archive and testflight upload mise tasks
- Persist sort option across app launches
- Show Apple Wallet status labels in card display view
- Bump build number alongside marketing version
- Add CoreSpotlight indexing for loyalty cards
- Add Spotlight search to What's New
- Add dominant color extraction
- Add camera capture view
- Scan-first add-card flow
- Present add-card options in bottom sheet

### Miscellaneous Tasks

- Migrate to Swift 6 language mode
- Add localization strings for export and multi-card preview
- Apply Xcode recommended project settings
- Update translations
- Bump version to 2026.02.6
- Silence App Store Connect encryption compliance dialog
- Mark format string as non-translatable
- Add Crowdin configuration

### Refactoring

- Simplify LaunchAppIntent to rely on openAppWhenRun
- Rename widget target and folder for consistency
- Rename FileImportManager to URLRouter
- Remove redundant merchant generation from ci task
- Make cardNumber properly optional (String?)
- Centralize card mutation side-effects in CardRepository
- Remove merchant template infrastructure
- Unify photo barcode scan flow

### Testing

- Add scan-first tests
- Add ci-backed image scanner coverage

### Ci

- Restructure release pipeline into discrete steps

## [2026.02.5] - 2026-03-08

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

## [2026.02.4] - 2026-03-08

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

- Update CI to use macOS 15 with Xcode 26.2
- Limit app to iPhone only
- Update version to 2026.02.4

### Refactoring

- Simplify CI workflows to use mise tasks
- Make i18n check support multiple languages dynamically

## [2026.02.3] - 2026-03-08

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

## [2026.02.2] - 2026-03-08

### Bug Fixes

- Correct BarcodeGenerator test method signatures
- Restore missing imports and fix test failures
- Configure SwiftData for local-only storage
- Use CardListView as main view instead of placeholder ContentView
- Merchant selection tap target and sheet transition

### Documentation

- Update README and TODO with current progress
- Add MIT license

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

## [2026.02.1] - 2026-03-08

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
