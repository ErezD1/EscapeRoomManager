import Foundation
import Contacts
import Combine

final class ContactsManager: ObservableObject {
    @Published var contactNames: [String] = []
    
    private let store = CNContactStore()
    private var didRequest = false
    
    func requestAccessIfNeeded() {
        guard !didRequest else { return }
        didRequest = true
        
        store.requestAccess(for: .contacts) { granted, error in
            guard granted, error == nil else {
                return
            }
            // run heavy work off the main thread
            DispatchQueue.global(qos: .userInitiated).async {
                self.loadContacts()
            }
        }
    }
    
    private func loadContacts() {
        let keys: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor
        ]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        var names: [String] = []
        
        do {
            try store.enumerateContacts(with: request) { contact, _ in
                let full = [contact.givenName, contact.familyName]
                    .joined(separator: " ")
                    .trimmingCharacters(in: .whitespaces)
                if !full.isEmpty {
                    names.append(full)
                }
            }
        } catch {
            return
        }
        
        // publish to UI on main thread
        DispatchQueue.main.async {
            self.contactNames = Array(Set(names)).sorted()
        }
    }
    
    func search(_ text: String) -> [String] {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }
        return contactNames.filter { $0.localizedCaseInsensitiveContains(q) }
    }
}
