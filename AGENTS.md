# Agent Guidelines for kartonche

This iOS Swift/SwiftUI project uses SwiftData for persistence. Follow these guidelines when working in this codebase.

## Build, Test, and Lint Commands

### Building
```bash
# Build debug configuration
xcodebuild -project kartonche.xcodeproj -scheme kartonche -configuration Debug build

# Build release configuration  
xcodebuild -project kartonche.xcodeproj -scheme kartonche -configuration Release build

# Clean build folder
xcodebuild -project kartonche.xcodeproj -scheme kartonche clean
```

### Testing
```bash
# Run all tests (unit + UI)
xcodebuild test -project kartonche.xcodeproj -scheme kartonche -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Run only unit tests
xcodebuild test -project kartonche.xcodeproj -scheme kartonche -only-testing:kartoncheTests

# Run only UI tests
xcodebuild test -project kartonche.xcodeproj -scheme kartonche -only-testing:kartoncheUITests

# Run a single test
xcodebuild test -project kartonche.xcodeproj -scheme kartonche -only-testing:kartoncheTests/YourTestStruct/testMethodName
```

### Linting
No linter is currently configured. Standard Xcode warnings and Swift compiler checks apply.

## Project Structure

```
kartonche/
├── kartonche/              # Main app target
│   ├── kartoncheApp.swift  # App entry point with @main
│   ├── ContentView.swift   # Root view
│   ├── Item.swift          # SwiftData models
│   └── Assets.xcassets/    # Images, colors, app icon
├── kartoncheTests/         # Unit tests (Swift Testing framework)
└── kartoncheUITests/       # UI tests (XCTest framework)
```

## Code Style Guidelines

### Naming Conventions
- **Types (structs, classes, enums, protocols):** PascalCase (`ContentView`, `Item`, `ModelContainer`)
- **Variables, functions, parameters:** camelCase (`modelContext`, `addItem()`, `timestamp`)
- **Private functions:** Prefix with `private` keyword, use camelCase (`private func deleteItems()`)
- **File names:** Match primary type name (`Item.swift` contains `Item` class)

### Imports
- Import only what you need
- Standard order: Foundation/UIKit first, then SwiftUI, then SwiftData, then custom modules
- Use `@testable import kartonche` in test files only

Example:
```swift
import SwiftUI
import SwiftData
```

### File Organization
- One primary type per file
- File header comment with filename, project name, and creation date
- Imports, then main type definition, then extensions (if any)
- Private helper functions within the same file as the type using them
- SwiftUI previews at bottom using `#Preview` macro

### Types and Properties
- Use Swift's type inference where it improves readability
- Explicitly declare types for public APIs and complex expressions
- Prefer `let` over `var` whenever possible
- Use property wrappers: `@Environment`, `@Query`, `@Model`, `@State`, `@Binding`
- Mark SwiftData models with `@Model` macro
- Use `final class` for SwiftData models (prevents inheritance issues)

### SwiftUI Patterns
- Keep views small and composable
- Extract subviews when body becomes complex (>15 lines)
- Use `private var` for computed view properties
- Use `private func` for view helper methods
- Wrap state mutations in `withAnimation { }` when appropriate
- Use `NavigationSplitView` for master-detail layouts on iPad

### SwiftData Patterns
- Access model context via `@Environment(\.modelContext)`
- Query data using `@Query private var items: [Item]`
- Models must be classes marked with `@Model` and `final`
- Use explicit initializers for model properties
- Set up `ModelContainer` in app entry point
- Use `.modelContainer(for: Type.self, inMemory: true)` for previews

### Error Handling
- Use `do-catch` for throwing operations
- `fatalError()` is acceptable for unrecoverable errors during setup (e.g., ModelContainer creation)
- Provide descriptive error messages with context
- Don't silently swallow errors

### Testing
- **Unit tests:** Use Swift Testing framework with `@Test` macro
- **UI tests:** Use XCTest framework with `XCTestCase` subclasses
- Mark async tests with `async throws`
- Use `@MainActor` for tests that touch UI/SwiftData
- Use `@testable import kartonche` to access internal types
- Prefer Swift Testing (`#expect(...)`) over XCTest assertions for new unit tests
- Set up in-memory model containers for tests: `.modelContainer(for: Item.self, inMemory: true)`

