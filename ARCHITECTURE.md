# kartonche - Architecture Documentation

## Overview

kartonche is a native iOS app for managing loyalty cards. Built with SwiftUI and SwiftData, it provides card scanning, storage, and quick access via widgets.

## Technology Stack

- **Language:** Swift 6.2+
- **UI Framework:** SwiftUI
- **Persistence:** SwiftData + CloudKit (iCloud sync)
- **Barcode Scanning:** VisionKit DataScannerViewController
- **Barcode Generation:** Core Image filters (CIBarcodeGenerator)
- **Photo Import:** PhotosUI PhotosPicker
- **Widgets:** WidgetKit
- **Localization:** String Catalogs (English primary, Bulgarian secondary)

**Zero third-party dependencies** - all Apple frameworks.

## Architecture Pattern

**SwiftUI + SwiftData (Declarative UI + Reactive Data)**

- Views observe SwiftData models via `@Query`
- Data changes automatically trigger view updates
- Unidirectional data flow
- ModelContext handles persistence

## Data Models

### LoyaltyCard (SwiftData Model)

```swift
@Model
final class LoyaltyCard {
    var id: UUID
    var name: String              // User-friendly name
    var storeName: String         // Merchant name
    var cardNumber: String        // Actual card number
    var barcodeType: BarcodeType  // QR, Code128, EAN13, etc.
    var barcodeData: String       // Raw data for barcode
    var color: String?            // Hex color (user customization)
    var secondaryColor: String?   // Secondary color for gradients
    var notes: String?            // Optional user notes
    var isFavorite: Bool          // Quick access flag
    var createdDate: Date
    var lastUsedDate: Date?       // Track usage for sorting
    var expirationDate: Date?     // Card expiration (if applicable)
    
    @Attribute(.externalStorage)
    var cardImage: Data?          // Optional photo of physical card
    
    @Relationship(deleteRule: .cascade, inverse: \CardLocation.card)
    var locations: [CardLocation] // Associated store locations
}
```

### BarcodeType (Enum)

```swift
enum BarcodeType: String, Codable {
    case qr
    case code128
    case ean13
    case pdf417
    case aztec
}
```

### MerchantTemplate (Generated)

```swift
// Generated from Merchants/merchants.kdl at build time
struct MerchantTemplate: Identifiable {
    let id: String                    // e.g., "bg.billa"
    let name: String                  // Primary name
    let otherNames: [String]          // Alternate names (localized, abbreviations)
    let country: String               // ISO country code
    let category: MerchantCategory
    let website: String?
    let suggestedColor: String?
    let secondaryColor: String?
    let programs: [ProgramTemplate]   // Loyalty programs offered
}
```

### ProgramTemplate (Generated)

```swift
struct ProgramTemplate: Identifiable {
    let id: String
    let name: String?                 // Program name (nil if merchant has single program)
    let barcodeType: BarcodeType
}
```

### MerchantCategory (Enum)

```swift
enum MerchantCategory: String, Codable, CaseIterable {
    case grocery    // Grocery Stores
    case fuel       // Gas Stations
    case pharmacy   // Pharmacies
    case retail     // Other Retail
    case wholesale  // Wholesale
}
```

## Directory Structure

```
kartonche/
├── Models/
│   ├── LoyaltyCard.swift         # Main data model
│   ├── CardLocation.swift        # Store location model
│   ├── BarcodeType.swift         # Barcode format enum
│   ├── CardExportDTO.swift       # Export/import data transfer
│   └── WhatsNewData.swift        # What's new content
├── Views/
│   ├── CardListView.swift        # Main list view
│   ├── CardDisplayView.swift     # Full-screen card display
│   ├── CardEditorView.swift      # Edit card properties
│   ├── MerchantSelectionView.swift
│   ├── SettingsView.swift        # App settings
│   ├── AboutView.swift           # About screen
│   ├── ImportPreviewView.swift   # Import preview
│   └── Components/
│       ├── CardRowView.swift     # List item
│       ├── BarcodeImageView.swift
│       ├── BarcodeScannerView.swift  # VisionKit wrapper
│       ├── MerchantRowView.swift
│       ├── EmptyCardListView.swift
│       ├── LocationEditorView.swift
│       └── MapLocationPicker.swift
├── Utilities/
│   ├── BarcodeGenerator.swift    # Core Image barcode generation
│   ├── BarcodeTypeDetector.swift # Auto-detect barcode format
│   ├── PermissionManager.swift   # Camera/photo permissions
│   ├── BrightnessManager.swift   # Screen brightness control
│   ├── ScreenManager.swift       # Idle timer management
│   ├── LocationManager.swift     # Location services
│   ├── GeocodingService.swift    # Address lookup
│   ├── NotificationManager.swift # Local notifications
│   ├── CardExporter.swift        # Export cards
│   ├── CardImporter.swift        # Import cards
│   └── PhotoBarcodeScanner.swift # Scan from photos
├── Generated/
│   └── MerchantTemplates.swift   # Auto-generated (build time)
├── Assets.xcassets/              # Images, colors, app icon
├── Localizable.xcstrings         # English + Bulgarian
└── kartoncheApp.swift            # App entry + ModelContainer

kartoncheWidget/                  # Widget extension target
├── kartoncheWidget.swift         # Main widget
├── FavoritesCarouselWidget.swift # Favorites carousel
├── LockScreenWidgets.swift       # Lock screen widgets
├── NearestLocationWidget.swift   # Location-based widget
└── Assets.xcassets/

Merchants/
├── merchants.kdl                 # Community database (seed data)
├── schema.kdl                    # KDL schema
└── README.md                     # Contributor guide

Scripts/
└── generate-merchants/
    └── Package.swift             # kdl-swift dependency

.mise/
└── tasks/                        # Development tasks
```

