import SwiftUI

struct MultipleChoiceAlert<Data, M: View>: ViewModifier {
    let title: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    let type: AlertType
    
    @Binding var data: Data?
    @ViewBuilder let message: (Data) -> M
    
    func body(content: Content) -> some View {
        content.alert(
            title,
            isPresented: $data.isPresent(),
            presenting: data,
            actions: { _ in
                HStack(alignment: .center) {
                    Button(type.confirmButtonText, role: .destructive) {
                        onConfirm()
                    }
                    
                    Button(type.cancelButtonText, role: .cancel) {
                        onCancel()
                    }
                }
            },
            message: message
        )
    }
}

extension View {
    func multipleChoiceAlert<Data, M: View>(
        title: String,
        data: Binding<Data?>,
        type: AlertType,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        message: @escaping (Data) -> M
    ) -> some View {
        modifier(
            MultipleChoiceAlert(
                title: title,
                onConfirm: onConfirm,
                onCancel: onCancel,
                type: type,
                data: data,
                message: message
            )
        )
    }
}
