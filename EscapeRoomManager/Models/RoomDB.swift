import Foundation
import Combine

struct RoomInfo: Identifiable, Codable {
    let id = UUID()
    let name: String
    let operatorName: String?
    let city: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case operatorName = "operator"
        case city
        case url
    }
}

final class RoomDB: ObservableObject {
    @Published var rooms: [RoomInfo] = []
    
    // TODO: replace with your actual GitHub raw URL
    private let remoteURLString = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/rooms.json"
    
    init() {
        loadLocal()
        fetchRemote()
    }
    
    /// Load bundled rooms.json (fallback)
    private func loadLocal() {
        guard let url = Bundle.main.url(forResource: "rooms", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            rooms = []
            return
        }
        
        if let decoded = try? JSONDecoder().decode([RoomInfo].self, from: data) {
            rooms = decoded
        } else {
            rooms = []
        }
    }
    
    /// Try to override with latest data from GitHub
    private func fetchRemote() {
        guard let url = URL(string: remoteURLString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil, let data = data else { return }
            guard let decoded = try? JSONDecoder().decode([RoomInfo].self, from: data) else { return }
            
            DispatchQueue.main.async {
                self.rooms = decoded
            }
        }.resume()
    }
    
    func search(_ text: String) -> [RoomInfo] {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }
        
        return rooms.filter {
            $0.name.localizedCaseInsensitiveContains(q) ||
            ($0.city?.localizedCaseInsensitiveContains(q) ?? false)
        }
    }
}
