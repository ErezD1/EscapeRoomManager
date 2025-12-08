import SwiftUI

@main
struct EscapeLogApp: App {
    @StateObject private var store = EscapeRoomStore()
    @StateObject private var roomDB = RoomDB()
    @StateObject private var contacts = ContactsManager()

    var body: some Scene {
        WindowGroup {
            RoomListView()
                .environmentObject(store)
                .environmentObject(roomDB)
                .environmentObject(contacts)
        }
    }
}
