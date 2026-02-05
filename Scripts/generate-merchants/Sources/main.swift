import Foundation
import KDL

// MARK: - Command Line Arguments

struct Arguments {
    let inputFile: String
    let outputFile: String
    let validateOnly: Bool
    
    static func parse() throws -> Arguments {
        let args = CommandLine.arguments
        
        if args.contains("--validate-only") {
            guard args.count >= 2 else {
                throw GeneratorError.missingArgument("--input required for validation")
            }
            let inputIndex = args.firstIndex(of: "--input") ?? args.count - 1
            let inputFile = args[inputIndex + 1]
            return Arguments(inputFile: inputFile, outputFile: "", validateOnly: true)
        }
        
        guard let inputIndex = args.firstIndex(of: "--input"),
              inputIndex + 1 < args.count else {
            throw GeneratorError.missingArgument("--input")
        }
        
        guard let outputIndex = args.firstIndex(of: "--output"),
              outputIndex + 1 < args.count else {
            throw GeneratorError.missingArgument("--output")
        }
        
        return Arguments(
            inputFile: args[inputIndex + 1],
            outputFile: args[outputIndex + 1],
            validateOnly: false
        )
    }
}

// MARK: - Error Types

enum GeneratorError: Error, CustomStringConvertible {
    case missingArgument(String)
    case fileNotFound(String)
    case parseError(String)
    case validationError(String)
    
    var description: String {
        switch self {
        case .missingArgument(let arg):
            return "Missing required argument: \(arg)"
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .parseError(let message):
            return "Parse error: \(message)"
        case .validationError(let message):
            return "Validation error: \(message)"
        }
    }
}

// MARK: - Data Models

struct MerchantData {
    let id: String
    let name: String
    let otherNames: [String]
    let category: String
    let barcodeType: String?
    let website: String?
    let suggestedColor: String?
    let secondaryColor: String?
    let programs: [ProgramData]
}

struct ProgramData {
    let id: String?
    let name: String?
    let barcodeType: String
}

// MARK: - KDL Extensions

extension KDLDocument {
    var allNodes: [KDLNode] {
        let mirror = Mirror(reflecting: self)
        guard let nodes = mirror.children.first(where: { $0.label == "nodes" })?.value as? [KDLNode] else {
            return []
        }
        return nodes
    }
}

extension KDLNode {
    var nodeName: String {
        let mirror = Mirror(reflecting: self)
        guard let name = mirror.children.first(where: { $0.label == "name" })?.value as? String else {
            return ""
        }
        return name
    }
    
    var allChildren: [KDLNode] {
        let mirror = Mirror(reflecting: self)
        guard let children = mirror.children.first(where: { $0.label == "children" })?.value as? [KDLNode] else {
            return []
        }
        return children
    }
}

extension KDLValue {
    var stringValue: String? {
        switch self {
        case .string(let value, _, _):
            return value
        default:
            return nil
        }
    }
}

// MARK: - KDL Parser

func parseKDL(fileURL: URL) throws -> [MerchantData] {
    let content = try String(contentsOf: fileURL, encoding: .utf8)
    
    let document: KDLDocument
    do {
        document = try KDL.parseDocument(content)
    } catch {
        throw GeneratorError.parseError("Failed to parse KDL document: \(error)")
    }
    
    var merchants: [MerchantData] = []
    
    for node in document.allNodes {
        guard node.nodeName == "merchant" else {
            throw GeneratorError.validationError("Unknown toplevel node: \(node.nodeName)")
        }
        
        guard let id = node["id"]?.stringValue else {
            throw GeneratorError.validationError("Merchant missing required 'id' property")
        }
        
        guard let name = node.child("name")?.arg?.stringValue else {
            throw GeneratorError.validationError("Merchant \(id) missing 'name'")
        }
        
        guard let category = node.child("category")?.arg?.stringValue else {
            throw GeneratorError.validationError("Merchant \(id) missing 'category'")
        }
        
        let otherNames: [String]
        if let otherNamesNode = node.child("other-names") {
            let mirror = Mirror(reflecting: otherNamesNode)
            if let args = mirror.children.first(where: { $0.label == "arguments" })?.value as? [KDLValue] {
                otherNames = args.compactMap { $0.stringValue }
            } else {
                otherNames = []
            }
        } else {
            otherNames = []
        }
        
        let barcodeType = node.child("barcode-type")?.arg?.stringValue
        let website = node.child("website")?.arg?.stringValue
        let suggestedColor = node.child("suggested-color")?.arg?.stringValue
        let secondaryColor = node.child("secondary-color")?.arg?.stringValue
        
        let programNodes = node.allChildren.filter { $0.nodeName == "program" }
        var programs: [ProgramData] = []
        
        for programNode in programNodes {
            let programId = programNode["id"]?.stringValue
            let programName = programNode.child("name")?.arg?.stringValue
            
            guard let programBarcodeType = programNode.child("barcode-type")?.arg?.stringValue else {
                throw GeneratorError.validationError("Program in merchant \(id) missing 'barcode-type'")
            }
            
            programs.append(ProgramData(
                id: programId,
                name: programName,
                barcodeType: programBarcodeType
            ))
        }
        
        // Validate: either barcode-type at merchant level OR programs
        if programs.isEmpty && barcodeType == nil {
            throw GeneratorError.validationError("Merchant \(id) must have either 'barcode-type' or 'program' nodes")
        }
        
        if !programs.isEmpty && barcodeType != nil {
            throw GeneratorError.validationError("Merchant \(id) cannot have both 'barcode-type' and 'program' nodes")
        }
        
        merchants.append(MerchantData(
            id: id,
            name: name,
            otherNames: otherNames,
            category: category,
            barcodeType: barcodeType,
            website: website,
            suggestedColor: suggestedColor,
            secondaryColor: secondaryColor,
            programs: programs
        ))
    }
    
    return merchants
}

