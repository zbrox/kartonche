# Bulgarian Merchant Loyalty Card Database

This directory contains a community-maintained database of Bulgarian merchants and their loyalty card programs. The database enables users to quickly add loyalty cards from pre-configured templates instead of manual entry.

## Purpose

The merchant database provides:
- **Quick card setup**: Select a merchant and get pre-filled card details
- **Search functionality**: Find merchants in both Latin and Cyrillic
- **Accurate barcode types**: Correct barcode format for each program
- **Brand colors**: Visually distinctive card colors

## Database Format

The database uses [KDL (KDL Document Language)](https://kdl.dev/), a human-readable configuration language designed for easy editing and version control.

### File Structure

```
Merchants/
├── merchants.kdl     # Main database (this is what you edit)
├── schema.kdl        # Schema documentation
└── README.md         # This file
```

## Contributing

### Adding a New Merchant

1. **Research the merchant:**
   - Visit their Bulgarian website (e.g., `https://store.bg`)
   - Note how they write their brand name (Latin or Cyrillic)
   - Find their brand color (from logo or website theme)
   - Determine loyalty program name and barcode type
   - Add common search variations (Cyrillic if name is Latin, vice versa)

2. **Edit `merchants.kdl`:**

**For single-program merchants (most common):**
```kdl
merchant id="bg.storename" {
    name "Official Brand Name"
    other-names "Cyrillic Name" "Alt Spelling"
    category "grocery"  // or "fuel", "pharmacy", "retail"
    barcode-type "ean13"  // or "qr", "code128", "pdf417", "aztec"
    website "https://www.store.bg"
    suggested-color "#FF0000"
    secondary-color "#FFFFFF"  // Text color for initials
}
```

**For multi-program merchants (rare):**
```kdl
merchant id="bg.storename" {
    name "Official Brand Name"
    other-names "Cyrillic Name"
    category "grocery"
    website "https://www.store.bg"
    suggested-color "#FF0000"
    secondary-color "#FFFFFF"
    
    program id="regular" {
        name "Regular Card"
        barcode-type "ean13"
    }
    
    program id="premium" {
        name "Premium Card"
        barcode-type "qr"
    }
}
```

3. **Validate your changes:**

```bash
mise run validate-merchants
```

4. **Generate Swift code:**

```bash
mise run generate-merchants
```

5. **Test the build:**

```bash
mise run build
```

6. **Submit a pull request** or commit directly if you have access.

### Field Guidelines

#### `id` (required)
- **Format:** Reverse-domain notation: `bg.storename`
- **Rules:**
  - Must be unique
  - Lowercase only
  - No spaces or special characters (except dots)
  - Prefix with `bg.` for Bulgarian merchants
- **Examples:** `bg.billa`, `bg.kaufland`, `bg.dm`

#### `name` (required)
- **What:** Official brand name as shown on their website/storefront
- **Rules:**
  - Use the exact name the brand uses in Bulgaria
  - Can be Latin or Cyrillic
  - Maintain original capitalization (e.g., "BILLA", "Lidl")
- **Examples:** `"BILLA"`, `"Kaufland"`, `"Фантастико"`

#### `other-names` (optional but recommended)
- **What:** Alternative names for search
- **Rules:**
  - Include Cyrillic variant if name is Latin (and vice versa)
  - Add common abbreviations or misspellings
  - Add alternate spellings people might search for
- **Examples:**
  - `"Била" "Billa"` (for BILLA)
  - `"Кауфланд"` (for Kaufland)
  - `"дм" "dm"` (for dm drogerie markt)
  - `"Софармаси" "Софарма"` (for Sopharmacy)

#### `category` (required)
- **Options:** `"grocery"`, `"fuel"`, `"pharmacy"`, `"retail"`
- **Purpose:** Groups merchants in the UI

#### `website` (optional but recommended)
- **Format:** Full HTTPS URL
- **Example:** `"https://www.billa.bg"`

#### `suggested-color` (optional)
- **Format:** Hex color code `"#RRGGBB"`
- **How to find:**
  - Use color picker on merchant's logo
  - Check website CSS for brand colors
  - Use dominant color from branding
- **Examples:** `"#FFED00"` (Billa yellow), `"#FF0000"` (Kaufland red)

#### `program` (required, at least one)
- **What:** Loyalty program details
- **Can have multiple:** Some merchants have multiple card types (e.g., regular vs. premium)

#### `program.name` (optional)
- **What:** Loyalty program name
- **Examples:** `"BILLA Card"`, `"Lidl Plus"`, `"Kaufland Card"`

#### `program.barcode-type` (required)
- **Options:** `"qr"`, `"code128"`, `"ean13"`, `"pdf417"`, `"aztec"`
- **How to determine:**
  - Check merchant's website or mobile app
  - Look at physical loyalty card
  - **Common patterns:**
    - Grocery stores: Usually `ean13`
    - Fuel stations: Usually `code128`
    - Modern apps: Often `qr`
    - Airlines/transport: Sometimes `pdf417` or `aztec`

### Multiple Programs Example

For merchants with multiple loyalty card types:

```kdl
merchant id="bg.example" {
    name "Example Store"
    category "grocery"
    
    program id="regular" {
        name "Regular Card"
        barcode-type "ean13"
    }
    
    program id="premium" {
        name "Premium Card"
        barcode-type "qr"
    }
}
```

## Data Accuracy

### Verification Checklist

Before submitting a merchant:
- [ ] Visited merchant's official Bulgarian website
- [ ] Verified official brand name (Latin/Cyrillic)
- [ ] Confirmed barcode type (from website, app, or physical card)
- [ ] Added appropriate search variants (`other-names`)
- [ ] Validated KDL syntax (`mise run validate-merchants`)
- [ ] Generated Swift code (`mise run generate-merchants`)
- [ ] Tested app builds (`mise run build`)

### Data Sources Priority

1. **Official merchant website** (highest priority)
2. **Official mobile app** screenshots
3. **Physical loyalty card** examination
4. **Merchant customer service** confirmation
5. **Reasonable industry assumptions** (lowest priority - document with TODO)

### What NOT to Include

❌ **Do not add:**
- Personal card numbers or account information
- Merchant internal/employee cards
- Deprecated or discontinued programs
- Test/demo cards
- Merchants outside Bulgaria (unless they operate in Bulgaria)

## Build Integration

The merchant database is compiled into Swift code at build time:

1. **Input:** `Merchants/merchants.kdl`
2. **Generator:** `Scripts/generate-merchants/` (Swift package)
3. **Output:** `kartonche/Generated/MerchantTemplates.swift` (auto-generated, gitignored)

The generated code provides:
- `MerchantTemplate` struct with all merchant data
- `MerchantTemplate.all` - array of all merchants
- `MerchantTemplate.search(query)` - search function
- `MerchantTemplate.grouped()` - group by category

## Testing

After making changes:

```bash
# Validate KDL syntax
mise run validate-merchants

# Generate Swift code
mise run generate-merchants

# Build app
mise run build

# Run tests
mise run test
```

## Common Mistakes

### ❌ Wrong: Using English names
```kdl
name "Billa"  // Wrong if they use "BILLA" in Bulgaria
```

### ✅ Correct: Using official Bulgarian branding
```kdl
name "BILLA"
other-names "Била" "Billa"
```

### ❌ Wrong: Forgetting search variants
```kdl
name "Kaufland"
// No other-names - users searching "Кауфланд" won't find it
```

### ✅ Correct: Including Cyrillic search terms
```kdl
name "Kaufland"
other-names "Кауфланд"
```

### ❌ Wrong: Guessing barcode types
```kdl
barcode-type "qr"  // Unverified guess
```

### ✅ Correct: Verified barcode type
```kdl
barcode-type "ean13"  // Verified from official app/card
```

## Questions?

- Check `schema.kdl` for detailed field specifications
- Review existing entries in `merchants.kdl` for examples
- Ask in GitHub issues for clarification

## License

This merchant database is community-contributed and freely available for use in the kartonche app.

Brand names, logos, and colors are property of their respective owners. This database is for informational purposes only to help users manage their loyalty cards.
