import Foundation

struct BulkImportParser {
    static func parse(text: String) -> [EscapeRoom] {
        let lines = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        var results: [EscapeRoom] = []
        
        for line in lines {
            // remove numbering like "1. "
            let noNumber = line.replacingOccurrences(
                of: #"^\s*\d+\.\s*"#,
                with: "",
                options: .regularExpression
            )
            
            // find first (…) as city
            guard let openIndex = noNumber.firstIndex(of: "("),
                  let closeIndex = noNumber[openIndex...].firstIndex(of: ")") else {
                // no parentheses → whole line as name
                let name = noNumber.trimmingCharacters(in: .whitespaces)
                if !name.isEmpty {
                    let room = EscapeRoom(
                        name: name,
                        date: Date(),
                        durationMinutes: 0,
                        friends: [],              // ⬅ empty array instead of ""
                        ratingFun: 0,
                        ratingDecor: 0,
                        ratingStory: 0,
                        ratingTech: 0,
                        location: nil,
                        provider: nil,
                        notes: ""
                    )
                    results.append(room)
                }
                continue
            }
            
            let namePart = noNumber[..<openIndex]
            let cityPart = noNumber[noNumber.index(after: openIndex)..<closeIndex]
            
            let rawName = String(namePart).trimmingCharacters(in: .whitespaces)
            var rawCity = String(cityPart).trimmingCharacters(in: .whitespaces)
            
            // clean city: remove leading ? and extra spaces
            rawCity = rawCity.trimmingCharacters(in: CharacterSet(charactersIn: " ?-–—"))
            
            guard !rawName.isEmpty else { continue }
            
            let room = EscapeRoom(
                name: rawName,
                date: Date(),
                durationMinutes: 0,
                friends: [],                  // ⬅ also here
                ratingFun: 0,
                ratingDecor: 0,
                ratingStory: 0,
                ratingTech: 0,
                location: rawCity.isEmpty ? nil : rawCity,
                provider: nil,
                notes: ""
            )
            
            results.append(room)
        }
        
        return results
    }
}
