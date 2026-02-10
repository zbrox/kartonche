//
//  ActionViewController.swift
//  action
//
//  Created on 2026-02-10.
//

import UIKit
import UniformTypeIdentifiers

class ActionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            close()
            return
        }
        
        let typeIdentifier = "com.zbrox.kartonche.card"
        
        for attachment in attachments {
            if attachment.hasItemConformingToTypeIdentifier(typeIdentifier) {
                attachment.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { [weak self] item, error in
                    guard let self, let url = item as? URL else {
                        Task { @MainActor in self?.close() }
                        return
                    }
                    Task { @MainActor in self.openMainApp(with: url) }
                }
                return
            }
            
            if attachment.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                attachment.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { [weak self] item, error in
                    guard let self,
                          let url = item as? URL,
                          url.pathExtension == "kartonche" else {
                        Task { @MainActor in self?.close() }
                        return
                    }
                    Task { @MainActor in self.openMainApp(with: url) }
                }
                return
            }
        }
        
        close()
    }
    
    private func openMainApp(with fileURL: URL) {
        guard let sharedContainer = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.zbrox.kartonche"
        ) else {
            close()
            return
        }
        
        let destinationURL = sharedContainer.appendingPathComponent("pending_import.kartonche")
        
        do {
            try? FileManager.default.removeItem(at: destinationURL)
            
            _ = fileURL.startAccessingSecurityScopedResource()
            defer { fileURL.stopAccessingSecurityScopedResource() }
            
            try FileManager.default.copyItem(at: fileURL, to: destinationURL)
            
            guard let appURL = URL(string: "kartonche://import") else {
                close()
                return
            }
            
            extensionContext?.open(appURL) { [weak self] _ in
                Task { @MainActor in self?.close() }
            }
            return
        } catch {
            print("Failed to copy file: \(error)")
        }
        
        close()
    }
    
    private func close() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