Example Swift Testing test:
```swift
import Testing
@testable import kartonche

struct MyFeatureTests {
    @Test func exampleTest() async throws {
        #expect(someValue == expectedValue)
    }
}
```

### Formatting
- **Indentation:** 4 spaces (Xcode default)
- **Line length:** No hard limit, but keep lines readable (aim for <120 chars)
- **Braces:** Opening brace on same line, closing brace on new line
- **Spacing:** One blank line between functions, no blank line before closing brace
- **Trailing commas:** Not used in multi-line arrays/parameters
- **Blank lines:** One blank line between type members, two lines between types

### Comments
- Use `//` for single-line comments
- **ONLY add comments for:**
  - **DocStrings:** Public API documentation for auto-generated docs
  - **Non-obvious logic:** Complex algorithms, workarounds, or implementation details that aren't immediately clear
  - **Context:** Why something is done a certain way, not what it does
- **NEVER add comments that simply restate what the code does**
- Don't state the obvious
- Keep comments up to date with code changes
- Use `// MARK: -` to organize code sections in longer files

**Bad examples:**
```swift
// This function runs the car engine
func runCarEngine() { ... }

// Set the color to red
cardColor = .red

// Loop through all cards
for card in cards { ... }
```

**Good examples:**
```swift
// MARK: - Public API

/// Generates a barcode image for the given data and type.
/// - Parameters:
///   - data: The barcode data to encode
///   - type: The barcode format (QR, EAN-13, etc.)
/// - Returns: A high-resolution UIImage, or nil if generation fails
func generateBarcode(data: String, type: BarcodeType) -> UIImage? { ... }

// Core Image generates small QR codes, scale up 10x for display
let transform = CGAffineTransform(scaleX: 10, y: 10)

// Work around iOS 26.2 bug where brightness doesn't restore on iPad
if UIDevice.current.userInterfaceIdiom == .pad {
    // Force brightness restore after 100ms delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        UIScreen.main.brightness = originalBrightness
    }
}
```

### Version Control
This project should use jj (Jujutsu) for version control:
- Initialize with `jj git init` if not already tracked
- Create WIP bookmarks for feature work
- Commit logical units of work with descriptive messages
- Never commit secrets, API keys, or sensitive data

## Architecture

- **Pattern:** SwiftUI + SwiftData (declarative UI with reactive data)
- **Data Flow:** Unidirectional - SwiftData changes trigger view updates automatically
- **State Management:** SwiftData for persistence, SwiftUI property wrappers for view state
- **Concurrency:** Swift's async/await, actors, and `@MainActor` for UI code

## Bundle Identifiers
- Main app: `com.zbrox.kartonche`
- Unit tests: `com.zbrox.kartoncheTests`  
- UI tests: `com.zbrox.kartoncheUITests`

## Platform Targets
- **iOS:** 26.2+
- **Devices:** iPhone and iPad (universal)
- **Swift:** 6.2.3 (Swift 5 mode)
- **Xcode:** 26.2+

## Dependencies

### Runtime Dependencies
None. Project uses only Apple frameworks (SwiftUI, SwiftData, Foundation, XCTest).

### Development Tools
- **xcbeautify**: Pretty-print Xcode build output (managed by mise)
- **jq**: JSON processor for parsing .xcstrings and .stringsdata files (managed by mise)

## Key Principles
1. Keep code simple and readable - prefer clarity over cleverness
2. Follow Apple's Swift API Design Guidelines
3. Use modern Swift features (macros, property wrappers, async/await)
4. Maintain consistency with existing code style
5. Write tests for new features and bug fixes
6. Test output must be pristine - no unexpected warnings or logs
7. Make minimal changes to achieve goals - don't refactor unrelated code
8. Match the formatting and style of surrounding code exactly

## Development Workflow with mise

