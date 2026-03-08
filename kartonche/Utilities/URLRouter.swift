//
//  URLRouter.swift
//  kartonche
//
//  Created on 2026-02-10.
//

import Foundation
import Observation

/// Routes incoming URLs to the appropriate view state
@Observable
final class URLRouter {
    /// URL of a .kartonche file waiting to be imported
    var pendingImportURL: URL?

    /// Deep link URL waiting to be processed
    var pendingDeepLinkURL: URL?

    /// Process a URL that may be a .kartonche file or deep link
    func handleURL(_ url: URL) {
        if url.pathExtension == "kartonche" {
            pendingImportURL = url
        } else if url.scheme == "kartonche" {
            pendingDeepLinkURL = url
        }
    }

    /// Clear the pending import after it's been processed
    func clearPendingImport() {
        pendingImportURL = nil
    }

    /// Clear the pending deep link after it's been processed
    func clearPendingDeepLink() {
        pendingDeepLinkURL = nil
    }
}
