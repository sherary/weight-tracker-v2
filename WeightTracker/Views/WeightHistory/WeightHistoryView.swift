import SwiftUI
import SwiftData

struct WeightHistoryView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var errorMessage: String?
    @State private var destinations: HistoryDestination? = nil
    @Query(sort: \Weight.date, order: .reverse) private var weights: [Weight]
    
    fileprivate typealias Symbol = (name: String, color: Color)
    fileprivate struct WeightRow: Identifiable {
        let weight: Weight
        let delta: Double?
        var id: Weight.ID { weight.id }
    }

    fileprivate var rows: [WeightRow] {
        weights.enumerated().map { index, weight in
            let prevIndex = index + 1
            let delta = prevIndex < weights.count
                ? weight.value - weights[prevIndex].value
                : 0
            
            return WeightRow(weight: weight, delta: delta)
        }
    }
    
    fileprivate func indicator(for delta: Double) -> Symbol {
        var symbol = Symbol(name: "square.fill", color: .secondary)
        
        if delta > 0 {
            symbol.name = "arrowtriangle.up.fill"
            symbol.color = .red
        }
        
        if delta < 0 {
            symbol.name = "arrowtriangle.down.fill"
            symbol.color = .green
        }
        
        return symbol
    }
    
    var body: some View {
        Group {
            if let message = errorMessage, !message.isEmpty {
                ErrorView(text: message) {
                    errorMessage = nil
                }
            } else {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Text("Weight Histories")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Button {
                            destinations = .add
                        } label: {
                            Label("Add", systemImage: "plus")
                                .labelStyle(.iconOnly)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding(.vertical, 16)
                    
                    List {
                        ForEach(rows) { row in
                            let style = indicator(for: row.delta ?? 0)
                            
                            HistoryTableCell(
                                data: row.weight,
                                symbol: style.name,
                                color: style.color,
                                delta: row.delta ?? 0
                            )
                        }
                    }
                    .listStyle(.plain)
                }
                .padding(.horizontal, 16)
                .sheet(item: $destinations) { destination in
                    Group {
                        switch destination {
                        case .add:
                            WeightSheet { weight in
                                save(data: weight)
                                commit()
                            }
                        case .edit(let data):
                            WeightSheet(id: data.id) { weight in
                                if let index = weights.firstIndex(where: { $0.id == weight.id }) {
                                    delete(offsets: IndexSet(integer: index))
                                    save(data: weight)
                                    commit()
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

extension WeightHistoryView {
    fileprivate func save(data: Weight) {
        withAnimation {
            modelContext.insert(data)
        }
    }

    fileprivate func delete(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(weights[index])
            }
        }
    }
    
    fileprivate func commit() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
            
            return
        }
    }
}

#Preview {
    WeightHistoryView()
        .modelContainer(for: Weight.self, inMemory: false)
}
