# kartonche

[![Tests](https://github.com/zbrox/kartonche/actions/workflows/test.yml/badge.svg)](https://github.com/zbrox/kartonche/actions/workflows/test.yml)
[![GitHub release](https://img.shields.io/github/v/tag/zbrox/kartonche?label=version&sort=semver)](https://github.com/zbrox/kartonche/releases)

A modern, open-source iOS app for managing loyalty cards.

## Overview

kartonche (картонче, "small card" in Bulgarian) is a native iOS app that helps you digitize and organize all your loyalty cards. No more fumbling through your wallet at checkout - just open the app, select your card, and scan.

### Key Features

- ✅ **Barcode Generation** - Generate QR, Code128, EAN-13, PDF417, and Aztec barcodes
- ✅ **Barcode Scanning** - Scan physical cards with your camera or photos using VisionKit
- ✅ **Quick Access** - Display barcodes instantly with brightness boost and screen wake
- ✅ **Quick Scan** - Snap a photo or pick from library to auto-extract barcode and card color
- ✅ **Smart Search** - Search and sort cards by name, store, or recent usage
- ✅ **Localized** - Full Bulgarian translation with English as base language
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
- ✅ Quick Scan: auto-extract barcode and color from photo or camera
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

3. Build and run:
```bash
mise run build
```

Or open `kartonche.xcodeproj` in Xcode and run.

## Development

### Using mise Tasks

We use [mise](https://mise.jdx.dev/) for task automation:

```bash
# Build and test
mise run build            # Build the app (Debug)
mise run test             # Run unit tests
mise run test-ui          # Run UI tests
mise run test-all         # Run all tests (unit + UI)
mise run clean            # Clean build artifacts
mise run check            # Clean build and show all warnings/errors
mise run check-i18n       # Check localization completeness
mise run dev              # Clean + build + test

# Release and distribution
mise run changelog-preview    # Preview unreleased changes
mise run changelog-update     # Update CHANGELOG.md
mise run release              # Prepare a new release (bump version)
mise run tag-release          # Tag release and generate changelog
mise run archive              # Archive the app for distribution
mise run testflight           # Bump build, archive, upload to TestFlight

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
├── action/                # App Action extension
├── quicklook/             # QuickLook preview extension
├── widget/                # Home screen, lock screen, and control widgets
├── kartoncheTests/        # Unit tests
├── kartoncheUITests/      # UI tests
└── Scripts/               # Build scripts
    └── generate-about-icon.sh  # Xcode build phase for app icon
```

## Documentation

- **[AGENTS.md](AGENTS.md)** - Coding guidelines, localization rules, commit conventions
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical decisions, data models, architecture patterns
- **[CHANGELOG.md](CHANGELOG.md)** - Version history (auto-generated from commits)

## Contributing

We welcome contributions!

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

# Full CI check (build + test)
mise run ci
```

### Continuous Integration

GitHub Actions automatically:
- Runs unit tests on all PRs and main branch pushes

See [.github/workflows/](.github/workflows/) for workflow definitions.

## Technology Stack

- **Language:** Swift 6.2+
- **Framework:** SwiftUI + SwiftData (iOS 26.2+)
- **Barcode:** VisionKit (scanning) + Core Image (generation)
- **Storage:** Local-only SwiftData (no cloud sync)
- **Localization:** String Catalogs (English base, Bulgarian translation)
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