This project uses [mise](https://mise.jdx.dev/) for task automation and environment management.

### Common Tasks

**Build and test:**
```bash
mise run build          # Build the app (Debug)
mise run check          # Clean build + show all warnings/errors
mise run test           # Run unit tests
mise run test-ui        # Run UI tests
mise run test-all       # Run all tests
mise run clean          # Clean build artifacts
mise run dev            # Clean + build + test everything
```

**Localization:**
```bash
mise run check-i18n     # Check localization completeness and issues
```

Checks for:
- Missing Bulgarian translations (fails task if found)
- Strings needing review
- New untranslated strings  
- Unused strings in catalog
- Bulgarian keys without explicit translations

Uses Xcode's .stringsdata mechanism for accurate detection.

**Merchant database:**
```bash
mise run merchants-list        # List all merchants
mise run merchant-add          # Interactive merchant creator
mise run merchant-info bg.billa # Show merchant details
mise run merchant-count        # Statistics by category/barcode type
mise run validate-merchants    # Validate KDL syntax
mise run generate-merchants    # Generate Swift code from KDL
```

**CHANGELOG:**
```bash
mise run changelog-preview       # Preview unreleased changes
mise run changelog-update        # Update CHANGELOG.md
mise run changelog-tag v1.0.0    # Create release tag + update CHANGELOG
mise run release-notes           # Generate GitHub release notes
```

**CI workflow:**
```bash
mise run ci            # Full CI check (generate + build + test)
```

### Environment Variables

View current configuration:
```bash
mise env
```

Override defaults:
```bash
mise set CONFIGURATION=Release    # Use Release builds
mise set IOS_DEVICE="iPhone 15"   # Specific simulator
```

### Task Files

All tasks are in `.mise/tasks/` directory. Tasks use bash with usage hints for autocomplete.

## GitHub Actions CI Configuration

This project uses GitHub Actions for continuous integration with mise for task automation.

### CI Environment

**Runners:** macOS-15 (Intel x86_64)  
**Xcode:** 26.2  
**Minimum iOS Target:** 26.2  
**Test Device:** iPhone 16 Pro simulator (iOS 26.2)

### Environment Variables

CI uses these environment variables for consistent builds:

```bash
IOS_DEVICE="iPhone 16 Pro"    # Simulator device
IOS_VERSION="26.2"             # iOS version (matches minimum target)
```

These are configured in `mise.toml` and explicitly set in the GitHub Actions workflow.

### Full Destination Specification

All xcodebuild commands use complete destination specs to avoid "multiple matching destinations" warnings:

```bash
platform=iOS Simulator,name=iPhone 16 Pro,OS=26.2
```

This eliminates ambiguity and ensures consistent simulator selection in CI.

### Running CI Locally

Simulate CI environment:

```bash
# Use same configuration as CI (already defaults in mise.toml)
mise run ci           # CI workflow (unit tests only)
mise run ci --full    # Full CI workflow (unit + UI tests)
```

### Testing on Different iOS Versions

To test on different iOS versions or devices locally:

```bash
# Test on different device
mise set IOS_DEVICE="iPad Pro 11-inch (M4)"
mise run test

# Test on different iOS version (if available locally)
mise set IOS_VERSION="18.5"
mise run test

# Reset to defaults
mise unset IOS_DEVICE
mise unset IOS_VERSION
```

### Available Simulators in CI

GitHub Actions macOS-15 runners include:

- **iOS 18.x**: iPhone 16 Pro, iPhone 16, iPhone SE (3rd gen), iPads
- **iOS 26.x**: iPhone 17 Pro, iPhone 16 Pro, iPhone Air, iPads

Full list: [GitHub Runner Images - macOS-15](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md)

### Troubleshooting CI Failures

#### "Multiple matching destinations" warning

**Fixed** by specifying complete destination in all build/test tasks:
```bash
platform=iOS Simulator,name=iPhone 16 Pro,OS=26.2
```

#### Simulator not available

1. Check Xcode version is correctly selected (26.2 required for iOS 26.2)
2. Verify simulator exists: `xcrun simctl list devices | grep "iPhone 16 Pro"`
3. GitHub Actions occasionally has simulator availability issues - retry workflow
4. CI includes verification step that fails fast with clear error if simulator unavailable

#### Build failures on tags

Tags trigger full test suite (`mise run ci --full`). This includes:
- Unit tests (`kartoncheTests`)
- UI tests (`kartoncheUITests`)
- All merchant validation and generation

Check specific test failures in xcbeautify output.

## Merchant Database

### Community-Maintained Templates

The `Merchants/` directory contains a KDL database of Bulgarian stores/merchants with loyalty card information. This enables quick card setup for users.

**Format:** KDL (KDL Document Language)  
**Build-time:** Swift code auto-generated from `merchants.kdl`

### Adding Merchants

1. Edit `Merchants/merchants.kdl`
2. Follow the template:

```kdl
merchant id="bg.storename" {
    name "Store Name"
    name-bg "Име на Магазина"
    category "grocery"
    barcode-type "ean13"
    website "https://store.bg"      // optional
    suggested-color "#FF0000"       // optional
}
```

3. Validate: `mise run validate-merchants`
4. Generate code: `mise run generate-merchants`
5. Build: `mise run build`

See `Merchants/README.md` for detailed contributor guide.

## Git Commit Messages

### Conventional Commits Format

All commits MUST follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Commit messages MUST be in English** (even though UI is Bulgarian-primary).

### Types

| Type | Description | Example |
|------|-------------|---------|
| **feat** | New feature | `feat: add barcode scanning` |
| **fix** | Bug fix | `fix: restore brightness on card dismiss` |
| **docs** | Documentation only | `docs: update AGENTS.md with localization` |
| **style** | Code style (formatting, no logic change) | `style: format BarcodeGenerator` |
| **refactor** | Code refactoring | `refactor: extract merchant search logic` |
| **test** | Adding/updating tests | `test: add unit tests for barcode generation` |
| **chore** | Maintenance tasks | `chore: update dependencies` |

### Scopes (Optional)

Use scopes to indicate which part of the app changed:

- `barcode` - Barcode generation/scanning
- `merchant` - Merchant database
- `ui` - User interface changes
- `widget` - Widget functionality
- `sync` - iCloud sync
- `i18n` - Localization/translations
- `build` - Build system changes

**Examples:**
```
feat(barcode): add EAN-13 generation support
fix(widget): deep link to correct card
docs(merchant): add contributor guide
chore(build): update mise tasks
```

### Message Guidelines

**Short revision descriptions (ideally):**
- Keep first line under 50 characters when possible
- Use imperative mood: "add feature" not "added feature"
- No period at end of first line
- Capitalize first letter

**Good examples:**
```
feat: add merchant selection view
fix: brightness not restored on dismiss
docs: update ARCHITECTURE.md
test: add scanner error handling tests
```

**Bad examples:**
```
feat: Added a new merchant selection view for the app  (too long, wrong tense)
Fix brightness.  (not conventional format, vague)
Updated stuff  (vague, no type)
feat(merchant): Fixes bug with merchant search  (wrong type - should be 'fix')
```

### Breaking Changes

If a commit introduces breaking changes, add `!` after type/scope and include `BREAKING CHANGE:` footer:

```
feat!: change merchant ID format

BREAKING CHANGE: Merchant IDs now use reverse domain format (bg.store)
instead of simple names (store). Existing databases must be migrated.
```

### Body and Footer (Optional)

**Body:** Provide additional context if needed  
**Footer:** Reference issues, breaking changes, etc.

```
feat(barcode): add support for PDF417 format

Adds generation and scanning support for PDF417 barcodes,
commonly used by gas station loyalty cards in Bulgaria.

Closes #42
```

### Jujutsu Integration

Since we use jj (Jujutsu), use `jj describe` to write revision descriptions:

```bash
# Make changes
jj describe -m "feat: add barcode scanning"

# Or use editor for longer description
jj describe
# Opens editor with conventional commits format
```

git-cliff will automatically parse these descriptions when generating CHANGELOG.

## CHANGELOG Management

We use [git-cliff](https://git-cliff.org/) to auto-generate CHANGELOG.md from conventional commits.

**mise tasks:**
```bash
mise run changelog-preview       # Preview unreleased changes
mise run changelog-update        # Update CHANGELOG.md
mise run changelog-tag v1.0.0    # Create release tag + update CHANGELOG
mise run release-notes           # Generate GitHub release notes
```

CHANGELOG is automatically generated on each version tag. Don't edit CHANGELOG.md manually.

## Bulgarian Localization Guidelines

### Translation Style

**Use neutral forms, NOT imperatives** for UI elements (buttons, actions, menu items).

**Principle:** Bulgarian UI text should use noun forms (gerunds) rather than imperative verbs. This creates a more formal, polished, and modern user interface.

**Rule:** Prefer `-ане`/`-ене` gerund endings over imperative verb forms.

### Common UI Translation Examples

| English | ❌ Wrong (Imperative) | ✅ Correct (Neutral) | Notes |
|---------|---------------------|---------------------|-------|
| Close | Затвори | Затваряне | Button to dismiss |
| Save | Запази | Запазване | Save changes |
| Cancel | Откажи | Отказ | Cancel action |
| Delete | Изтрий | Изтриване | Delete item |
| Edit | Редактирай | Редактиране | Edit mode |
| Add | Добави | Добавяне | Add new item |
| Search | Търси | Търсене | Search action |
| Scan | Сканирай | Сканиране | Scan barcode |
| Share | Сподели | Споделяне | Share item |
| Export | Експортирай | Експортиране | Export data |
| Import | Импортирай | Импортиране | Import data |
| Select | Избери | Избор | Select item |
| Continue | Продължи | Продължаване | Continue flow |
| Confirm | Потвърди | Потвърждение | Confirm action |
| Refresh | Опресни | Опресняване | Refresh view |
| Filter | Филтрирай | Филтриране | Filter list |
| Sort | Сортирай | Сортиране | Sort items |
| Settings | Настройки | Настройки | Already neutral |
| Back | Назад | Назад | Already neutral |
| Done | Готово | Готово | Already neutral |

### Special Cases

**Toggle states:**
- "Enable" → "Включване" (not "Включи")
- "Disable" → "Изключване" (not "Изключи")
- "Show" → "Показване" (not "Покажи")
- "Hide" → "Скриване" (not "Скрий")

**Longer phrases:**
Keep them concise but natural:
- "Add New Card" → "Добавяне на карта" (not "Добави нова карта")
- "Scan Barcode" → "Сканиране на баркод" (not "Сканирай баркод")
- "Delete All" → "Изтриване на всички" (not "Изтрий всички")

**Alert buttons:**
Alert/dialog buttons can be slightly more direct but still avoid harsh imperatives:
- "OK" → "Добре" (neutral)
- "Yes" → "Да" (neutral)
- "No" → "Не" (neutral)
- "Allow" → "Разрешаване" (neutral gerund)
- "Don't Allow" → "Без разрешение" (neutral phrase)

### When Imperatives ARE Acceptable

**Instructional text / onboarding:**
In paragraphs explaining what to do, imperatives are natural:
- "Сканирайте баркода на вашата карта" (Scan the barcode on your card)
- "Изберете магазин от списъка" (Select a store from the list)

**Error messages / user guidance:**
When giving instructions in messages:
- "Моля, проверете връзката си с интернет" (Please check your internet connection)

**Rule of thumb:** 
- **UI elements (buttons, tabs, menu items)** → Neutral forms
- **Instructional text (help, onboarding, errors)** → Can use imperatives naturally

### Length Guidelines

**Prefer shorter phrases:**
- ✅ "Затваряне" (9 letters)
- ❌ "Затваряне на прозореца" (too long for button)

**No absurd abbreviations:**
- ✅ "Редактиране" (full word)
- ❌ "Ред." (too abbreviated)
- ❌ "Редакт." (too abbreviated)

**Context determines length:**
- Buttons: Shorter (1-2 words preferred)
- Section headers: Can be longer (2-3 words OK)
- Instructions: Natural sentence length

### Testing Translations

**When reviewing Bulgarian translations:**
1. Check UI buttons/actions use neutral forms (gerunds)
2. Verify phrases aren't unnecessarily long
3. Ensure no weird abbreviations
4. Read aloud - does it sound natural and professional?
5. Compare with popular Bulgarian apps (iOS Settings, etc.)

### String Catalog Best Practices

**Add context comments in English for translators:**
```swift
// In code:
Text("Close", comment: "Button to dismiss the card detail view")
Text("Add", comment: "Button to create a new loyalty card")
```

**In Localizable.xcstrings:**
- English: "Close"
- Bulgarian: "Затваряне"
- Comment: "Button to dismiss the card detail view"

This helps translators choose appropriate neutral forms.
