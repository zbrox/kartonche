//
//  PreviewViewController.swift
//  kartoncheQuickLook
//
//  Created on 2026-02-10.
//

import UIKit
import QuickLook
import SwiftUI

class PreviewViewController: UIViewController, QLPreviewingController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    func preparePreviewOfFile(at url: URL) async throws {
        // Parse the .kartonche file
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let container = try decoder.decode(CardExportContainer.self, from: data)
        
        guard !container.cards.isEmpty else {
            throw PreviewError.noCards
        }

        // Single card: detailed preview; multiple cards: list overview
        let hostingController: UIHostingController<AnyView>
        if container.cards.count == 1 {
            hostingController = UIHostingController(rootView: AnyView(CardPreviewView(card: container.cards[0])))
        } else {
            hostingController = UIHostingController(rootView: AnyView(MultiCardPreviewView(container: container)))
        }
        
        // Add as child view controller
        await MainActor.run {
            addChild(hostingController)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(hostingController.view)
            
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            hostingController.didMove(toParent: self)
        }
    }
}

enum PreviewError: Error {
    case noCards
    case invalidData
}
