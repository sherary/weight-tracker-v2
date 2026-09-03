import SwiftUI

struct EmptyAnalyticsView: View {
    let onButtonTap: (() -> Void)?
    
    var body: some View {
        VStack {
            StandardEmptyView(onButtonTap: onButtonTap)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyAnalyticsView {
        print("test")
    }
}
