import SwiftUI
import Charts

struct FoodProductScanHistoryView: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRecord: FoodProductScanRecord?

    private var sortedRecords: [FoodProductScanRecord] {
        appVM.foodProductScanHistory.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if appVM.foodProductScanHistory.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            qualityTrendChart
                            recordsList
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(Lang.s("food_product_scan_history"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .sheet(item: $selectedRecord) { record in
            FoodProductDetailView(record: record)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text(Lang.s("no_scans_yet"))
                .font(.title3.weight(.semibold))
            Text(Lang.s("scan_product_label"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var qualityTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(Lang.s("quality_trend"), systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)

            let chronological = appVM.foodProductScanHistory.sorted { $0.date < $1.date }

            if chronological.count >= 2 {
                Chart {
                    ForEach(chronological) { record in
                        LineMark(
                            x: .value("Date", record.date),
                            y: .value("Score", record.qualityScore)
                        )
                        .foregroundStyle(Color(red: 0.55, green: 0.22, blue: 0.14))
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Date", record.date),
                            y: .value("Score", record.qualityScore)
                        )
                        .foregroundStyle(qualityPointColor(record.qualityScore))
                        .symbolSize(50)

                        AreaMark(
                            x: .value("Date", record.date),
                            y: .value("Score", record.qualityScore)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [Color(red: 0.55, green: 0.22, blue: 0.14).opacity(0.2), Color(red: 0.55, green: 0.22, blue: 0.14).opacity(0.0)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 160)
                .chartYScale(domain: 0...100)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.month(.abbreviated).day())
                                    .font(.caption2)
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text("\(v)")
                                    .font(.caption2)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    }
                }
            } else {
                HStack(spacing: 16) {
                    summaryPill(label: Lang.s("total_scans"), value: "\(chronological.count)", icon: "doc.text.magnifyingglass", color: Color(red: 0.55, green: 0.22, blue: 0.14))
                    if let last = chronological.last {
                        summaryPill(label: Lang.s("last_quality"), value: "\(last.qualityScore)/100", icon: "star.fill", color: qualityPointColor(last.qualityScore))
                    }
                }
                Text(Lang.s("scan_more_products_trend"))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }

            if !sortedRecords.isEmpty {
                let avgScore = sortedRecords.reduce(0) { $0 + $1.qualityScore } / sortedRecords.count
                HStack(spacing: 8) {
                    Image(systemName: "star.circle.fill")
                        .foregroundStyle(qualityPointColor(avgScore))
                    Text("\(Lang.s("average_quality"))\(avgScore)/100")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(qualityPointColor(avgScore))
                    Spacer()
                    Text(qualityLabelFor(avgScore))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(qualityPointColor(avgScore))
                        .clipShape(.capsule)
                }
                .padding(12)
                .background(qualityPointColor(avgScore).opacity(0.08))
                .clipShape(.rect(cornerRadius: 12))
            }
        }
        .padding(16)
        .background(.white.opacity(0.8))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func summaryPill(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text(value)
                .font(.title3.weight(.bold))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var recordsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(Lang.s("records"), systemImage: "clock.arrow.circlepath")
                .font(.headline)

            ForEach(sortedRecords) { record in
                recordCard(record)
            }
        }
    }

    private func recordCard(_ record: FoodProductScanRecord) -> some View {
        Button {
            selectedRecord = record
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    if let data = record.imageData, let img = UIImage(data: data) {
                        Color(.secondarySystemGroupedBackground)
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(uiImage: img)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .allowsHitTesting(false)
                            }
                            .clipShape(.rect(cornerRadius: 10))
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(red: 0.55, green: 0.22, blue: 0.14).opacity(0.1))
                                .frame(width: 50, height: 50)
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.title3)
                                .foregroundStyle(Color(red: 0.55, green: 0.22, blue: 0.14))
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(record.productName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Text(record.formattedDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        qualityBadge(record.qualityScore, label: record.qualityLabel)
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(record.calories)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.primary)
                            Text("kcal")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                HStack(spacing: 8) {
                    miniMacro(label: "P", value: record.protein, color: Color.wellnessTeal)
                    miniMacro(label: "C", value: record.carbohydrates, color: .orange)
                    miniMacro(label: "F", value: record.totalFat, color: Color(red: 0.72, green: 0.08, blue: 0.08))
                    miniMacro(label: "Sugar", value: record.sugars, color: .purple)
                    miniMacro(label: "Fiber", value: record.fiber, color: .green)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(14)
            .background(.white.opacity(0.8))
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                withAnimation { appVM.deleteFoodProductScanRecord(id: record.id) }
            } label: {
                Label(Lang.s("delete"), systemImage: "trash")
            }
        }
    }

    private func qualityBadge(_ score: Int, label: String) -> some View {
        HStack(spacing: 4) {
            Text("\(score)")
                .font(.caption.weight(.bold))
            Text(label)
                .font(.system(size: 9, weight: .semibold))
        }
        .foregroundStyle(qualityPointColor(score))
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(qualityPointColor(score).opacity(0.12))
        .clipShape(.capsule)
    }

    private func miniMacro(label: String, value: Double, color: Color) -> some View {
        Text(String(format: "%.0f%@", value, label))
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(color)
    }

    private func qualityPointColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .blue
        case 40..<60: return .orange
        default: return .red
        }
    }

    private func qualityLabelFor(_ score: Int) -> String {
        switch score {
        case 80...100: return Lang.s("excellent")
        case 60..<80: return Lang.s("good")
        case 40..<60: return Lang.s("average")
        case 20..<40: return Lang.s("poor")
        default: return Lang.s("very_poor")
        }
    }
}

