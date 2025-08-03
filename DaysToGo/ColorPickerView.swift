import SwiftUI
import DaysToGoKit

struct ColorPickerView: View {
    @Binding var selectedColor: PastelColor

    let colors = PastelColor.allCases

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
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
}
