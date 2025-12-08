import SwiftUI

private let listDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    return df
}()

struct RoomListView: View {
    @EnvironmentObject var store: EscapeRoomStore
    @State private var showingAdd = false
    @State private var showingBulkImport = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemBackground), Color.blue.opacity(0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                Group {
                    if store.rooms.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "lock.open.trianglebadge.exclamationmark")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("עוד לא הוספת חדרי בריחה")
                                .font(.headline)
                            
                            Text("הוסף חדר חדש או יבוא רשימה קיימת בלחיצה על ⋯")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else {
                        List {
                            ForEach($store.rooms) { $room in
                                NavigationLink {
                                    RoomDetailView(room: $room)
                                } label: {
                                    RoomRowView(room: room)
                                }
                            }
                            .onDelete(perform: store.delete)
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("החדרים שלי")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingBulkImport = true
                    } label: {
                        Image(systemName: "text.badge.plus")
                    }
                    .help("Bulk import מרשימה")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                NavigationStack {
                    AddRoomView()
                }
            }
            .sheet(isPresented: $showingBulkImport) {
                NavigationStack {
                    BulkImportView()
                }
            }
        }
    }
}

struct RoomRowView: View {
    let room: EscapeRoom
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 52, height: 52)
                Text(room.finalRatingText)
                    .font(.headline)
                    .foregroundColor(room.hasRating ? .blue : .secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(room.name)
                    .font(.headline)
                
                HStack(spacing: 6) {
                    if let city = room.location, !city.isEmpty {
                        Image(systemName: "mappin.and.ellipse")
                        Text(city)
                    }
                    
                    Image(systemName: "calendar")
                    Text(listDateFormatter.string(from: room.date))
                    
                    if room.durationMinutes > 0 {
                        Text("•")
                        Image(systemName: "clock")
                        Text("\(room.durationMinutes) דק'")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
