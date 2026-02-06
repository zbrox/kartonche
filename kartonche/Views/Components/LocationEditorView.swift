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
    @State private var isSearching = false
    
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
                Section {
                    TextField(String(localized: "Location Name"), text: $name)
                        .accessibilityIdentifier("locationNameField")
                    
                    TextField(String(localized: "Search Address"), text: $searchText)
                        .accessibilityIdentifier("addressSearchField")
                        .onChange(of: searchText) { _, newValue in
                            if !newValue.isEmpty {
                                searchCompleter.queryFragment = newValue
                                isSearching = true
                            } else {
                                isSearching = false
                                searchResults = []
                            }
                        }
                    
                    if !address.isEmpty {
                        Text(address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if isSearching && !searchResults.isEmpty {
                    Section(String(localized: "Search Results")) {
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
                
                Section(String(localized: "Detection Radius")) {
                    HStack {
                        Text("\(Int(radius))m")
                        Slider(value: $radius, in: 100...2000, step: 50)
                    }
                    Text(String(localized: "Card will appear when you're within this distance"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Optional: Manual coordinate entry for advanced users
                Section(String(localized: "Coordinates")) {
                    HStack {
                        Text(String(localized: "Latitude"))
                        Spacer()
                        Text(String(format: "%.6f", latitude))
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text(String(localized: "Longitude"))
                        Spacer()
                        Text(String(format: "%.6f", longitude))
                            .foregroundStyle(.secondary)
                    }
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
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty && !address.isEmpty && latitude != 0.0 && longitude != 0.0
    }
    
    private func setupSearchCompleter() {
        searchCompleter.resultTypes = .address
        searchCompleter.delegate = SearchCompleterDelegate(onUpdate: { results in
            searchResults = results
        })
    }
    
    private func selectSearchResult(_ result: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response = response, let mapItem = response.mapItems.first else { return }
            
            name = mapItem.name ?? result.title
            address = "\(result.title), \(result.subtitle)"
            latitude = mapItem.placemark.coordinate.latitude
            longitude = mapItem.placemark.coordinate.longitude
            
            searchText = ""
            isSearching = false
            searchResults = []
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
    
    init(onUpdate: @escaping ([MKLocalSearchCompletion]) -> Void) {
        self.onUpdate = onUpdate
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        onUpdate(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Handle error silently for now
        onUpdate([])
    }
}

#Preview {
    let card = LoyaltyCard(
        name: "Billa Club",
        storeName: "Billa",
        cardNumber: "1234567890123",
        barcodeType: .ean13,
        barcodeData: "1234567890123"
    )
    
    return LocationEditorView(card: card) { location in
        print("Saved location: \(location.name)")
    }
}