// MARK: - Swift Code Generator

func generateSwiftCode(merchants: [MerchantData]) -> String {
    var output = """
    // Auto-generated from Merchants/merchants.kdl
    // DO NOT EDIT - Changes will be overwritten
    // Generated on: \(Date())
    
    import Foundation
    
    // MARK: - Merchant Category
    
    enum MerchantCategory: String, Codable, CaseIterable {
        case grocery
        case fuel
        case pharmacy
        case retail
        
        var displayName: String {
            switch self {
            case .grocery: return String(localized: "Хранителни магазини")
            case .fuel: return String(localized: "Бензиностанции")
            case .pharmacy: return String(localized: "Аптеки")
            case .retail: return String(localized: "Други")
            }
        }
    }
    
    // MARK: - Program Template
    
    struct ProgramTemplate: Identifiable {
        let id: String
        let name: String?
        let barcodeType: BarcodeType
    }
    
    // MARK: - Merchant Template
    
    struct MerchantTemplate: Identifiable {
        let id: String
        let name: String
        let otherNames: [String]
        let category: MerchantCategory
        let website: String?
        let suggestedColor: String?
        let secondaryColor: String?
        let programs: [ProgramTemplate]
        
        var displayName: String { name }
        
        var initials: String {
            let words = name.split(separator: " ")
            if words.count >= 2 {
                return words.prefix(2)
                    .compactMap { $0.first.map(String.init) }
                    .joined()
                    .uppercased()
            } else {
                return String(name.prefix(1)).uppercased()
            }
        }
        
        var hasSingleProgram: Bool {
            programs.count == 1
        }
    }
    
    // MARK: - Merchant Data
    
    extension MerchantTemplate {
        static let all: [MerchantTemplate] = [
    
    """
    
    for merchant in merchants {
        let otherNamesArray = merchant.otherNames.isEmpty ? "[]" : "[\(merchant.otherNames.map { "\"\($0)\"" }.joined(separator: ", "))]"
        let website = merchant.website.map { "\"\($0)\"" } ?? "nil"
        let suggestedColor = merchant.suggestedColor.map { "\"\($0)\"" } ?? "nil"
        let secondaryColor = merchant.secondaryColor.map { "\"\($0)\"" } ?? "nil"
        
        var programsCode: String
        if merchant.programs.isEmpty, let barcodeType = merchant.barcodeType {
            programsCode = "[ProgramTemplate(id: \"\(merchant.id)\", name: nil, barcodeType: .\(barcodeType))]"
        } else {
            let programLines = merchant.programs.map { program in
                let programId = program.id ?? "default"
                let programName = program.name.map { "\"\($0)\"" } ?? "nil"
                return "ProgramTemplate(id: \"\(programId)\", name: \(programName), barcodeType: .\(program.barcodeType))"
            }
            programsCode = "[\n                \(programLines.joined(separator: ",\n                "))\n            ]"
        }
        
        output += """
                MerchantTemplate(
                    id: "\(merchant.id)",
                    name: "\(merchant.name)",
                    otherNames: \(otherNamesArray),
                    category: .\(merchant.category),
                    website: \(website),
                    suggestedColor: \(suggestedColor),
                    secondaryColor: \(secondaryColor),
                    programs: \(programsCode)
                ),
        
        """
    }
    
    output += """
            ]
        
        static func search(_ query: String) -> [MerchantTemplate] {
            guard !query.isEmpty else { return all }
            
            let normalized = query.lowercased()
                .folding(options: .diacriticInsensitive, locale: .current)
            
            return all.filter { merchant in
                let nameMatch = merchant.name.lowercased().contains(normalized)
                let otherNamesMatch = merchant.otherNames.contains { altName in
                    altName.lowercased().contains(normalized)
                }
                return nameMatch || otherNamesMatch
            }
            .sorted { lhs, rhs in
                let lhsExact = lhs.name.lowercased() == normalized
                let rhsExact = rhs.name.lowercased() == normalized
                if lhsExact != rhsExact { return lhsExact }
                
                let lhsStarts = lhs.name.lowercased().hasPrefix(normalized)
                let rhsStarts = rhs.name.lowercased().hasPrefix(normalized)
                if lhsStarts != rhsStarts { return lhsStarts }
                
                return lhs.name < rhs.name
            }
        }
        
        static func grouped() -> [MerchantCategory: [MerchantTemplate]] {
            Dictionary(grouping: all, by: \\.category)
        }
    }
    
    """
    
    return output
}

// MARK: - Main

do {
    let args = try Arguments.parse()
    
    let inputURL = URL(fileURLWithPath: args.inputFile)
    guard FileManager.default.fileExists(atPath: inputURL.path) else {
        throw GeneratorError.fileNotFound(args.inputFile)
    }
    
    print("Parsing \(args.inputFile)...")
    let merchants = try parseKDL(fileURL: inputURL)
    print("✓ Parsed \(merchants.count) merchants")
    
    if args.validateOnly {
        print("✓ Validation successful")
        exit(0)
    }
    
    print("Generating Swift code...")
    let swiftCode = generateSwiftCode(merchants: merchants)
    
    let outputURL = URL(fileURLWithPath: args.outputFile)
    try swiftCode.write(to: outputURL, atomically: true, encoding: .utf8)
    
    print("✓ Generated \(args.outputFile)")
    let programCount = merchants.map { $0.programs.isEmpty ? 1 : $0.programs.count }.reduce(0, +)
    print("✓ \(merchants.count) merchants, \(programCount) programs")
    
} catch {
    print("ERROR: \(error)")
    exit(1)
}
