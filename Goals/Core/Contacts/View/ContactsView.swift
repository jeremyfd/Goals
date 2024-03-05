//
//  ContactsView.swift
//  Goals
//
//  Created by Jeremy Daines on 05/03/2024.
//

//import SwiftUI
//
//struct ContactsView: View {
//    @StateObject var viewModel = ContactsViewModel()
//    
//    var body: some View {
//        List(viewModel.contacts) { contact in
//            VStack(alignment: .leading) {
//                Text(contact.name)
//                // Display the normalized phone number if available
//                if let normalizedNumber = contact.normalizedPhoneNumber {
//                    Text(normalizedNumber)
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                } else {
//                    Text("Invalid number")
//                        .font(.subheadline)
//                        .foregroundColor(.red)
//                }
//                Spacer()
//                if contact.isOnApp {
//                    Text("On App").foregroundColor(.green)
//                } else {
//                    Text("Not on App").foregroundColor(.red)
//                }
//            }
//        }
//        .onAppear {
//            print("DEBUG: ContactsView appeared")
//            print("DEBUG: Contacts in view: \(viewModel.contacts.count)")
//        }
//        .onChange(of: viewModel.contacts) { newContacts in
//            print("DEBUG: Contacts changed in view")
//            print("DEBUG: Updated contacts in view: \(newContacts.count)")
//        }
//        .navigationBarTitle("Contacts", displayMode: .inline)
//    }
//}