struct FoodProductDetailView: View {
    let record: FoodProductScanRecord
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    qualityScoreCard
                    caloriesCard
                    macroSection
                    otherNutrientsSection
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .navigationTitle(record.productName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.s("close")) { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        HStack(spacing: 14) {
            if let data = record.imageData, let img = UIImage(data: data) {
                Color(.secondarySystemBackground)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadius: 14))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(record.productName)
                    .font(.title3.weight(.bold))
                Text("\(Lang.s("serving_size")): \(record.servingSize)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(record.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
    }

    private var qualityScoreCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(Lang.s("quality_score"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(record.qualityScore)")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(scoreColor)
                    Text("/ 100")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(scoreColor.opacity(0.6))
                }
                Text(record.qualityLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(scoreColor)
                    .clipShape(.capsule)
            }
            Spacer()
            qualityRing
        }
        .padding(18)
        .background(scoreColor.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var qualityRing: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 10)
                .frame(width: 64, height: 64)
            Circle()
                .trim(from: 0, to: Double(record.qualityScore) / 100.0)
                .stroke(scoreColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 64, height: 64)
                .rotationEffect(.degrees(-90))
            Text("\(record.qualityScore)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(scoreColor)
        }
    }

    private var caloriesCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Lang.s("calories"))
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(record.calories)")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundStyle(Color.wellnessTeal)
                    Text("kcal")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.wellnessTeal)
                }
            }
            Spacer()
        }
        .padding(18)
        .background(Color.wellnessTeal.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var macroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Lang.s("macronutrients"))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            HStack(spacing: 10) {
                macroCard(label: Lang.s("protein"), value: record.protein, unit: "g", color: Color.wellnessTeal)
                macroCard(label: Lang.s("carbs"), value: record.carbohydrates, unit: "g", color: .orange)
                macroCard(label: Lang.s("fat"), value: record.totalFat, unit: "g", color: Color(red: 0.72, green: 0.08, blue: 0.08))
            }
        }
    }

    private func macroCard(label: String, value: Double, unit: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(String(format: "%.1f%@", value, unit))
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.08))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var otherNutrientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Lang.s("other_nutrients"))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                nutrientRow(label: Lang.s("sugars"), value: record.sugars, unit: "g")
                Divider().padding(.horizontal, 16)
                nutrientRow(label: Lang.s("saturated_fat"), value: record.saturatedFat, unit: "g")
                Divider().padding(.horizontal, 16)
                nutrientRow(label: Lang.s("fiber"), value: record.fiber, unit: "g")
                Divider().padding(.horizontal, 16)
                nutrientRow(label: Lang.s("salt"), value: record.salt, unit: "g")
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private func nutrientRow(label: String, value: Double, unit: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
            Spacer()
            Text(String(format: "%.1f %@", value, unit))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var scoreColor: Color {
        switch record.qualityScore {
        case 80...100: return .green
        case 60..<80: return .blue
        case 40..<60: return .orange
        default: return .red
        }
    }
}
