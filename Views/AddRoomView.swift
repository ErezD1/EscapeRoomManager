import SwiftUI

struct AddRoomView: View {
    @EnvironmentObject var store: EscapeRoomStore
    @EnvironmentObject var roomDB: RoomDB
    @EnvironmentObject var contacts: ContactsManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var date = Date()
    @State private var duration = ""          // optional, string
    @State private var city = ""              // editable city
    
    @State private var friendInput = ""
    @State private var friends: [String] = []
    
    @State private var ratingFun = 0
    @State private var ratingDecor = 0
    @State private var ratingStory = 0
    @State private var ratingTech = 0
    
    @State private var notes = ""
    @State private var showRoomSuggestions = true
    @State private var selectedRoom: RoomInfo?
    @State private var showFriendSuggestions = false
    
    private var roomSuggestions: [RoomInfo] {
        showRoomSuggestions ? Array(roomDB.search(name).prefix(8)) : []
    }
    
    private var friendSuggestions: [String] {
        contacts.search(friendInput)
    }
    
    private var finalRating: Double {
        let values = [ratingFun, ratingDecor, ratingStory, ratingTech].map(Double.init)
        let sum = values.reduce(0, +)
        return sum == 0 ? 0 : sum / Double(values.count)
    }
    
    private var ratingSummaryText: String {
        finalRating == 0 ? "לא דורג עדיין" : String(format: "%.1f", finalRating)
    }
    
    var body: some View {
        Form {
            Section("חדר") {
                VStack(alignment: .leading) {
                    TextField("שם החדר", text: $name)
                        .onChange(of: name) { _ in
                            selectedRoom = nil
                            showRoomSuggestions = true
                        }
                    
                    TextField("עיר", text: $city)
                        .textInputAutocapitalization(.never)
                    
                    if !roomSuggestions.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(roomSuggestions) { room in
                                    Button {
                                        choose(room)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(room.name)
                                            if let c = room.city {
                                                Text(c)
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(maxHeight: 160)
                    }
                }
                
                DatePicker("תאריך", selection: $date, displayedComponents: .date)
                
                TextField("זמן (בדקות — לא חובה)", text: $duration)
                    .keyboardType(.numberPad)
            }
            
            Section("חברים") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("הוסף חבר…", text: $friendInput)
                            .onChange(of: friendInput) { _ in
                                showFriendSuggestions = true
                            }
                        
                        Button {
                            addFriendFromInput()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(friendInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    
                    if showFriendSuggestions && !friendSuggestions.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(friendSuggestions.prefix(6), id: \.self) { name in
                                    Button {
                                        addFriend(name)
                                        friendInput = ""
                                        showFriendSuggestions = false
                                    } label: {
                                        Text(name)
                                            .padding(.vertical, 2)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(maxHeight: 120)
                    }
                    
                    if !friends.isEmpty {
                        TagListView(tags: friends)
                    }
                }
            }
            
            Section("דירוג") {
                RatingSliderView(title: "כיף", value: $ratingFun)
                RatingSliderView(title: "תפאורה", value: $ratingDecor)
                RatingSliderView(title: "סיפור", value: $ratingStory)
                RatingSliderView(title: "עדכניות", value: $ratingTech)
                
                HStack {
                    Text("ציון סופי")
                    Spacer()
                    Text(ratingSummaryText)
                        .foregroundColor(finalRating > 0 ? .blue : .secondary)
                }
            }
            
            Section("הערות") {
                TextField("הערות על החדר…", text: $notes, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
        }
        .navigationTitle("חדר חדש")
        .onAppear {
            contacts.requestAccessIfNeeded()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("ביטול") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("שמירה") { saveRoom() }
                    .disabled(!validForm)
            }
        }
    }
    
    private var validForm: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
        // duration optional
    }
    
    private func choose(_ room: RoomInfo) {
        selectedRoom = room
        name = room.name
        if let c = room.city {
            city = c
        }
        showRoomSuggestions = false
    }
    
    private func addFriendFromInput() {
        let trimmed = friendInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        addFriend(trimmed)
        friendInput = ""
        showFriendSuggestions = false
    }
    
    private func addFriend(_ name: String) {
        if !friends.contains(name) {
            friends.append(name)
        }
    }
    
    private func saveRoom() {
        let minutes = Int(duration) ?? 0
        
        let room = EscapeRoom(
            name: name,
            date: date,
            durationMinutes: minutes,
            friends: friends,
            ratingFun: ratingFun,
            ratingDecor: ratingDecor,
            ratingStory: ratingStory,
            ratingTech: ratingTech,
            location: city.isEmpty ? selectedRoom?.city : city,
            provider: selectedRoom?.operatorName,
            notes: notes
        )
        
        store.add(room)
        dismiss()
    }
}
