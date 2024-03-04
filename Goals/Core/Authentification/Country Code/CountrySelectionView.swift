//
//  CountrySelectionView.swift
//  Goals
//
//  Created by Jeremy Daines on 04/03/2024.
//

import SwiftUI

struct CountrySelectionView: View {
    @Binding var selectedCountry: Country
    @Binding var isPresented: Bool
    @State private var searchText = ""
    
    let suggestedCountries: [Country] // Populate this with your suggested countries
    let indexedCountries: [String: [Country]] // Your countries sorted into a dictionary by their first letter
    
    var filteredIndexedCountries: [String: [Country]] {
        indexedCountries.compactMapValues { countries in
            let filteredCountries = countries.filter(shouldShowCountry)
            return filteredCountries.isEmpty ? nil : filteredCountries
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                List {
                    if searchText.isEmpty {
                        Section(header: Text("SUGGESTED")) {
                            ForEach(suggestedCountries, id: \.id) { country in
                                CountryRow(country: country, selectedCountry: $selectedCountry, isPresented: $isPresented)
                            }
                        }
                    }
                    
                    ForEach(filteredIndexedCountries.keys.sorted(), id: \.self) { key in
                        Section(header: Text(key)) {
                            ForEach(filteredIndexedCountries[key] ?? [], id: \.id) { country in
                                CountryRow(country: country, selectedCountry: $selectedCountry, isPresented: $isPresented)
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .navigationBarTitle("Select Country", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                self.isPresented = false
            })
        }
    }
    
    private func shouldShowCountry(country: Country) -> Bool {
        searchText.isEmpty || country.name.localizedCaseInsensitiveContains(searchText)
    }
}

// A view representing a single country row
struct CountryRow: View {
    var country: Country
    @Binding var selectedCountry: Country
    @Binding var isPresented: Bool
    
    var body: some View {
        Button(action: {
            self.selectedCountry = country
            self.isPresented = false
        }) {
            HStack {
                Text(country.flag)
                Text(country.name)
                    .foregroundColor(.black)
                Text(country.dialCode)
                    .foregroundColor(.black)
            }
        }
//        .buttonStyle(PlainButtonStyle()) // To avoid list row highlighting
    }
}

// A custom search bar component
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
        }
    }
}
