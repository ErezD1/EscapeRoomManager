import Foundation
import Combine
import SwiftUI

final class EscapeRoomStore: ObservableObject {
    @Published var rooms: [EscapeRoom] = [] {
        didSet { save() }
    }
    
    private let storageKey = "escapeRooms"

    init() {
        load()
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let decoded = try? JSONDecoder().decode([EscapeRoom].self, from: data) {
            rooms = decoded
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(rooms) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
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
