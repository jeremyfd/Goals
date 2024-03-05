//
//  ContactsViewModel.swift
//  Goals
//
//  Created by Jeremy Daines on 05/03/2024.
//

//import Foundation
//import Contacts
//import SwiftUI
//import PhoneNumberKit
//
//actor ResultsActor {
//    var results: [(UUID, Bool)] = []
//    
//    func append(_ result: (UUID, Bool)) {
//        results.append(result)
//        print("DEBUG: Appended result to ResultsActor: \(result)")
//    }
//    
//    func getResults() -> [(UUID, Bool)] {
//        print("DEBUG: Retrieving results from ResultsActor")
//        return results
//    }
//}
//
//class ContactsViewModel: ObservableObject {
//    @Published var contacts = [Contact]()
//    
//    @MainActor
//    func getContacts() {
//        Task {
//            do {
//                let fetchedContacts = try await fetchContacts()
//                print("DEBUG: Fetched \(fetchedContacts.count) contacts")
//                
//                let sortedContacts = fetchedContacts.sorted(by: { $0.name < $1.name })
//                print("DEBUG: Sorted contacts")
//                
//                let resultsActor = ResultsActor()
//                print("DEBUG: Created ResultsActor")
//                
//                try await withThrowingTaskGroup(of: Void.self, body: { group in
//                    for contact in sortedContacts {
//                        guard let normalizedNumber = self.normalizePhoneNumber(contact.phoneNumber) else {
//                            print("DEBUG: Skipping contact with invalid phone number: \(contact.name)")
//                            continue
//                        }
//                        
//                        group.addTask {
//                            print("DEBUG: Checking if contact is on app: \(contact.name)")
//                            let isOnApp = try await UserService.phoneNumberExists(normalizedNumber)
//                            await resultsActor.append((contact.id, isOnApp))
//                        }
//                    }
//                    
//                    for try await _ in group {
//                        // No need to do anything here
//                    }
//                })
//                
//                await MainActor.run {
//                    Task {
//                        let results = await resultsActor.getResults()
//                        print("DEBUG: Received results from ResultsActor: \(results)")
//                        
//                        for (id, isOnApp) in results {
//                            if let index = self.contacts.firstIndex(where: { $0.id == id }) {
//                                self.contacts[index].isOnApp = isOnApp
//                                print("DEBUG: Updated contact: \(self.contacts[index].name), isOnApp: \(isOnApp)")
//                            }
//                        }
//                    }
//                }
//            } catch {
//                print("Failed to fetch contacts: \(error)")
//            }
//        }
//    }
//    
//    private func fetchContacts() async throws -> [Contact] {
//        let store = CNContactStore()
//        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
//        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
//        var contacts = [Contact]()
//        
//        try await withCheckedThrowingContinuation { continuation in
//            do {
//                try store.enumerateContacts(with: request) { (contact, stop) in
//                    contact.phoneNumbers.forEach { phoneNumber in
//                        let number = phoneNumber.value.stringValue
//                        let name = "\(contact.givenName) \(contact.familyName)"
//                        let normalizedNumber = normalizePhoneNumber(number)
//                        contacts.append(Contact(name: name, phoneNumber: number, normalizedPhoneNumber: normalizedNumber, isOnApp: false))
//                        print("DEBUG: Fetched contact: \(name)")
//                    }
//                }
//                continuation.resume(returning: contacts)
//            } catch {
//                continuation.resume(throwing: error)
//            }
//        }
//        
//        return contacts
//    }
//    
//    private func normalizePhoneNumber(_ number: String) -> String? {
//        let phoneNumberKit = PhoneNumberKit()
//        
//        do {
//            let phoneNumber = try phoneNumberKit.parse(number)
//            let formattedNumber = phoneNumberKit.format(phoneNumber, toType: .e164)
//            print("DEBUG: Normalized phone number: \(formattedNumber)")
//            return formattedNumber
//        } catch {
//            print("Error normalizing phone number: \(error)")
//            return nil
//        }
//    }
//    
//    init() {
//        Task {
//            await getContacts()
//        }
//    }
//
//}
//
//struct Contact: Identifiable, Equatable {
//    let id = UUID()
//    var name: String
//    var phoneNumber: String // Original phone number
//    var normalizedPhoneNumber: String? // Normalized phone number
//    var isOnApp: Bool
//}
