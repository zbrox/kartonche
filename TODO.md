# kartonche - Implementation TODO

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
- [ ] Create TODO.md (this file)
- [ ] Create mise.toml
- [ ] Create mise task files
- [ ] Test all mise tasks work

---

## Sprint 1: Foundation & Setup (Days 1-3)

### Data Models
- [ ] Create `BarcodeType` enum (qr, code128, ean13, pdf417, aztec)
- [ ] Create `LoyaltyCard` SwiftData model with all properties
- [ ] Write unit tests for model validation
- [ ] Test model persistence with SwiftData

### iCloud Sync Configuration
- [ ] Update `kartoncheApp.swift` ModelConfiguration for CloudKit
- [ ] Enable iCloud capability in Xcode project
- [ ] Enable CloudKit capability
- [ ] Add CloudKit container identifier
- [ ] Test sync between two devices/simulators

### Localization Setup
- [ ] Create `Localizable.xcstrings` String Catalog
- [ ] Add Bulgarian as language
- [ ] Add initial strings (10-15 common UI elements)
- [ ] Follow neutral form guidelines (no imperatives)
- [ ] Test language switching

### Permissions Setup
- [ ] Add `NSCameraUsageDescription` to Info.plist (Bulgarian + English)
- [ ] Add `NSPhotoLibraryUsageDescription` to Info.plist
- [ ] Create `PermissionManager` utility class
- [ ] Implement camera permission checking/requesting
- [ ] Test permission flows

---

## Sprint 2: Barcode Core (Days 4-7)

### Barcode Generation
- [ ] Create `BarcodeGenerator` utility using Core Image
- [ ] Implement QR code generation (`CIQRCodeGenerator`)
- [ ] Implement Code128 generation (`CICode128BarcodeGenerator`)
- [ ] Implement EAN-13 generation (`CIBarcodeGenerator`)
- [ ] Implement PDF417 generation (`CIPDF417BarcodeGenerator`)
- [ ] Implement Aztec generation (`CIAztecCodeGenerator`)
- [ ] Write unit tests for all barcode types
- [ ] Handle scaling/interpolation correctly

### Barcode Display Component
- [ ] Create `BarcodeImageView` SwiftUI component
- [ ] Set `.interpolation(.none)` for sharp edges
- [ ] Make responsive to different sizes
- [ ] Add high contrast background
- [ ] Test on physical device screen

### Barcode Scanning
- [ ] Create `BarcodeScannerView` wrapping VisionKit
- [ ] Check `DataScannerViewController.isSupported`
- [ ] Configure for all barcode symbologies
- [ ] Handle scanned data callback
- [ ] Error handling for unsupported devices
- [ ] Test on physical device (required for camera)

### Screen Management Utilities
- [ ] Create `BrightnessManager` class
- [ ] Implement brightness save/restore
- [ ] Create `ScreenManager` class
- [ ] Implement idle timer disable/enable
- [ ] Test cleanup on view disappear

---

## Sprint 3: Card Management UI (Days 8-12)

### Main Card List
- [ ] Create `CardListView` (replace ContentView)
- [ ] Implement `@Query` for all cards
- [ ] Create `CardRowView` component
- [ ] Add search functionality
- [ ] Implement sort options (alphabetical, recent, favorites)
- [ ] Add swipe-to-delete action
- [ ] Add favorite toggle (star icon)
- [ ] Create empty state view
- [ ] Localize all strings

### Card Display View
- [ ] Create `CardDisplayView` for full-screen display
- [ ] Integrate `BarcodeImageView`
- [ ] Integrate `BrightnessManager` (boost on appear)
- [ ] Integrate `ScreenManager` (keep awake)
- [ ] Show card name and number
- [ ] Add dismiss gesture/button
- [ ] Test brightness restore on dismiss
- [ ] Verify idle timer re-enabled

### Card Editor
- [ ] Create `CardEditorView` with form
- [ ] All fields: name, store, number, barcode type, notes, color
- [ ] Color picker for customization
- [ ] Save/Cancel buttons
- [ ] Delete button (with confirmation)
- [ ] Form validation
- [ ] Localize all strings

### Manual Card Entry
- [ ] Create `ManualCardEntryView`
- [ ] Barcode type picker
- [ ] Text field for barcode data
- [ ] Preview of generated barcode as user types
- [ ] Validation for barcode format
- [ ] Save button creates card
- [ ] Localize all strings

### Navigation
- [ ] Wire up navigation from list to display
- [ ] Wire up navigation from list to editor
- [ ] Wire up add card flow
- [ ] Test back navigation
- [ ] Test state preservation

---

## Sprint 4: Merchant Database (Days 13-15)

### KDL Database Setup
- [ ] Create `Merchants/` directory
- [ ] Create `merchants.kdl` with initial Bulgarian merchants (15-20)
  - [ ] Billa, Kaufland, Lidl (grocery)
  - [ ] OMV, Lukoil, Shell (fuel)
  - [ ] Sopharmacy, Subra (pharmacy)
  - [ ] Other popular Bulgarian stores
- [ ] Create `schema.kdl` for validation
- [ ] Create `Merchants/README.md` contributor guide
- [ ] Follow flexible naming (Cyrillic or Latin)

### Build Script
- [ ] Create `Scripts/generate-merchants/` directory
- [ ] Create `Package.swift` with kdl-swift dependency
- [ ] Create Swift script to parse KDL
- [ ] Generate `MerchantTemplates.swift` code
- [ ] Implement change detection (git hash)
- [ ] Add error handling and validation
- [ ] Test script locally

### Xcode Integration
- [ ] Add "Run Script" build phase
- [ ] Script calls `mise run generate-merchants`
- [ ] Runs before "Compile Sources"
- [ ] Create `kartonche/Generated/` directory
- [ ] Add `Generated/` to `.gitignore`
- [ ] Test build-time generation

### Merchant Selection UI
- [ ] Create `MerchantSelectionView`
- [ ] Search bar with autocomplete
- [ ] Filter `MerchantTemplate.search(query)`
- [ ] Show merchant name (Bulgarian), category, barcode type
- [ ] "Add Custom Card" button at bottom
- [ ] Localize all strings
- [ ] Test Bulgarian search (Cyrillic input)

### Quick Add Flow
- [ ] Integrate merchant selection into add card flow
- [ ] Pre-fill card name, barcode type from template
- [ ] Skip to barcode scanner directly
- [ ] Create card with merchant info
- [ ] Test end-to-end quick add

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

## Sprint 8: Testing & Bug Fixes (Days 25-27)

### Unit Tests
- [ ] Test `BarcodeGenerator` all formats
- [ ] Test `BarcodeType` enum
- [ ] Test `LoyaltyCard` model validation
- [ ] Test `MerchantTemplate.search()`
- [ ] Test barcode data validation
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
