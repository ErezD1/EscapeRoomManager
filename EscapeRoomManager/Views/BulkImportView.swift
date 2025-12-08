import SwiftUI

struct BulkImportView: View {
    @EnvironmentObject var store: EscapeRoomStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var rawText: String = ""
    @State private var preview: [EscapeRoom] = []
    
    var body: some View {
        VStack {
            Form {
                Section("הדבק כאן את הרשימה") {
                    TextEditor(text: $rawText)
                        .frame(minHeight: 200)
                        .font(.system(.body, design: .rounded))
                        .textInputAutocapitalization(.never)
                }
                
                if !preview.isEmpty {
                    Section("תצוגה מקדימה (\(preview.count) חדרים)") {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(preview.prefix(15)) { room in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(room.name)
                                                .font(.subheadline)
                                            if let city = room.location {
                                                Text(city)
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 2)
                                }
                                if preview.count > 15 {
                                    Text("ועוד \(preview.count - 15) חדרים…")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .frame(minHeight: 120, maxHeight: 220)
                    }
                }
            }
            
            HStack {
                Button("סגור") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("תצוגה מקדימה") {
                    preview = BulkImportParser.parse(text: rawText)
                }
                .buttonStyle(.bordered)
                
                Button("ייבוא") {
                    let parsed = BulkImportParser.parse(text: rawText)
                    guard !parsed.isEmpty else { return }
                    store.addBulk(parsed)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(BulkImportParser.parse(text: rawText).isEmpty)
            }
            .padding()
        }
        .navigationTitle("ייבוא מרשימה")
    }
}
