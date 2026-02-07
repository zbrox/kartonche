//
//  MapLocationPicker.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import SwiftUI
import MapKit

/// Interactive map view for dropping a pin to select a location
struct MapLocationPicker: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    
    let onSelect: (CLLocationCoordinate2D) -> Void
    
    @State private var cameraPosition: MapCameraPosition
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var mapRegion: MKCoordinateRegion
    
    init(initialCoordinate: CLLocationCoordinate2D? = nil, onSelect: @escaping (CLLocationCoordinate2D) -> Void) {
        self.onSelect = onSelect
        
        // Default to Sofia, Bulgaria or provided coordinate
        let coordinate = initialCoordinate ?? CLLocationCoordinate2D(latitude: 42.6977, longitude: 23.3219)
        
        _mapRegion = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
        
        _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )))
        
        _selectedCoordinate = State(initialValue: initialCoordinate)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Map view
                Map(position: $cameraPosition) {
                    if let coordinate = selectedCoordinate {
                        Annotation("", coordinate: coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.red)
                                .background(
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 30, height: 30)
                                )
                        }
                    }
                }
                .mapStyle(.standard)
                .onTapGesture { location in
                    // Convert tap location to coordinate
                    // Note: This is approximate - MapKit doesn't provide direct tap-to-coordinate
                    // We'll use the center of the map when user confirms
                }
                .onMapCameraChange { context in
                    // Update selected coordinate to map center when camera moves
                    selectedCoordinate = context.region.center
                }
                
                // Crosshair in center
                VStack {
                    Spacer()
                    Image(systemName: "plus")
                        .font(.system(size: 30))
                        .foregroundStyle(.red)
                        .background(
                            Circle()
                                .fill(.white)
                                .frame(width: 50, height: 50)
                        )
                        .shadow(radius: 3)
                    Spacer()
                }
                
                // Controls overlay
                VStack {
                    Spacer()
                    
                    HStack(spacing: 16) {
                        // Current location button
                        Button {
                            centerOnCurrentLocation()
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                                .background(.blue)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        
                        Spacer()
                        
                        // Confirm button
                        Button {
                            confirmSelection()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text(String(localized: "Confirm Location"))
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(.green)
                            .clipShape(Capsule())
                            .shadow(radius: 3)
                        }
                        .disabled(selectedCoordinate == nil)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle(String(localized: "Drop Pin on Map"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Try to center on current location if available
                if locationManager.authorizationStatus == .authorizedWhenInUse ||
                   locationManager.authorizationStatus == .authorizedAlways {
                    locationManager.requestLocation()
                    
                    // Wait a bit then center on current location
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(1))
                        
                        if let currentLocation = locationManager.currentLocation {
                            let region = MKCoordinateRegion(
                                center: currentLocation.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                            cameraPosition = .region(region)
                            selectedCoordinate = currentLocation.coordinate
                        }
                    }
                }
            }
        }
    }
    
    private func centerOnCurrentLocation() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            return
        }
        
        locationManager.requestLocation()
        
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            
            if let currentLocation = locationManager.currentLocation {
                let region = MKCoordinateRegion(
                    center: currentLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                withAnimation {
                    cameraPosition = .region(region)
                    selectedCoordinate = currentLocation.coordinate
                }
            }
        }
    }
    
    private func confirmSelection() {
        // Use the selected coordinate (which is updated as map moves)
        guard let coordinate = selectedCoordinate else { return }
        onSelect(coordinate)
        dismiss()
    }
}

#Preview {
    MapLocationPicker { coordinate in
        print("Selected: \(coordinate)")
    }
}
