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
        
        guard let firstCard = container.cards.first else {
            throw PreviewError.noCards
        }
        
        // Create the preview view
        let previewView = CardPreviewView(card: firstCard)
        let hostingController = UIHostingController(rootView: previewView)
        
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
