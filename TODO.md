# kartonche - Implementation TODO

## Overall Progress (as of 2026-02-05)

**Completed Sprints:**
- ✅ Sprint 0: Project Setup (mise, documentation, planning)
- ✅ Sprint 1: Foundation (models, permissions, **complete Bulgarian localization**)
- ✅ Sprint 2: Barcode Core (generation, display, scanning, utilities)
- ✅ Sprint 3: Card Management UI (list, display, editor, navigation, **search, sort, empty states**)
- ✅ Sprint 4: Merchant Database (KDL database, code generator, selection UI)
- ✅ Sprint 8: Testing (BarcodeType, BarcodeGenerator, Model, MerchantTemplate, ScreenManager, BrightnessManager tests)

**Partially Complete:**
- ⚠️ Sprint 7: Polish & Features (search ✅, sort ✅, empty states ✅, favorites tracking pending, color picker pending)

**Not Started:**
- ❌ Sprint 5: Photo Import
- ❌ Sprint 6: Widgets
- ❌ Sprint 9: CI/CD & Documentation
- ❌ Sprint 10: MVP Release Prep

**Key Decisions:**
- iCloud/CloudKit sync SKIPPED (requires paid Apple Developer account)
- Local-only storage with SwiftData
- Bulgarian as PRIMARY language (клубна карта terminology)

---

## Sprint 0: Project Setup ✅

- [x] Research Apple Wallet integration
- [x] Research location features
- [x] Research EAN-13 barcode support
- [x] Research Bulgarian NFC card usage
- [x] Research Swift KDL parsers
- [x] Plan architecture
- [x] Plan merchant database
- [x] Plan localization strategy
- [x] Update AGENTS.md with all guidelines
- [x] Create ARCHITECTURE.md
- [x] Create cliff.toml
- [x] Create initial CHANGELOG.md
- [x] Create TODO.md (this file)
- [x] Create mise.toml
- [x] Create mise task files
- [x] Test all mise tasks work

---

## Sprint 1: Foundation & Setup ✅ (mostly complete)

### Data Models ✅
- [x] Create `BarcodeType` enum (qr, code128, ean13, pdf417, aztec)
- [x] Create `LoyaltyCard` SwiftData model with all properties
- [x] Write unit tests for model validation
- [x] Test model persistence with SwiftData

### iCloud Sync Configuration ❌ (SKIPPED - requires paid developer account)
- [x] Update `kartoncheApp.swift` ModelConfiguration for local storage
- [-] Enable iCloud capability in Xcode project (SKIPPED)
- [-] Enable CloudKit capability (SKIPPED)
- [-] Add CloudKit container identifier (SKIPPED)
- [-] Test sync between two devices/simulators (SKIPPED)

### Localization Setup ✅
- [x] Create `Localizable.xcstrings` String Catalog
- [x] Add Bulgarian as language
- [x] Add initial strings (10-15 common UI elements)
- [x] Follow neutral form guidelines (using gerunds like Добавяне, Затваряне)
- [x] Complete all string translations (15+ strings)
- [x] Use correct Bulgarian terminology (клубна карта, not карта за лоялност)
- [ ] Test language switching on device

### Permissions Setup ✅
- [x] Add `NSCameraUsageDescription` to Info.plist (Bulgarian + English)
- [x] Add `NSPhotoLibraryUsageDescription` to Info.plist
- [x] Create `PermissionManager` utility class
- [x] Implement camera permission checking/requesting
- [x] Test permission flows

---

## Sprint 2: Barcode Core ✅

### Barcode Generation ✅
- [x] Create `BarcodeGenerator` utility using Core Image
- [x] Implement QR code generation (`CIQRCodeGenerator`)
- [x] Implement Code128 generation (`CICode128BarcodeGenerator`)
- [x] Implement EAN-13 generation (`CIBarcodeGenerator`)
- [x] Implement PDF417 generation (`CIPDF417BarcodeGenerator`)
- [x] Implement Aztec generation (`CIAztecCodeGenerator`)
- [x] Write unit tests for all barcode types
- [x] Handle scaling/interpolation correctly

