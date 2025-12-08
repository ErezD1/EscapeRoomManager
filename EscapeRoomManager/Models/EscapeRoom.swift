import Foundation

struct EscapeRoom: Identifiable, Codable {
    let id: UUID
    var name: String
    var date: Date
    var durationMinutes: Int
    
    /// multiple friends as tags
    var friends: [String]
    
    /// 0 = not rated yet
    var ratingFun: Int
    var ratingDecor: Int
    var ratingStory: Int
    var ratingTech: Int
    
    /// city / location (e.g. "חיפה")
    var location: String?
    /// room operator / company
    var provider: String?
    
    var notes: String
    
    init(
        id: UUID = UUID(),
        name: String,
        date: Date = Date(),
        durationMinutes: Int = 0,
        friends: [String] = [],
        ratingFun: Int = 0,
        ratingDecor: Int = 0,
        ratingStory: Int = 0,
        ratingTech: Int = 0,
        location: String? = nil,
        provider: String? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.durationMinutes = durationMinutes
        self.friends = friends
        self.ratingFun = ratingFun
        self.ratingDecor = ratingDecor
        self.ratingStory = ratingStory
        self.ratingTech = ratingTech
        self.location = location
        self.provider = provider
        self.notes = notes
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, date, durationMinutes, friends
        case ratingFun, ratingDecor, ratingStory, ratingTech
        case location, provider, notes
    }
    
    // custom decode so old data with String friends won't break
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try c.decode(String.self, forKey: .name)
        date = try c.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        durationMinutes = try c.decodeIfPresent(Int.self, forKey: .durationMinutes) ?? 0
        
        if let arr = try? c.decode([String].self, forKey: .friends) {
            friends = arr
        } else if let single = try? c.decode(String.self, forKey: .friends) {
            let parts = single
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            friends = parts
        } else {
            friends = []
        }
        
        ratingFun   = try c.decodeIfPresent(Int.self, forKey: .ratingFun)   ?? 0
        ratingDecor = try c.decodeIfPresent(Int.self, forKey: .ratingDecor) ?? 0
        ratingStory = try c.decodeIfPresent(Int.self, forKey: .ratingStory) ?? 0
        ratingTech  = try c.decodeIfPresent(Int.self, forKey: .ratingTech)  ?? 0
        
        location = try c.decodeIfPresent(String.self, forKey: .location)
        provider = try c.decodeIfPresent(String.self, forKey: .provider)
        notes    = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(date, forKey: .date)
        try c.encode(durationMinutes, forKey: .durationMinutes)
        try c.encode(friends, forKey: .friends)
        try c.encode(ratingFun, forKey: .ratingFun)
        try c.encode(ratingDecor, forKey: .ratingDecor)
        try c.encode(ratingStory, forKey: .ratingStory)
        try c.encode(ratingTech, forKey: .ratingTech)
        try c.encode(location, forKey: .location)
        try c.encode(provider, forKey: .provider)
        try c.encode(notes, forKey: .notes)
    }
    
    // MARK: - Helpers
    
    var hasRating: Bool {
        [ratingFun, ratingDecor, ratingStory, ratingTech].contains(where: { $0 > 0 })
    }
    
    var finalRating: Double {
        let values = [ratingFun, ratingDecor, ratingStory, ratingTech].map(Double.init)
        let sum = values.reduce(0, +)
        return sum == 0 ? 0 : sum / Double(values.count)
    }
    
    var finalRatingText: String {
        guard hasRating else { return "—" }
        return String(format: "%.1f", finalRating)
    }
    
    var friendsDisplay: String {
        friends.joined(separator: ", ")
    }
}
