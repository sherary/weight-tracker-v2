import SwiftUI

struct ErrorView: View {
    let text: String
    let onButtonTap: (() -> Void)?
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.yellow)
                    .font(.system(size: 64))
                
                Text(text)
                    .lineLimit(8)
                    .foregroundStyle(.primary)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .truncationMode(.tail)
                    .padding(.bottom, 32)
                
                Button {
                    if let onButtonTap = onButtonTap {
                        onButtonTap()
                    }
                } label: {
                    Label("Clear", systemImage: "clear.fill")
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.orange.opacity(0.8))
                        )
                        .font(.system(size: 24))
                }
            }
        }
    }
}
