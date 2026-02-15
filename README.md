# kartonche

[![Tests](https://github.com/zbrox/kartonche/actions/workflows/test.yml/badge.svg)](https://github.com/zbrox/kartonche/actions/workflows/test.yml)
[![Validate Merchants](https://github.com/zbrox/kartonche/actions/workflows/validate-merchants.yml/badge.svg)](https://github.com/zbrox/kartonche/actions/workflows/validate-merchants.yml)
[![GitHub release](https://img.shields.io/github/v/tag/zbrox/kartonche?label=version&sort=semver)](https://github.com/zbrox/kartonche/releases)

A modern, open-source iOS app for managing loyalty cards.

## Overview

kartonche (картонче, "small card" in Bulgarian) is a native iOS app that helps you digitize and organize all your loyalty cards. No more fumbling through your wallet at checkout - just open the app, select your card, and scan.

### Key Features

- ✅ **Barcode Generation** - Generate QR, Code128, EAN-13, PDF417, and Aztec barcodes
- ✅ **Barcode Scanning** - Scan physical cards with your camera or photos using VisionKit
- ✅ **Quick Access** - Display barcodes instantly with brightness boost and screen wake
- ✅ **Merchant Templates** - Pre-configured templates for popular stores
- ✅ **Smart Search** - Search and sort cards by name, store, or recent usage
- ✅ **Bulgarian-First** - Complete interface in Bulgarian with English fallback
- ✅ **Widgets** - Home screen and lock screen widgets for quick access
- ✅ **Location Awareness** - Get notified when near stores with your saved cards
- ✅ **Expiration Tracking** - Track card expiration dates with reminder notifications
- ✅ **Export/Import** - Share cards via AirDrop or save to files
- 💾 **Local Storage** - SwiftData-based storage (no cloud account required)

## Current Status

🚀 **Alpha Release** - Feature Complete, Testing in Progress

**What Works:**
- ✅ Add/edit/delete loyalty cards
- ✅ Generate all major barcode types (QR, Code128, EAN-13, PDF417, Aztec)
- ✅ Scan barcodes with camera or from photos
- ✅ Display cards with brightness boost and screen wake
- ✅ Search and sort cards by name, store, or usage
- ✅ Pre-configured merchant templates (BILLA, Kaufland, Lidl, OMV, Sopharmacy, etc.)
- ✅ Home screen and lock screen widgets
- ✅ Location-based notifications when near stores
- ✅ Expiration date tracking with reminders
- ✅ Export/import cards via AirDrop
- ✅ Full Bulgarian localization with VoiceOver and Dynamic Type support

## Quick Start

**First time setup:**
```bash
git clone https://github.com/zbrox/kartonche.git
cd kartonche
mise trust
mise run generate-merchants
mise run build
```

**Daily development:**
```bash
mise run dev              # Clean + build + test
mise run test             # Run tests
mise run ci               # Full CI check before commit
```

Open in Xcode simulator or connect an iOS 26.2+ device to test camera scanning.

## Getting Started

### Prerequisites

- macOS with Xcode 26.2+
- iOS 26.2+ device or simulator
- [mise](https://mise.jdx.dev/) (optional but recommended)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/zbrox/kartonche.git
cd kartonche
```

2. Trust the mise configuration:
```bash
mise trust
```

3. Generate merchant templates (required before first build):
```bash
mise run generate-merchants
```

4. Build and run:
```bash
mise run build
```

Or open `kartonche.xcodeproj` in Xcode and run.

**Note:** The merchant template generator must be run at least once before building. It generates `kartonche/Generated/MerchantTemplates.swift` from the KDL database.

## Development

### Using mise Tasks

We use [mise](https://mise.jdx.dev/) for task automation:

```bash
# Build and test
mise run build          # Build the app
mise run test           # Run unit tests
mise run test-all       # Run all tests
mise run clean          # Clean build artifacts
mise run dev            # Clean + build + test

# CHANGELOG management
mise run changelog-preview    # Preview unreleased changes
mise run changelog-update     # Update CHANGELOG.md

# Merchant database
mise run merchants-list       # List all merchants
mise run merchant-add         # Interactive merchant creator
mise run merchant-info bg.billa    # Show merchant details
mise run validate-merchants   # Validate KDL syntax
mise run generate-merchants   # Generate Swift code from KDL

# CI workflow
mise run ci                   # Full CI check
```

### Project Structure

```
kartonche/
├── AGENTS.md              # Guidelines for AI coding agents
├── ARCHITECTURE.md        # Technical architecture documentation
├── CHANGELOG.md           # Version history (auto-generated)
├── mise.toml              # Development task configuration
├── .mise/tasks/           # Individual task scripts
├── kartonche/             # Main app code
│   ├── Models/            # SwiftData models
│   ├── Views/             # SwiftUI views and components
│   ├── Utilities/         # Helper classes (barcode, brightness, permissions)
│   ├── Resources/         # Localizable.xcstrings
│   └── Generated/         # Auto-generated code (gitignored)
├── kartoncheTests/        # Unit tests
├── kartoncheUITests/      # UI tests
├── Merchants/             # Community merchant database (14 merchants)
│   ├── merchants.kdl      # Merchant data in KDL format
│   ├── schema.kdl         # Schema documentation
│   └── README.md          # Contribution guidelines
└── Scripts/               # Build scripts
    └── generate-merchants/  # Swift code generator
```

## Documentation

- **[AGENTS.md](AGENTS.md)** - Coding guidelines, localization rules, commit conventions
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical decisions, data models, architecture patterns
- **[CHANGELOG.md](CHANGELOG.md)** - Version history (auto-generated from commits)

## Contributing

We welcome contributions!

### Merchant Database

You can help by adding stores to our merchant template database:

1. Run `mise run merchant-add` for interactive entry
2. Or manually edit `Merchants/merchants.kdl` following the schema
3. Validate your changes: `mise run validate-merchants`
4. Generate code: `mise run generate-merchants`
5. Test that it builds: `mise run build`
6. Submit a pull request

See [Merchants/README.md](Merchants/README.md) for detailed contribution guidelines.

**Currently supported merchants (14):**
- **Grocery:** BILLA, Kaufland, Lidl, Фантастико, T MARKET
- **Fuel:** OMV, Lukoil, Shell, Petrol, EKO
- **Pharmacy:** Sopharmacy, Subra
- **Retail:** dm drogerie markt, CCC

All templates include pre-configured barcode types, suggested colors, and both Bulgarian and English names.

### Code Contributions

1. Read [AGENTS.md](AGENTS.md) for coding guidelines
2. Follow conventional commits format
3. Write tests for new features (CI enforces all tests passing)
4. Run `mise run test` before committing
5. Ensure Bulgarian localization uses neutral forms (not imperatives)

### Testing

We maintain comprehensive test coverage:

```bash
# Run unit tests
mise run test

# Run UI tests
mise run test-ui

# Run all tests
mise run test-all

# Full CI check (generate + build + test)
mise run ci
```

### Continuous Integration

GitHub Actions automatically:
- Validates merchant database KDL syntax on PRs
- Runs unit tests on all PRs and main branch pushes
- Checks for duplicate merchant IDs
- Verifies code generation succeeds

See [.github/workflows/](.github/workflows/) for workflow definitions.

## Technology Stack

- **Language:** Swift 6.2+
- **Framework:** SwiftUI + SwiftData (iOS 26.2+)
- **Barcode:** VisionKit (scanning) + Core Image (generation)
- **Storage:** Local-only SwiftData (no cloud sync)
- **Localization:** String Catalogs (Bulgarian primary, 15+ strings)
- **Database:** KDL format with build-time code generation
- **Testing:** Swift Testing framework
- **Dependencies:** Minimal dependencies: swift-crypto, swift-certificates, ZIPFoundation + native Apple frameworks

## What's Next

- [ ] iCloud sync (CloudKit integration)
- [x] Apple Wallet integration
- [x] UI test coverage
- [ ] App Store release

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Acknowledgments

Thanks to early testers and friends who provided feedback.

---

**Status:** Alpha | **Version:** 2026.02 | **Platform:** iOS 26.2+
