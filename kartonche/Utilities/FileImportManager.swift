//
//  FileImportManager.swift
//  kartonche
//
//  Created on 2026-02-10.
//

import Foundation
import Observation

/// Manages file import state shared between App and views
@Observable
final class FileImportManager {
    private static let appGroupIdentifier = "group.com.zbrox.kartonche"
    private static let pendingImportFilename = "pending_import.kartonche"
    
    /// URL of a .kartonche file waiting to be imported
    var pendingImportURL: URL?
    
    /// Deep link URL waiting to be processed
    var pendingDeepLinkURL: URL?
    
    /// Process a URL that may be a .kartonche file or deep link
    func handleURL(_ url: URL) {
        if url.pathExtension == "kartonche" {
            pendingImportURL = url
        } else if url.scheme == "kartonche" && url.host == "import" {
            handleImportFromSharedContainer()
        } else if url.scheme == "kartonche" {
            pendingDeepLinkURL = url
        }
    }
    
    /// Read the pending import file from the shared app group container
    private func handleImportFromSharedContainer() {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier
        ) else {
            return
        }
        
        let fileURL = containerURL.appendingPathComponent(Self.pendingImportFilename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }
        
        pendingImportURL = fileURL
    }
    
    /// Clear the pending import after it's been processed
    func clearPendingImport() {
        // Clean up the shared container file if it exists
        if let url = pendingImportURL,
           url.path.contains(Self.appGroupIdentifier) {
            try? FileManager.default.removeItem(at: url)
        }
        pendingImportURL = nil
    }
    
    /// Clear the pending deep link after it's been processed
    func clearPendingDeepLink() {
        pendingDeepLinkURL = nil
    }
}
