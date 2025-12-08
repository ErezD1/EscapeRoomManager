import SwiftUI

struct EditRoomView: View {
    @Binding var room: EscapeRoom
    @EnvironmentObject var roomDB: RoomDB
    @EnvironmentObject var contacts: ContactsManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var date: Date
    @State private var duration: String
    @State private var city: String
    @State private var friends: [String]
    
    @State private var friendInput = ""
    @State private var ratingFun: Int
    @State private var ratingDecor: Int
    @State private var ratingStory: Int
    @State private var ratingTech: Int
    @State private var notes: String
    
    @State private var showRoomSuggestions = false
    @State private var selectedRoom: RoomInfo?
    @State private var showFriendSuggestions = false
    
    init(room: Binding<EscapeRoom>) {
        _room = room
        let value = room.wrappedValue
        
        _name = State(initialValue: value.name)
        _date = State(initialValue: value.date)
        _duration = State(initialValue: value.durationMinutes == 0 ? "" : String(value.durationMinutes))
        _city = State(initialValue: value.location ?? "")
        _friends = State(initialValue: value.friends)
        
        _ratingFun = State(initialValue: value.ratingFun)
        _ratingDecor = State(initialValue: value.ratingDecor)
        _ratingStory = State(initialValue: value.ratingStory)
        _ratingTech = State(initialValue: value.ratingTech)
        _notes = State(initialValue: value.notes)
    }
    
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
        .navigationTitle("עריכת חדר")
        .onAppear {
            contacts.requestAccessIfNeeded()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("ביטול") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("שמירה") { saveChanges() }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
    
    private func choose(_ roomInfo: RoomInfo) {
        selectedRoom = roomInfo
        name = roomInfo.name
        if let c = roomInfo.city {
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
    
    private func saveChanges() {
        room.name = name
        room.date = date
        room.durationMinutes = Int(duration) ?? 0
        room.location = city.isEmpty ? nil : city
        room.friends = friends
        room.ratingFun = ratingFun
        room.ratingDecor = ratingDecor
        room.ratingStory = ratingStory
        room.ratingTech = ratingTech
        room.notes = notes
        
        dismiss()
    }
}
