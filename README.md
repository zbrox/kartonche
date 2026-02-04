# kartonche

A modern, open-source iOS app for managing loyalty cards in Bulgaria.

## Overview

kartonche (картонче, "small card" in Bulgarian) is a native iOS app that helps you digitize and organize all your loyalty cards from Bulgarian stores, gas stations, pharmacies, and more. No more fumbling through your wallet at checkout - just open the app, select your card, and scan.

### Key Features (Planned)

- 📸 **Barcode Scanning** - Scan physical cards with your camera
- 🎯 **Quick Access** - Display barcodes instantly for scanning at checkout
- 🏪 **Merchant Templates** - Pre-configured templates for popular Bulgarian stores
- 📱 **Widgets** - Add favorite cards to your home screen
- ☁️ **iCloud Sync** - Seamlessly sync across all your devices
- 🌍 **Bulgarian-First** - Interface in Bulgarian with English support

## Current Status

🚧 **In Active Development** - Sprint 0 (Project Setup) Complete

We've completed the foundation:
- ✅ Project architecture documented
- ✅ Development workflow configured (mise)
- ✅ Conventional commits setup
- ✅ Bulgarian localization guidelines
- ✅ Community merchant database planned

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
mise run build          # Build the app
mise run test           # Run unit tests
mise run test-all       # Run all tests
mise run clean          # Clean build artifacts
mise run dev            # Clean + build + test

# CHANGELOG management
mise run changelog-preview    # Preview unreleased changes
mise run changelog-update     # Update CHANGELOG.md

# Merchant database (coming soon)
mise run merchants-list       # List all merchants
mise run merchant-add         # Interactive merchant creator

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
├── kartoncheTests/        # Unit tests
├── kartoncheUITests/      # UI tests
├── Merchants/             # Community merchant database (TBD)
└── Scripts/               # Build scripts (TBD)
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
2. Or manually edit `Merchants/merchants.kdl` (coming soon)
3. Follow the guidelines in `Merchants/README.md` (coming soon)
4. Submit a pull request

### Code Contributions

1. Read [AGENTS.md](AGENTS.md) for coding guidelines
2. Follow conventional commits format
3. Write tests for new features
4. Ensure Bulgarian localization uses neutral forms (not imperatives)

## Technology Stack

- **Language:** Swift 6.2+
- **Framework:** SwiftUI + SwiftData
- **Barcode:** VisionKit (scanning) + Core Image (generation)
- **Sync:** CloudKit (iCloud)
- **Localization:** String Catalogs (Bulgarian primary)
- **Dependencies:** Zero! All native Apple frameworks

## Roadmap

### MVP (Current Focus)
- [ ] Core card management (add, edit, delete)
- [ ] Barcode scanning and generation
- [ ] Merchant template database
- [ ] Home screen widgets
- [ ] iCloud sync
- [ ] Bulgarian + English localization

### Phase 2 (Future)
- [ ] Location-aware card suggestions
- [ ] Background geofencing notifications
- [ ] Apple Wallet integration (optional)
- [ ] Export/import functionality

See [TODO.md](TODO.md) for detailed implementation plan.

## License

MIT License - See [LICENSE](LICENSE) file (coming soon)

## Acknowledgments

Built with ❤️ for the Bulgarian community.

Special thanks to:
- Contributors who add merchant templates
- Early testers providing feedback
- The Bulgarian iOS developer community

---

**Status:** Pre-Alpha | **Version:** 0.1.0-dev | **Platform:** iOS 26.2+
