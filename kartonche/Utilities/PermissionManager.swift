//
//  PermissionManager.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-02-04.
//

import AVFoundation
import Photos
import SwiftUI
import UIKit

@MainActor
class PermissionManager: ObservableObject {
    @Published var cameraAuthorizationStatus: AVAuthorizationStatus
    @Published var photoLibraryAuthorizationStatus: PHAuthorizationStatus
    
    init() {
        self.cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        self.photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func requestCameraPermission() async -> Bool {
        cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            return true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            return granted
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    func requestPhotoLibraryPermission() async -> PHAuthorizationStatus {
        photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch photoLibraryAuthorizationStatus {
        case .authorized, .limited:
            return photoLibraryAuthorizationStatus
        case .notDetermined:
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            photoLibraryAuthorizationStatus = status
            return status
        case .denied, .restricted:
            return photoLibraryAuthorizationStatus
        @unknown default:
            return photoLibraryAuthorizationStatus
        }
    }
    
    func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            Task { @MainActor in
                await UIApplication.shared.open(settingsURL)
            }
        }
    }
}
