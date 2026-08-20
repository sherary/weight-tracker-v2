import SwiftUI

struct InlineTitle<Content: View>: View {
    let content: Content
    let text: String
    
    init(text: String, @ViewBuilder content: () -> Content) {
        self.text = text
        self.content = content()
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Text(text)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.primary)
            
            Spacer()
            
            content
        }
    }
}
