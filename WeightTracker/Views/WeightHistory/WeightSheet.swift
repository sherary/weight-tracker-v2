import SwiftUI
import SwiftData

struct WeightSheet: View {
    var id: UUID?
    let onSave: ((Weight) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var data: Weight = Weight()
    @State private var errorMessage: String?
    
    private var dateRange: ClosedRange<Date> {
        let now = Date.now
        var fiscalYear = DateComponents()
        fiscalYear.year = Calendar.current.component(.year, from: now)
        fiscalYear.month = 1
        fiscalYear.day = 1
        
        guard let startingDate = Calendar.current.date(from: fiscalYear) else {
            return now...Date.now
        }
        
        return startingDate...now
    }
    
    private func form(for data: Weight) -> some View {
        return VStack(alignment: .leading) {
            Text("Weight Form")
                .font(.system(size: 24, weight: .bold))
                .padding(.bottom, 16)
            
            VStack(alignment: .leading) {
                Text("Weight")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(.primary.opacity(0.8))
                
                TextField("55,5", value: $data.value, format: .number.precision(.fractionLength(2)))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.blue, lineWidth: 0.8)
                    )
            }
            .padding(.bottom, 24)
            
            ZStack {
                VStack(alignment: .leading) {
                    Text("Date")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(.primary.opacity(0.8))
                    
                    Text(data.date, format: .dateTime)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.blue, lineWidth: 0.8)
                        )
                }
                .zIndex(0)
                
                GeometryReader { proxy in
                    DatePicker(
                        "Date",
                        selection: $data.date,
                        in: dateRange,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .fixedSize()
                    .scaleEffect(x: proxy.size.width, y: proxy.size.height / 34, anchor: .center)
                    .opacity(0.011)
                }
                .frame(height: 48)
                .contentShape(Rectangle())
                .zIndex(1)
                .offset(y: 20)
            }
            .padding(.bottom, 24)
            
            Button {
                if let onSave = onSave {
                    onSave(data)
                }
                
                dismiss()
            } label: {
                Label("Save", systemImage: "folder")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.blue)
                    )
            }
            .disabled(data.value.isNaN)
            .padding(.vertical, 16)
        }
        .presentationDetents([.fraction(0.7)])
        .presentationBackground(Color(.systemBackground)) 
    }
    
    var body: some View {
        Group {
            if id != nil,
               let errorMessage = errorMessage {
                ErrorView(
                    text: errorMessage,
                    onButtonTap: {
                        self.errorMessage = nil
                    }
                )
            } else if errorMessage == nil {
                form(for: data)
            } else {
                ProgressView()
            }
        }
        .task {
            guard let id else {
                data = Weight(id: UUID())
                
                return
            }
            
            let queryResponse = findItem(with: id)
            switch queryResponse {
            case .success(let responseData):
                if let weight = responseData {
                    data = weight
                }
            case .failure(let err):
                errorMessage = err.localizedDescription
            }
        }
    }
}

extension WeightSheet {
    private func findItem(with id: UUID) -> Result<Weight?, Error> {
        var descriptor = FetchDescriptor<Weight>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        
        do {
            let item = try modelContext.fetch(descriptor)
            
            return .success(item.first)
        } catch {
            return .failure(error)
        }
    }
}

#Preview {
    WeightSheet { item in
        
    }
}