### Barcode Display Component ✅
- [x] Create `BarcodeImageView` SwiftUI component
- [x] Set `.interpolation(.none)` for sharp edges
- [x] Make responsive to different sizes
- [x] Add high contrast background
- [ ] Test on physical device screen

### Barcode Scanning ✅
- [x] Create `BarcodeScannerView` wrapping VisionKit
- [x] Check `DataScannerViewController.isSupported`
- [x] Configure for all barcode symbologies
- [x] Handle scanned data callback
- [x] Error handling for unsupported devices
- [ ] Test on physical device (required for camera)

### Screen Management Utilities ✅
- [x] Create `BrightnessManager` class
- [x] Implement brightness save/restore
- [x] Create `ScreenManager` class
- [x] Implement idle timer disable/enable
- [x] Test cleanup on view disappear

---

## Sprint 3: Card Management UI ✅ (mostly complete)

### Main Card List ✅
- [x] Create `CardListView` (replace ContentView)
- [x] Implement `@Query` for all cards
- [x] Create `CardRowView` component
- [x] Add search functionality
- [x] Implement sort options (alphabetical, recent, favorites)
- [x] Add swipe-to-delete action
- [x] Add favorite toggle (star icon)
- [x] Create empty state view
- [ ] Localize all strings

### Card Display View ✅
- [x] Create `CardDisplayView` for full-screen display
- [x] Integrate `BarcodeImageView`
- [x] Integrate `BrightnessManager` (boost on appear)
- [x] Integrate `ScreenManager` (keep awake)
- [x] Show card name and number
- [x] Add dismiss gesture/button
- [ ] Test brightness restore on dismiss (on device)
- [ ] Verify idle timer re-enabled (on device)

### Card Editor ✅
- [x] Create `CardEditorView` with form
- [x] All fields: name, store, number, barcode type, notes, color
- [x] Color picker for customization
- [x] Save/Cancel buttons
- [x] Delete button (with confirmation)
- [x] Form validation
- [ ] Localize all strings

### Manual Card Entry ⚠️ (integrated into editor, not separate view)
- [x] Barcode type picker (in CardEditorView)
- [x] Text field for barcode data (in CardEditorView)
- [ ] Preview of generated barcode as user types
- [x] Validation for barcode format
- [x] Save button creates card
- [ ] Localize all strings

### Navigation ✅
- [x] Wire up navigation from list to display
- [x] Wire up navigation from list to editor
- [x] Wire up add card flow
- [x] Test back navigation
- [x] Test state preservation

---

## Sprint 4: Merchant Database ✅

### KDL Database Setup ✅
- [x] Create `Merchants/` directory
- [x] Create `merchants.kdl` with initial Bulgarian merchants (14 total)
  - [x] Billa, Kaufland, Lidl, Фантастико, T MARKET (grocery)
  - [x] OMV, Lukoil, Shell, Petrol, EKO (fuel)
  - [x] Sopharmacy, Subra (pharmacy)
  - [x] dm drogerie markt, CCC (retail)
- [x] Create `schema.kdl` for validation
- [x] Create `Merchants/README.md` contributor guide
- [x] Follow flexible naming (Cyrillic or Latin)

### Build Script ✅
- [x] Create `Scripts/generate-merchants/` directory
- [x] Create `Package.swift` with kdl-swift dependency
- [x] Create Swift script to parse KDL
- [x] Generate `MerchantTemplates.swift` code
- [ ] Implement change detection (git hash) - TODO
- [x] Add error handling and validation
- [x] Test script locally

### Xcode Integration ✅
- [ ] Add "Run Script" build phase - not needed, using mise
- [x] Script calls `mise run generate-merchants`
- [x] Runs before compile (manual for now)
- [x] Create `kartonche/Generated/` directory
- [x] Add `Generated/` to `.gitignore`
- [x] Test build-time generation

