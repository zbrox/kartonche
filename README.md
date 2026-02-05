# kartonche

A modern, open-source iOS app for managing loyalty cards in Bulgaria.

## Overview

kartonche (картонче, "small card" in Bulgarian) is a native iOS app that helps you digitize and organize all your loyalty cards from Bulgarian stores, gas stations, pharmacies, and more. No more fumbling through your wallet at checkout - just open the app, select your card, and scan.

### Key Features

- ✅ **Barcode Generation** - Generate QR, Code128, EAN-13, PDF417, and Aztec barcodes
- ✅ **Barcode Scanning** - Scan physical cards with your camera using VisionKit
- ✅ **Quick Access** - Display barcodes instantly with brightness boost and screen wake
- ✅ **Merchant Templates** - Pre-configured templates for 14 popular Bulgarian stores
- ✅ **Smart Search** - Search and sort cards by name, store, or recent usage
- ✅ **Bulgarian-First** - Complete interface in Bulgarian with English fallback
- 🚧 **Widgets** - Add favorite cards to your home screen (coming soon)
- 💾 **Local Storage** - SwiftData-based storage (no paid developer account needed)

## Current Status

🚀 **Alpha Release** - Core Features Complete

**Completed Sprints:**
- ✅ **Sprint 0:** Project setup, documentation, architecture
- ✅ **Sprint 1:** Data models, permissions, complete Bulgarian localization
- ✅ **Sprint 2:** Barcode generation (5 types), scanning, display utilities
- ✅ **Sprint 3:** Card management UI (list, display, editor, search, sort)
- ✅ **Sprint 4:** Merchant database (14 merchants, KDL format, code generator)
- ✅ **Sprint 8:** Comprehensive unit tests (45 tests, 100% pass rate)
- ✅ **Sprint 9:** CI/CD (GitHub Actions for validation and testing)

**What Works:**
- ✅ Add/edit/delete loyalty cards
- ✅ Generate all major barcode types
- ✅ Scan barcodes with camera
- ✅ Display cards with brightness boost
- ✅ Search and sort cards
- ✅ Pre-configured merchant templates (BILLA, Kaufland, Lidl, OMV, Sopharmacy, etc.)
- ✅ Full Bulgarian localization

## Quick Start

**First time setup:**
```bash
git clone https://github.com/yourusername/kartonche.git
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
git clone https://github.com/yourusername/kartonche.git
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
├── TODO.md                # Sprint-by-sprint implementation plan
├── CHANGELOG.md           # Auto-generated from commits
├── mise.toml              # Development task configuration
├── .mise/tasks/           # Individual task scripts
├── kartonche/             # Main app code
│   ├── Models/            # SwiftData models
│   ├── Views/             # SwiftUI views and components
│   ├── Utilities/         # Helper classes (barcode, brightness, permissions)
│   ├── Resources/         # Localizable.xcstrings
│   └── Generated/         # Auto-generated code (gitignored)
├── kartoncheTests/        # Unit tests (45 tests)
├── kartoncheUITests/      # UI tests (coming soon)
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
- **[TODO.md](TODO.md)** - Detailed implementation roadmap
- **[CHANGELOG.md](CHANGELOG.md)** - Version history (auto-generated)

## Contributing

We welcome contributions! This is an open-source project focused on the Bulgarian market.

### Merchant Database

You can help by adding popular Bulgarian stores to our merchant template database:

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
3. Write tests for new features (we have 45 unit tests with 100% pass rate)
4. Run `mise run test` before committing
5. Ensure Bulgarian localization uses neutral forms (not imperatives)

### Testing

We maintain comprehensive test coverage:

```bash
# Run unit tests
mise run test

# Run UI tests (coming soon)
mise run test-ui

# Run all tests
mise run test-all

# Full CI check (generate + build + test)
mise run ci
```

**Current test coverage:**
- BarcodeType: 5 tests
- BarcodeGenerator: 7 tests  
- LoyaltyCard model: 4 tests
- MerchantTemplate: 13 tests
- ScreenManager: 3 tests
- BrightnessManager: 5 tests
- PermissionManager: 8 tests
- **Total: 45 tests, 100% passing ✅**

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
- **Testing:** Swift Testing framework (45 unit tests)
- **Dependencies:** Zero runtime dependencies! All native Apple frameworks

## Roadmap

### MVP (Near Complete)
- ✅ Core card management (add, edit, delete)
- ✅ Barcode scanning and generation (5 types)
- ✅ Merchant template database (14 merchants)
- ✅ Bulgarian + English localization
- ✅ Search and sort functionality
- ✅ Comprehensive unit tests (45 tests)
- ✅ CI/CD automation
- 🚧 Photo import for cards
- 🚧 Home screen widgets
- 🚧 UI tests

### Phase 2 (Future)
- [ ] Recently used tracking and favorites
- [ ] Color customization per card
- [ ] Location-aware card suggestions
- [ ] Background geofencing notifications
- [ ] Export/import functionality
- [ ] Apple Wallet integration (if user demand > 1000 users)

See [TODO.md](TODO.md) for detailed implementation plan.

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Acknowledgments

Built with ❤️ for the Bulgarian community.

Special thanks to:
- Contributors who add merchant templates
- Early testers providing feedback
- The Bulgarian iOS developer community

---

**Status:** Alpha | **Version:** 0.5.0-dev | **Platform:** iOS 26.2+ | **Tests:** 45/45 passing ✅
