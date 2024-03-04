//
//  PhoneNumberViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 04/03/2024.
//

import SwiftUI
import Firebase

class PhoneNumberAuthViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var showingCountrySelection = false
    @Published var selectedCountry: Country {
        didSet {
            saveSelectedCountry()
        }
    }
    @Published var errorMessage = ""
    
    init() {
        // Load the saved country or default to the first country
        let savedCountryCode = UserDefaults.standard.string(forKey: "SelectedCountryCode")
        print("DEBUG: Loaded country code from UserDefaults: \(savedCountryCode ?? "nil")")
        if let code = savedCountryCode,
           let savedCountry = countries.first(where: { $0.regionCode == code }) {
            selectedCountry = savedCountry
        } else {
            selectedCountry = countries.first!  // Default to the first country in your list
        }
    }
    
    
    let indexedCountries = Dictionary(grouping: countries, by: { String($0.name.prefix(1)) })
    let suggestedCountries: [Country] = [
        Country(name: "United States", flag: "🇺🇸", regionCode: "US", dialCode: "+1"),
        Country(name: "China", flag: "🇨🇳", regionCode: "CN", dialCode: "+86"),
        Country(name: "Japan", flag: "🇯🇵", regionCode: "JP", dialCode: "+81"),
        Country(name: "Germany", flag: "🇩🇪", regionCode: "DE", dialCode: "+49"),
        Country(name: "United Kingdom", flag: "🇬🇧", regionCode: "GB", dialCode: "+44")
    ]
    
    var fullPhoneNumber: String {
            let cleanPhoneNumber = phoneNumber.filter("0123456789".contains)
            return selectedCountry.dialCode + cleanPhoneNumber
        }
    
    func saveSelectedCountry() {
        UserDefaults.standard.set(selectedCountry.regionCode, forKey: "SelectedCountryCode")
        print("DEBUG: Saved country: \(selectedCountry.regionCode)")
    }
    
    func changeSelectedCountry(to newCountry: Country) {
        selectedCountry = newCountry
        saveSelectedCountry()
    }

}