## Data Flow

### Adding a Card (Quick Flow with Merchant Template)

1. User taps "Add Card"
2. `MerchantSelectionView` shows searchable list of `MerchantTemplate.all`
3. User selects "Билла" → pre-fills barcode type (EAN-13)
4. `BarcodeScannerView` presents VisionKit scanner
5. Scanner returns barcode data
6. Create `LoyaltyCard` with merchant name + scanned data
7. Insert into `ModelContext` → automatic save
8. iCloud sync happens automatically (CloudKit)
9. View updates via `@Query` observation

### Displaying a Card for Scanning

1. User taps card in `CardListView`
2. Navigate to `CardDisplayView`
3. `BrightnessManager.boost()` sets screen to max brightness
4. `ScreenManager.keepAwake()` disables idle timer
5. `BarcodeGenerator` uses Core Image to generate barcode image
6. `BarcodeImageView` displays with `.interpolation(.none)`
7. User dismisses → `onDisappear` restores brightness + re-enables idle timer

### Widget Updates

1. Widget extension reads cards from shared SwiftData container
2. Timeline provider queries favorite/recent cards
3. Widget displays up to 3 cards with small barcodes
4. User taps widget → deep link to specific card in app
5. Widget refreshes on system schedule (not real-time)

## Key Architectural Decisions

### Why SwiftData + CloudKit?

- **Zero backend code** - Apple handles sync infrastructure
- **Automatic conflict resolution** - CloudKit manages merges
- **iCloud account required** - Acceptable for target audience
- **Privacy-first** - Data stays in user's iCloud, not our servers

### Why Core Image for Barcodes?

- **Native support** - QR, Code128, EAN-13, PDF417, Aztec all supported
- **Zero dependencies** - No third-party libraries
- **High quality** - Hardware-accelerated rendering
- **Scales well** - Generate at any size needed

### Why VisionKit for Scanning?

- **Modern API** - High-level, easy to use (iOS 16+)
- **Hardware accelerated** - Uses Neural Engine
- **Built-in UI** - Scanner interface provided by system
- **Supports all formats** - Same formats we generate

### Why KDL for Merchant Database?

- **Human-friendly** - Easy for contributors to edit
- **Schema validation** - Built-in validation support
- **No nesting issues** - Unlike YAML significant whitespace
- **Comments supported** - Document merchants inline

### Why File-based mise Tasks?

- **Better for complex logic** - Full bash capabilities
- **Easier maintenance** - Each task is separate file
- **Version control friendly** - Clean diffs
- **Autocomplete support** - Usage hints for shell completion

## Concurrency Model

- **@MainActor** for all UI code and SwiftData access
- **async/await** for camera/scanner operations
- **Task {}** for async work in SwiftUI views
- **No manual threading** - Swift concurrency handles it

## Error Handling

### Recoverable Errors
- Show alert with user-friendly message (English + Bulgarian)
- Log error details for debugging
- Provide actionable next step ("Try Again", "Open Settings")

### Permission Errors
- Check authorization before requesting
- Show explanation before requesting permission
- Deep link to Settings if denied

### Critical Errors
- `fatalError()` acceptable only for:
  - ModelContainer creation failure (unrecoverable)
  - Programmer errors (force unwrap of required data)

## Testing Strategy

### Unit Tests (Swift Testing)
- `BarcodeGenerator` - all supported formats
- `MerchantTemplate.search()` - Bulgarian + English queries
- Model validation logic
- Barcode type conversions

### UI Tests (XCTest)
- Add card flow (manual entry)
- Display card (brightness/idle timer)
- Edit card
- Delete card
- Search/filter cards
- Widget tap opens app

### Manual Testing Checklist
- Physical device required (camera, brightness)
- Test all barcode types with real cards
- Test iCloud sync across devices
- Test Bulgarian localization
- Test accessibility (VoiceOver, Dynamic Type)

## Performance Considerations

### Barcode Generation
- Cache generated barcode images (not implemented in MVP)
- Generate at display size (avoid scaling)
- Use `.interpolation(.none)` for sharp edges

### Widget Performance
- Limit to 3 cards per widget
- Timeline updates budget-controlled by system
- Fetch minimal data (don't load all cards)

### iCloud Sync
- Automatic batching by CloudKit
- Conflict resolution handled by system
- Test with poor connectivity

## Security & Privacy

### Data Storage
- SwiftData local SQLite database (encrypted at rest by iOS)
- iCloud CloudKit private database (user's data only)
- No data sent to third-party servers

### Permissions
- Camera: Just-in-time request when scanning
- Photos: PhotosPicker (system handles permission)
- Location: "When In Use" for store location features
- Notifications: Local notifications for location-based reminders

### No Tracking
- No analytics
- No crash reporting
- No user data collection

## Build Process

### Build-Time Code Generation

1. Xcode build phase runs before compilation
2. Checks if `Merchants/merchants.kdl` changed
3. If changed, runs `mise run generate-merchants`
4. Swift script with kdl-swift parses KDL
5. Generates `kartonche/Generated/MerchantTemplates.swift`
6. Xcode compiles generated code

### CI/CD

GitHub Actions workflow:
1. Validate `merchants.kdl` syntax
2. Generate merchant templates
3. Build app
4. Run tests

## Deployment

- **Target:** iOS 26.2+
- **Devices:** iPhone and iPad (universal)
- **Distribution:** App Store (after MVP)
- **Open Source:** GitHub repository

## Maintenance

- **Merchant database:** Community contributions via PRs
- **Localization:** String catalog updates as needed
- **Dependencies:** None to maintain (all Apple frameworks)
- **Breaking changes:** iOS version updates only
