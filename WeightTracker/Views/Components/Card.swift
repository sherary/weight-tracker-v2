import SwiftUI

struct Card<Content: View>: View {
    var spacing: CGFloat = 0
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.quinary.opacity(0.6))
        )
    }
}
