import SwiftUI

struct WeightHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    @AppStorage("useMetricUnits") private var useMetric: Bool = true

    private var sortedEntries: [WeightEntry] {
        appVM.weightHistory.sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar(title: Lang.s("weight_history_title"), onBack: { dismiss() })

            if sortedEntries.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "scalemass")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text(Lang.s("no_records"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(sortedEntries.enumerated()), id: \.element.id) { index, entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                    if index < sortedEntries.count - 1 {
                                        let diffKg = entry.weightKg - sortedEntries[index + 1].weightKg
                                        let diff = useMetric ? diffKg : diffKg * 2.20462
                                        let unit = useMetric ? "kg" : "lbs"
                                        Text(diff >= 0 ? "+\(String(format: "%.1f", diff)) \(unit)" : "\(String(format: "%.1f", diff)) \(unit)")
                                            .font(.caption)
                                            .foregroundStyle(diff <= 0 ? Color.wellnessTeal : .orange)
                                    }
                                }
                                Spacer()
                                Text(WeightFormatter.formatWithUnit(entry.weightKg, metric: useMetric))
                                    .font(.subheadline.weight(.semibold))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                            if index < sortedEntries.count - 1 {
                                Divider().padding(.leading, 16)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .clipShape(.rect(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}
