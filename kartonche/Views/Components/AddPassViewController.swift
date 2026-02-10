//
//  AddPassViewController.swift
//  kartonche
//
//  Created on 2026-02-10.
//

import SwiftUI
import PassKit

struct AddPassViewController: UIViewControllerRepresentable {
    let pass: PKPass
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> PKAddPassesViewController {
        let controller = PKAddPassesViewController(pass: pass)!
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: PKAddPassesViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    class Coordinator: NSObject, PKAddPassesViewControllerDelegate {
        let onDismiss: () -> Void

        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }

        func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
            onDismiss()
        }
    }
}
