import SwiftUI

struct EmptyListView: View {
    var onButtonTap: (() -> Void)?
    
    var body: some View {
        VStack {
            StandardEmptyView(onButtonTap: onButtonTap)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyListView {
        
    }
}
