import SwiftUI

struct StandardEmptyView: View {
    let onButtonTap: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "folder.fill")
                .foregroundStyle(.yellow)
                .font(.system(size: 64))
            
            Text("Nothing to see here")
                .foregroundStyle(.secondary)
                .font(.subheadline)
                .padding(.bottom, 32)
            
            Button {
                if let onButtonTap = onButtonTap {
                    onButtonTap()
                }
            } label: {
                Label("Add new record", systemImage: "plus")
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.blue.opacity(0.8))
                    )
                    .font(.system(size: 16))
            }
        }
    }
}
