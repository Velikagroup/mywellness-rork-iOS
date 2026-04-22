import SwiftUI
import Charts

struct BodyScanHistoryView: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(\.dismiss) private var dismiss

    private let scanTeal = Color(red: 0.0, green: 0.75, blue: 0.7)
    private let accentGreen = Color(red: 0.2, green: 0.78, blue: 0.45)

    private var sortedRecords: [BodyScanRecord] {
        appVM.bodyScanHistory.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if appVM.bodyScanHistory.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            trendChartSection
                            recordsListSection
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(Lang.s("body_scan_history"))
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
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.stand.line.dotted.figure.stand")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text(Lang.s("no_scans_yet"))
                .font(.title3.weight(.semibold))
            Text(Lang.s("first_scan_message"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var trendChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(Lang.s("overall_trend"), systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)

            let chronological = appVM.bodyScanHistory.sorted { $0.date < $1.date }

            if chronological.count >= 2 {
                bodyFatChart(records: chronological)
            } else {
                singleScanSummary(records: chronological)
            }
        }
        .padding(16)
        .background(.white.opacity(0.8))
        .clipShape(.rect(cornerRadius: 16))
    }

    @ViewBuilder
    private func bodyFatChart(records: [BodyScanRecord]) -> some View {
        let fatData = records.compactMap { r -> (date: Date, value: Double)? in
            guard let v = r.bodyFatNumeric else { return nil }
            return (r.date, v)
        }
        let ageData = records.compactMap { r -> (date: Date, value: Double)? in
            guard let v = r.biologicalAgeNumeric else { return nil }
            return (r.date, v)
        }

        if !fatData.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(Lang.s("body_fat_percent"))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Chart {
                    ForEach(Array(fatData.enumerated()), id: \.offset) { _, point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("BF%", point.value)
                        )
                        .foregroundStyle(scanTeal)
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("BF%", point.value)
                        )
                        .foregroundStyle(scanTeal)
                        .symbolSize(40)

                        AreaMark(
                            x: .value("Date", point.date),
                            y: .value("BF%", point.value)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [scanTeal.opacity(0.2), scanTeal.opacity(0.0)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 160)
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
                            if let v = value.as(Double.self) {
                                Text("\(Int(v))%")
                                    .font(.caption2)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    }
                }
            }
        }

        if !ageData.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(Lang.s("biological_age"))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                Chart {
                    ForEach(Array(ageData.enumerated()), id: \.offset) { _, point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Age", point.value)
                        )
                        .foregroundStyle(accentGreen)
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("Age", point.value)
                        )
                        .foregroundStyle(accentGreen)
                        .symbolSize(40)

                        AreaMark(
                            x: .value("Date", point.date),
                            y: .value("Age", point.value)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [accentGreen.opacity(0.2), accentGreen.opacity(0.0)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 120)
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
                            if let v = value.as(Double.self) {
                                Text("\(Int(v))")
                                    .font(.caption2)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    }
                }
            }
        }
    }

    private func singleScanSummary(records: [BodyScanRecord]) -> some View {
        VStack(spacing: 8) {
            if let record = records.first {
                HStack(spacing: 16) {
                    miniStat(label: Lang.s("body_fat_percent"), value: record.estimatedBodyFat, icon: "percent", color: scanTeal)
                    miniStat(label: Lang.s("biological_age"), value: record.biologicalAge, icon: "heart.fill", color: accentGreen)
                }
                Text(Lang.s("more_scans_for_trend"))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
        }
    }

    private func miniStat(label: String, value: String, icon: String, color: Color) -> some View {
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

    private var recordsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(Lang.s("records"), systemImage: "clock.arrow.circlepath")
                .font(.headline)

            ForEach(sortedRecords) { record in
                recordCard(record)
            }
        }
    }

    private func recordCard(_ record: BodyScanRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.date.formatted(.dateTime.day().month(.wide).year().locale(Locale(identifier: "it"))))
                        .font(.subheadline.weight(.semibold))
                    Text(record.date, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(record.somatotype)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(scanTeal.opacity(0.15))
                    .foregroundStyle(scanTeal)
                    .clipShape(.capsule)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                dataCell(label: Lang.s("body_fat_percent"), value: record.estimatedBodyFat, icon: "flame.fill", color: .orange)
                dataCell(label: Lang.s("bio_age"), value: record.biologicalAge, icon: "heart.fill", color: .pink)
                dataCell(label: Lang.s("definition"), value: record.muscleDefinition, icon: "figure.strengthtraining.traditional", color: scanTeal)
                dataCell(label: Lang.s("bloating"), value: record.bloatingPercentage, icon: "drop.fill", color: .blue)
                dataCell(label: Lang.s("skin"), value: record.skinTexture, icon: "hand.raised.fill", color: .purple)
                dataCell(label: Lang.s("cal_day"), value: "\(record.dailyCalories)", icon: "bolt.fill", color: accentGreen)
            }

            if !record.strongPoints.isEmpty || !record.weakPoints.isEmpty {
                Divider()

                if !record.strongPoints.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Lang.s("strong_points"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(accentGreen)
                        ForEach(record.strongPoints, id: \.self) { point in
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundStyle(accentGreen)
                                    .padding(.top, 1)
                                Text(point)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                if !record.weakPoints.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Lang.s("weak_points"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.orange)
                        ForEach(record.weakPoints, id: \.self) { point in
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                                    .padding(.top, 1)
                                Text(point)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            if !record.overallAssessment.isEmpty {
                Divider()
                Text(record.overallAssessment)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(14)
        .background(.white.opacity(0.8))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func dataCell(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
            Text(value)
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.06))
        .clipShape(.rect(cornerRadius: 10))
    }
}
