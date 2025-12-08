import Foundation
import Combine
import SwiftUICore

final class EscapeRoomStore: ObservableObject {
    @Published var rooms: [EscapeRoom] = [] {
        didSet { save() }
    }
    
    private let storageKey = "escapeRooms"

    init() {
        load()
    }
    
    private func load() {
        let iCloudStore = NSUbiquitousKeyValueStore.default
        
        // 1. Try iCloud data first
        if let data = iCloudStore.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([EscapeRoom].self, from: data) {
            rooms = decoded
            return
        }
        
        // 2. Fallback: local UserDefaults
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([EscapeRoom].self, from: data) {
            rooms = decoded
        }
    }
    
    private func save() {
        guard let encoded = try? JSONEncoder().encode(rooms) else { return }
        
        // local
        UserDefaults.standard.set(encoded, forKey: storageKey)
        
        // iCloud key-value
        let iCloudStore = NSUbiquitousKeyValueStore.default
        iCloudStore.set(encoded, forKey: storageKey)
        iCloudStore.synchronize()
    }
    
    func add(_ room: EscapeRoom) {
        rooms.insert(room, at: 0)
    }
    
    func addBulk(_ newRooms: [EscapeRoom]) {
        rooms.insert(contentsOf: newRooms.reversed(), at: 0)
    }
    
    func delete(at offsets: IndexSet) {
        rooms.remove(atOffsets: offsets)
    }
}
