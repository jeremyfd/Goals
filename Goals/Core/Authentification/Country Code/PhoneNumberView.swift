//
//  PhoneNumberView.swift
//  Goals
//
//  Created by Jeremy Daines on 04/03/2024.
//

import SwiftUI

struct PhoneNumberView: View {
    @ObservedObject var viewModel: PhoneNumberAuthViewModel
    
    var body: some View {
        VStack {
            HStack {
                CountryPickerButton(viewModel: viewModel)
                PhoneNumberTextField(viewModel: viewModel)
            }
        }
    }
}


struct CountryPickerButton: View {
    @ObservedObject var viewModel: PhoneNumberAuthViewModel
    
    var body: some View {
        Button(action: {
            viewModel.showingCountrySelection = true
        }) {
            HStack {
                Text(viewModel.selectedCountry.flag)
                    .font(.system(size: 24))
                    .foregroundColor(.black)
                Text(viewModel.selectedCountry.dialCode)
                    .font(.system(size: 18))
                    .foregroundColor(Color.theme.primaryText)
                Image(systemName: "chevron.down")
                .foregroundColor(Color.theme.primaryText)
            }
            .padding(.horizontal, 5)
            .frame(height: 44)
            .cornerRadius(10)
        }
        .padding(.leading)
        .sheet(isPresented: $viewModel.showingCountrySelection) {
            CountrySelectionView(
                selectedCountry: $viewModel.selectedCountry,
                isPresented: $viewModel.showingCountrySelection,
                suggestedCountries: viewModel.suggestedCountries,
                indexedCountries: viewModel.indexedCountries
            )
        }
    }
}

struct PhoneNumberTextField: View {
    @ObservedObject var viewModel: PhoneNumberAuthViewModel
    
    var body: some View {
        TextField("Phone Number", text: $viewModel.phoneNumber)
            .padding(.trailing)
            .keyboardType(.phonePad)
            .foregroundColor(Color.theme.primaryText)
    }
}
