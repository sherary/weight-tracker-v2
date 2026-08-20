import SwiftUI

struct SwipableIcon: View {
    let symbol: String
    let tint: Color
    let onSave: (() -> Void)?
    
    var body: some View {
        Button {
            if let onSave = onSave {
                onSave()
            }
        } label: {
            Image(systemName: symbol)
        }
        .tint(tint)
    }
}

#Preview {
    SwipableIcon(
        symbol: "square.and.pencil",
        tint: .blue,
        onSave: nil
    )
}