### Merchant Selection UI ✅
- [x] Create `MerchantSelectionView`
- [x] Search bar with autocomplete
- [x] Filter `MerchantTemplate.search(query)`
- [x] Show merchant name (Bulgarian), category, barcode type
- [x] "Add Custom Card" button at bottom (manual entry)
- [ ] Localize all strings (hardcoded Bulgarian for now)
- [x] Test Bulgarian search (Cyrillic input)

### Quick Add Flow ✅
- [x] Integrate merchant selection into add card flow
- [x] Pre-fill card name, barcode type from template
- [x] Pre-fill suggested colors from template
- [ ] Skip to barcode scanner directly (goes to editor first)
- [x] Create card with merchant info
- [ ] Test end-to-end quick add (needs device testing)

---

## Sprint 5: Photo Import (Days 16-17)

### Photo Import UI
- [ ] Create `PhotoImportView` using PhotosUI
- [ ] Implement `PhotosPicker` selection
- [ ] Load selected image data
- [ ] Store as `@Attribute(.externalStorage)` in SwiftData
- [ ] Display photo in card editor
- [ ] Delete photo option
- [ ] Test with large images

### Add Card Flow Integration
- [ ] Add "Import Photo" option to add card flow
- [ ] Optional: Attach photo after scanning
- [ ] Optional: Attach photo to existing cards
- [ ] Test storage and retrieval

---

## Sprint 6: Widgets (Days 18-21)

### Widget Extension Setup
- [ ] Add Widget Extension target to project
- [ ] Configure shared App Group
- [ ] Share SwiftData container with widget
- [ ] Set up widget Info.plist

### Widget Implementation
- [ ] Create `CardWidgetEntry` timeline entry
- [ ] Create `CardWidgetView` SwiftUI widget view
- [ ] Implement timeline provider (query favorite cards)
- [ ] Show 1-3 favorite cards with barcodes
- [ ] Medium widget: 2 cards
- [ ] Large widget: 3 cards
- [ ] Generate scannable-size barcodes

### Deep Linking
- [ ] Implement deep link URLs (card ID)
- [ ] Handle URL in `kartoncheApp.swift`
- [ ] Navigate to specific card on widget tap
- [ ] Test deep linking

### Widget Configuration
- [ ] Optional: Add widget configuration (which cards to show)
- [ ] Update timeline on card changes
- [ ] Test widget refresh behavior

---

## Sprint 7: Polish & Features (Days 22-24)

### Favorites System
- [ ] Add star/heart button to card row
- [ ] Toggle `isFavorite` flag
- [ ] "Favorites" section at top of list (optional filter)
- [ ] Update widget when favorites change

### Recently Used Tracking
- [ ] Update `lastUsedDate` when card displayed
- [ ] Sort option: "Recently Used"
- [ ] Show "last used" timestamp in detail view

### Visual Customization
- [ ] Color picker in card editor
- [ ] Store hex color in model
- [ ] Apply color to card row background/accent
- [ ] Preview color in editor

### Search & Filter
- [ ] Search bar in card list
- [ ] Filter by card name, store name
- [ ] Filter by category (if merchant template used)
- [ ] Clear search button

### Empty States
- [ ] "No cards yet" with friendly message
- [ ] "Add your first card" CTA button
- [ ] Onboarding hints for new users
- [ ] "No search results" state

---

## Sprint 8: Testing & Bug Fixes (Days 25-27) ⚠️ (partial)

### Unit Tests ✅ (good coverage)
- [x] Test `BarcodeGenerator` all formats
- [x] Test `BarcodeType` enum (all cases, display names, codable, raw values)
- [x] Test `LoyaltyCard` model validation
- [x] Test `MerchantTemplate.search()` (13 tests)
- [x] Test `ScreenManager` (idle timer management)
- [x] Test `BrightnessManager` (state management, safety checks)
- [ ] Test `PermissionManager` (camera/photo permissions)
- [ ] Test barcode data validation in `BarcodeGenerator`
- [ ] Achieve >70% code coverage for utilities

### UI Tests
- [ ] Test add card (manual entry)
- [ ] Test display card
- [ ] Test edit card
- [ ] Test delete card
- [ ] Test search
- [ ] Test favorites toggle
- [ ] Test widget tap opens app

