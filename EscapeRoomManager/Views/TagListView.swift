import SwiftUI

struct TagListView: View {
    let tags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Capsule().fill(Color.blue.opacity(0.12)))
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
