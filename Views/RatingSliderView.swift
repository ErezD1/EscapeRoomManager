import SwiftUI

struct RatingSliderView: View {
    let title: String
    @Binding var value: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text("\(value)/10")
                    .foregroundColor(.secondary)
            }
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0.rounded()) }
                ),
                in: 1...10,
                step: 1
            )
        }
        .padding(.vertical, 4)
    }
}
