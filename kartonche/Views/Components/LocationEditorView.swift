//
//  LocationEditorView.swift
//  kartonche
//
//  Created on 2026-02-06.
//

import SwiftUI
import MapKit

struct LocationEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    
    let card: LoyaltyCard
    let location: CardLocation?
    let onSave: (CardLocation) -> Void
    
    @State private var name: String
    @State private var address: String
    @State private var latitude: Double
    @State private var longitude: Double
    @State private var radius: Double
    
    @State private var searchText = ""
    @State private var searchResults: [MKLocalSearchCompletion] = []
    @State private var searchCompleter = MKLocalSearchCompleter()
    @State private var searchCompleterDelegate: SearchCompleterDelegate?
    @State private var isSearching = false
    
    @State private var showingPermissionRequest = false
    @State private var showingPermissionDenied = false
    @State private var isUsingCurrentLocation = false
    @State private var currentLocationError: String?
    @State private var searchError: String?
    @State private var showingMapPicker = false
    
    private var isEditMode: Bool { location != nil }
    
    init(card: LoyaltyCard, location: CardLocation? = nil, onSave: @escaping (CardLocation) -> Void) {
        self.card = card
        self.location = location
        self.onSave = onSave
        
        if let location = location {
            _name = State(initialValue: location.name)
            _address = State(initialValue: location.address)
            _latitude = State(initialValue: location.latitude)
            _longitude = State(initialValue: location.longitude)
            _radius = State(initialValue: location.radius)
        } else {
            _name = State(initialValue: "")
            _address = State(initialValue: "")
            _latitude = State(initialValue: 0.0)
            _longitude = State(initialValue: 0.0)
            _radius = State(initialValue: 500.0)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Name field
                Section {
                    TextField(String(localized: "Location Name"), text: $name)
                        .accessibilityIdentifier("locationNameField")
                }
                
                // Location selection section - completely different based on state
                if !hasValidAddress {
                    // BEFORE: Show options to select location
                    Section {
                        Button {
                            useCurrentLocation()
                        } label: {
                            HStack {
                                Image(systemName: "location.circle.fill")
                                Text(String(localized: "Use Current Location"))
                                Spacer()
                                if isUsingCurrentLocation {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isUsingCurrentLocation)
                        
                        Button {
                            showingMapPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                Text(String(localized: "Drop Pin on Map"))
                            }
                        }
                        
                        if let error = currentLocationError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Section {
                        TextField(String(localized: "Search for address..."), text: $searchText)
                            .accessibilityIdentifier("addressSearchField")
                            .onChange(of: searchText) { _, newValue in
                                if !newValue.isEmpty {
                                    searchCompleter.queryFragment = newValue
                                    isSearching = true
                                    searchError = nil
                                } else {
                                    isSearching = false
                                    searchResults = []
                                }
                            }
                        
                        if let error = searchError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    } footer: {
                        Text(String(localized: "Type to search, then tap a result"))
                            .font(.caption)
                    }
                    
                    // Search results
                    if isSearching && !searchResults.isEmpty {
                        Section {
                            ForEach(searchResults, id: \.self) { result in
                                Button {
                                    selectSearchResult(result)
                                } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(result.title)
                                            .foregroundStyle(.primary)
                                        Text(result.subtitle)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    // AFTER: Show selected location cleanly
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Label {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(address)
                                        .foregroundStyle(.primary)
                                    Text(String(format: "%.6f° N, %.6f° E", latitude, longitude))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                }
                            } icon: {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                                    .imageScale(.large)
                            }
                            
                            Button {
                                // Clear location to allow reselection
                                address = ""
                                latitude = 0.0
                                longitude = 0.0
                                searchText = ""
                                searchResults = []
                                isSearching = false
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text(String(localized: "Change Location"))
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                
                // Radius section - always visible
                Section {
                    HStack {
                        Text("\(Int(radius))m")
                            .monospacedDigit()
                            .frame(width: 60, alignment: .leading)
                        Slider(value: $radius, in: 100...2000, step: 50)
                    }
                } header: {
                    Text(String(localized: "Detection Radius"))
                } footer: {
                    Text(String(localized: "Card will appear when you're within this distance"))
                        .font(.caption)
                }
            }
            .navigationTitle(isEditMode ? String(localized: "Edit Location") : String(localized: "Add Location"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                    .accessibilityIdentifier("cancelButton")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        saveLocation()
                    }
                    .disabled(!isValid)
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onAppear {
                setupSearchCompleter()
                checkLocationPermission()
            }
            .sheet(isPresented: $showingPermissionRequest) {
                LocationPermissionView(
                    onAllow: {
                        locationManager.requestPermission()
                        showingPermissionRequest = false
                    },
                    onDeny: {
                        showingPermissionRequest = false
                        dismiss()
                    }
                )
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showingPermissionDenied) {
                LocationPermissionDeniedView(
                    onOpenSettings: {
                        locationManager.openSettings()
                        showingPermissionDenied = false
                        dismiss()
                    },
                    onCancel: {
                        showingPermissionDenied = false
                        dismiss()
                    }
                )
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showingMapPicker) {
                MapLocationPicker { coordinate in
                    handleMapSelection(coordinate)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty && hasValidAddress && hasValidCoordinates
    }
    
    private var hasValidAddress: Bool {
        !address.isEmpty
    }
    
    private var hasValidCoordinates: Bool {
        latitude != 0.0 && longitude != 0.0
    }
    
    private func checkLocationPermission() {
        // Only check permission if we're adding a new location (not editing)
        guard location == nil else { return }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            showingPermissionRequest = true
        case .denied, .restricted:
            showingPermissionDenied = true
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission granted, continue
            break
        @unknown default:
            break
        }
    }
    
    private func setupSearchCompleter() {
        // Allow both addresses and points of interest for more flexible search
        searchCompleter.resultTypes = [.address, .pointOfInterest]
        
        // Set region to Bulgaria for better local results
        searchCompleter.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 42.7339, longitude: 25.4858), // Center of Bulgaria
            span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
        )
        
        // Create and store the delegate to prevent it from being deallocated
        let delegate = SearchCompleterDelegate(
            onUpdate: { [self] results in
                searchResults = results
                searchError = nil
            },
            onError: { [self] error in
                searchError = String(localized: "Search failed. Check your internet connection.")
                searchResults = []
            }
        )
        
        searchCompleterDelegate = delegate
        searchCompleter.delegate = delegate
    }
    
    private func selectSearchResult(_ result: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response = response, let mapItem = response.mapItems.first else {
                searchError = String(localized: "Unable to find location details")
                return
            }
            
            // Auto-fill name if it's empty
            if name.isEmpty {
                name = mapItem.name ?? result.title
            }
            
            address = "\(result.title), \(result.subtitle)"
            latitude = mapItem.location.coordinate.latitude
            longitude = mapItem.location.coordinate.longitude
            
            searchText = ""
            isSearching = false
            searchResults = []
            searchError = nil
        }
    }
    
    private func handleMapSelection(_ coordinate: CLLocationCoordinate2D) {
        // Reverse geocode the selected coordinate
        Task {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            do {
                let (geocodedName, geocodedAddress) = try await GeocodingService.reverseGeocode(location: location)
                
                await MainActor.run {
                    // Auto-fill name if empty
                    if name.isEmpty {
                        name = geocodedName
                    }
                    
                    address = geocodedAddress
                    latitude = coordinate.latitude
                    longitude = coordinate.longitude
                }
            } catch {
                await MainActor.run {
                    // Even if geocoding fails, use the coordinates
                    if name.isEmpty {
                        name = String(localized: "Selected Location")
                    }
                    address = String(format: "%.6f° N, %.6f° E", coordinate.latitude, coordinate.longitude)
                    latitude = coordinate.latitude
                    longitude = coordinate.longitude
                }
            }
        }
    }
    
    private func useCurrentLocation() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            currentLocationError = String(localized: "Location permission not granted")
            if locationManager.authorizationStatus == .notDetermined {
                showingPermissionRequest = true
            } else {
                showingPermissionDenied = true
            }
            return
        }
        
        isUsingCurrentLocation = true
        currentLocationError = nil
        
        Task {
            // Request current location
            await MainActor.run {
                locationManager.requestLocation()
            }
            
            // Wait a bit for location to be fetched
            try? await Task.sleep(for: .seconds(2))
            
            guard let currentLocation = locationManager.currentLocation else {
                await MainActor.run {
                    currentLocationError = String(localized: "Unable to get current location")
                    isUsingCurrentLocation = false
                }
                return
            }
            
            do {
                let (geocodedName, geocodedAddress) = try await GeocodingService.reverseGeocode(location: currentLocation)
                
                await MainActor.run {
                    // Auto-fill name if empty
                    if name.isEmpty {
                        name = geocodedName
                    }
                    
                    address = geocodedAddress
                    latitude = currentLocation.coordinate.latitude
                    longitude = currentLocation.coordinate.longitude
                    
                    isUsingCurrentLocation = false
                    currentLocationError = nil
                }
            } catch {
                await MainActor.run {
                    currentLocationError = error.localizedDescription
                    isUsingCurrentLocation = false
                }
            }
        }
    }
    
    private func saveLocation() {
        let savedLocation: CardLocation
        
        if let location = location {
            // Update existing location
            location.name = name
            location.address = address
            location.latitude = latitude
            location.longitude = longitude
            location.radius = radius
            savedLocation = location
        } else {
            // Create new location
            savedLocation = CardLocation(
                name: name,
                address: address,
                latitude: latitude,
                longitude: longitude,
                radius: radius
            )
        }
        
        onSave(savedLocation)
        dismiss()
    }
}

// MARK: - Search Completer Delegate

private class SearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
    let onUpdate: ([MKLocalSearchCompletion]) -> Void
    let onError: (Error) -> Void
    
    init(onUpdate: @escaping ([MKLocalSearchCompletion]) -> Void, onError: @escaping (Error) -> Void) {
        self.onUpdate = onUpdate
        self.onError = onError
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        onUpdate(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        onError(error)
    }
}

#Preview {
    LocationEditorView(
        card: LoyaltyCard(
            name: "Billa Club",
            storeName: "Billa",
            cardNumber: "1234567890123",
            barcodeType: .ean13,
            barcodeData: "1234567890123"
        )
    ) { location in
        print("Saved location: \(location.name)")
    }
}
