//
//  MerchantSelectionOrderTests.swift
//  kartoncheTests
//
//  Created on 2026-02-05.
//

import Testing
@testable import kartonche

struct MerchantSelectionOrderTests {
    
    @Test func allMerchantsExist() async throws {
        let merchants = MerchantTemplate.all
        #expect(merchants.count == 14)
    }
    
    @Test func allMerchantsHavePrimaryColor() async throws {
        let merchants = MerchantTemplate.all
        for merchant in merchants {
            #expect(merchant.suggestedColor != nil, "Merchant \(merchant.name) missing primary color")
        }
    }
    
    @Test func allMerchantsHaveSecondaryColor() async throws {
        let merchants = MerchantTemplate.all
        for merchant in merchants {
            #expect(merchant.secondaryColor != nil, "Merchant \(merchant.name) missing secondary color")
        }
    }
    
    @Test func allProgramsHaveBarcodeType() async throws {
        let merchants = MerchantTemplate.all
        var totalPrograms = 0
        for merchant in merchants {
            for program in merchant.programs {
                // barcodeType is non-optional, so just verify it exists
                let _ = program.barcodeType
                totalPrograms += 1
            }
        }
        // Verify we have programs (14 single + 1 with 2 programs = 15 total)
        #expect(totalPrograms >= 14)
    }
}
