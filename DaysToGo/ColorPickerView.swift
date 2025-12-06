import SwiftUI
import DaysToGoKit

struct ColorPickerView: View {
    @Binding var selectedColor: PastelColor

    let colors = PastelColor.allCases

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(colors, id: \.self) { color in
                Circle()
                    .fill(color.color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 2)
                    )
                    .onTapGesture {
                        selectedColor = color
                    }
                    .accessibilityLabel(color.rawValue)
                    .accessibility(addTraits: selectedColor == color ? .isSelected : .isButton)
            }
        }
        .padding()
    }
}