### Manual Testing on Device
- [ ] Test camera scanning with real cards
- [ ] Test all barcode types display correctly
- [ ] Verify brightness boost/restore works
- [ ] Verify idle timer disable/enable
- [ ] Test iCloud sync across devices
- [ ] Test Bulgarian localization (all strings)
- [ ] Test English localization (fallback)
- [ ] Test widget shows correct cards
- [ ] Test deep linking from widget

### Accessibility
- [ ] VoiceOver support for all views
- [ ] Dynamic Type (text scaling)
- [ ] High contrast mode support
- [ ] Test with accessibility features enabled

### Bug Fixes
- [ ] Fix any crashes found
- [ ] Fix layout issues on different screen sizes
- [ ] Fix iPad-specific issues (if any)
- [ ] Fix any localization errors

---

## Sprint 9: CI/CD & Documentation (Days 28-29)

### GitHub Actions
- [ ] Create `.github/workflows/validate-merchants.yml`
- [ ] Validate KDL syntax on PR
- [ ] Check for duplicate merchant IDs
- [ ] Test code generation
- [ ] Run mise run ci (build + test)

### Repository Setup
- [ ] Create comprehensive `.gitignore`
- [ ] Create `.gitattributes` (for Git LFS future)
- [ ] Set up Git LFS configuration (for Phase 2 logos)

### Documentation
- [ ] Create comprehensive README.md
- [ ] Document installation/setup
- [ ] Document mise tasks
- [ ] Add screenshots (after MVP complete)
- [ ] Link to ARCHITECTURE.md, AGENTS.md

### License
- [ ] Choose open source license (MIT recommended)
- [ ] Add LICENSE file
- [ ] Add copyright headers to files

---

## Sprint 10: MVP Release Prep (Day 30)

### Final Testing
- [ ] Full end-to-end testing
- [ ] Test on multiple devices (iPhone, iPad)
- [ ] Test on iOS 26.2 (minimum version)
- [ ] Performance testing (large card collections)

### App Store Prep (Future)
- [ ] App icon design
- [ ] Launch screen
- [ ] Privacy policy (required for App Store)
- [ ] App Store description (Bulgarian + English)
- [ ] Screenshots for App Store

### Code Review
- [ ] Review all code for consistency
- [ ] Remove debug logging
- [ ] Remove commented-out code
- [ ] Ensure all strings localized
- [ ] Check for security issues

### Release
- [ ] Tag version 1.0.0 using mise run changelog-tag
- [ ] Generate release notes with mise run release-notes
- [ ] Create GitHub release
- [ ] Archive and sign app
- [ ] Submit to App Store (if ready)

---

## Phase 2: Future Enhancements (Post-MVP)

### Location Features (Months 2-3)
- [ ] Add `CardLocation` model
- [ ] Location search UI (MKLocalSearch)
- [ ] Location list/map view
- [ ] "Nearby cards" section (When In Use permission)
- [ ] Optional: Background geofencing
- [ ] Optional: Local notifications

### Apple Wallet Integration (Month 4+)
- [ ] Only if user demand proven (>1000 users)
- [ ] Backend server for pass signing
- [ ] Pass generation service
- [ ] APNs integration
- [ ] "Add to Wallet" button

### Community Features
- [ ] CONTRIBUTING.md file
- [ ] Issue templates
- [ ] PR template
- [ ] Merchant submission guidelines

### Other Enhancements
- [ ] Categories/tags for cards
- [ ] Export/import (JSON backup)
- [ ] Share cards with family
- [ ] Balance tracking (manual entry)
- [ ] Card expiration alerts
- [ ] App icon customization
- [ ] Dark mode refinements

---

## Notes

- All tasks marked `[ ]` are pending
- Mark completed tasks with `[x]`
- Update this file as plan evolves
- Use `mise run ci` before committing major changes
- Test on physical device regularly (camera required)
- Bulgarian localization is PRIMARY - test thoroughly
