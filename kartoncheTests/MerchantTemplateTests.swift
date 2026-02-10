//
//  MerchantTemplateTests.swift
//  kartoncheTests
//
//  Created on 2026-02-05.
//

import Testing
@testable import kartonche

@MainActor
struct MerchantTemplateTests {
    
    @Test func allMerchantsLoaded() {
        #expect(!MerchantTemplate.all.isEmpty, "Merchant list should not be empty")
        #expect(MerchantTemplate.all.count >= 5, "Should have at least 5 merchants")
    }
    
    @Test func merchantsHaveRequiredFields() {
        for merchant in MerchantTemplate.all {
            #expect(!merchant.id.isEmpty, "Merchant \(merchant.name) missing id")
            #expect(!merchant.name.isEmpty, "Merchant \(merchant.id) missing name")
            #expect(!merchant.programs.isEmpty, "Merchant \(merchant.name) has no programs")
        }
    }
    
    @Test func programsHaveValidBarcodeTypes() {
        for merchant in MerchantTemplate.all {
            for program in merchant.programs {
                #expect(
                    [BarcodeType.qr, .code128, .ean13, .pdf417, .aztec].contains(program.barcodeType),
                    "Merchant \(merchant.name) has invalid barcode type in program"
                )
            }
        }
    }
    
    @Test func categoriesAreValid() {
        let validCategories: Set<MerchantCategory> = [.grocery, .fuel, .pharmacy, .retail, .wholesale]
        for merchant in MerchantTemplate.all {
            #expect(validCategories.contains(merchant.category), "Merchant \(merchant.name) has invalid category")
        }
    }
    
    @Test func searchEmptyReturnsAll() {
        let results = MerchantTemplate.search("")
        #expect(results.count == MerchantTemplate.all.count, "Empty search should return all merchants")
    }
    
    @Test func searchLatinExactMatch() {
        let results = MerchantTemplate.search("BILLA")
        #expect(!results.isEmpty, "Should find BILLA by Latin name")
        #expect(results.contains(where: { $0.name == "BILLA" }), "Should match exact Latin name")
    }
    
    @Test func searchCyrillicMatch() {
        let results = MerchantTemplate.search("Кауфланд")
        #expect(!results.isEmpty, "Should find Kaufland by Cyrillic name")
        #expect(results.contains(where: { $0.name == "Kaufland" }), "Should match Cyrillic in other-names")
    }
    
    @Test func searchPartialMatch() {
        let results = MerchantTemplate.search("ил")
        #expect(!results.isEmpty, "Should find merchants with partial match")
        #expect(results.contains(where: { $0.otherNames.contains("Била") }), "Should match partial Cyrillic")
    }
    
    @Test func searchCaseInsensitive() {
        let lowerResults = MerchantTemplate.search("billa")
        let upperResults = MerchantTemplate.search("BILLA")
        #expect(lowerResults.count == upperResults.count, "Search should be case insensitive")
    }
    
    @Test func groupedByCategory() {
        let grouped = MerchantTemplate.grouped()
        #expect(!grouped.isEmpty, "Grouped merchants should not be empty")
        
        // Check that all categories with merchants are present
        for merchant in MerchantTemplate.all {
            #expect(grouped[merchant.category] != nil, "Category \(merchant.category) should be in grouped results")
        }
    }
    
    @Test func initialsExtraction() {
        let billa = MerchantTemplate.all.first(where: { $0.id == "bg.billa" })
        #expect(billa?.initials == "B", "BILLA should have initials 'B'")
        
        let tmarket = MerchantTemplate.all.first(where: { $0.id == "bg.tmarket" })
        #expect(tmarket?.initials == "TM", "T MARKET should have initials 'TM'")
        
        let metro = MerchantTemplate.all.first(where: { $0.id == "bg.metro" })
        #expect(metro?.initials == "MC", "Metro Cash & Carry should have initials 'MC'")
    }
    
    @Test func hasSingleProgramDetection() {
        let billa = MerchantTemplate.all.first(where: { $0.id == "bg.billa" })
        #expect(billa?.hasSingleProgram == true, "BILLA should have single program")
        
        let kaufland = MerchantTemplate.all.first(where: { $0.id == "bg.kaufland" })
        #expect(kaufland?.hasSingleProgram == true, "Kaufland should have single program")
    }
    
    @Test func colorHexValidity() {
        for merchant in MerchantTemplate.all {
            if let colorHex = merchant.suggestedColor {
                #expect(colorHex.hasPrefix("#"), "Color should start with #: \(merchant.name)")
                #expect(colorHex.count == 7, "Color should be #RRGGBB format: \(merchant.name)")
            }
            
            if let secondaryHex = merchant.secondaryColor {
                #expect(secondaryHex.hasPrefix("#"), "Secondary color should start with #: \(merchant.name)")
                #expect(secondaryHex.count == 7, "Secondary color should be #RRGGBB format: \(merchant.name)")
            }
        }
    }
    
    @Test func countryFieldIsValid() {
        for merchant in MerchantTemplate.all {
            #expect(!merchant.country.isEmpty, "Merchant \(merchant.name) should have a country")
            #expect(merchant.country.count == 2, "Country should be ISO 3166-1 alpha-2: \(merchant.name)")
            #expect(merchant.country == merchant.country.uppercased(), "Country should be uppercase: \(merchant.name)")
        }
    }
    
    @Test func countryFlagGeneration() {
        let billa = MerchantTemplate.all.first(where: { $0.id == "bg.billa" })
        #expect(billa?.countryFlag == "🇧🇬", "Bulgarian merchant should have BG flag")
    }
}
