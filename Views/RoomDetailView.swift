import SwiftUI

private let detailDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    return df
}()

struct RoomDetailView: View {
    @Binding var room: EscapeRoom
    @State private var showingEdit = false
    
    var body: some View {
        Form {
            Section("פרטי חדר") {
                VStack(alignment: .leading, spacing: 4) {
                    Text(room.name)
                        .font(.headline)
                    
                    if let city = room.location, !city.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.and.ellipse")
                            Text(city)
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Image(systemName: "calendar")
                    Text(detailDateFormatter.string(from: room.date))
                }
                .foregroundColor(.secondary)
                
                if room.durationMinutes > 0 {
                    HStack {
                        Image(systemName: "clock")
                        Text("משך: \(room.durationMinutes) דקות")
                    }
                    .foregroundColor(.secondary)
                }
                
                if let provider = room.provider, !provider.isEmpty {
                    HStack {
                        Image(systemName: "building.2")
                        Text(provider)
                    }
                }
            }
            
            Section("דירוגים") {
                ratingRow("כיף כללי", room.ratingFun)
                ratingRow("תפאורה", room.ratingDecor)
                ratingRow("סיפור", room.ratingStory)
                ratingRow("עדכניות", room.ratingTech)
                
                HStack {
                    Text("ציון סופי")
                    Spacer()
                    Text(room.finalRatingText)
                        .font(.headline)
                        .foregroundColor(room.hasRating ? .blue : .secondary)
                }
            }
            
            if !room.friends.isEmpty {
                Section("שחקנים") {
                    TagListView(tags: room.friends)
                }
            }
            
            Section("הערות") {
                if room.notes.isEmpty {
                    Text("אין הערות")
                        .foregroundColor(.secondary)
                } else {
                    Text(room.notes)
                }
            }
        }
        .navigationTitle(room.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("עריכה") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            NavigationStack {
                EditRoomView(room: $room)
            }
        }
    }
    
    func ratingRow(_ title: String, _ value: Int) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value == 0 ? "לא דורג" : "\(value)/10")
                .foregroundColor(.secondary)
        }
    }
}
