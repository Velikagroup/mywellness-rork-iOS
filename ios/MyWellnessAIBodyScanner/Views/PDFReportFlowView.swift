import SwiftUI

struct PDFReportFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm
    @State private var step: Int = 0
    @State private var selectedRange: DateRangeOption = .last7Days
    @State private var isGenerating: Bool = false
    @State private var pdfData: Data? = nil
    @State private var showShareSheet: Bool = false

    private enum DateRangeOption: CaseIterable {
        case last7Days, last30Days, last90Days, allTime

        var label: String {
            switch self {
            case .last7Days: return Lang.s("pdf_last_7")
            case .last30Days: return Lang.s("pdf_last_30")
            case .last90Days: return Lang.s("pdf_last_90")
            case .allTime: return Lang.s("pdf_all_time")
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar(title: nil, onBack: {
                if step > 0 {
                    withAnimation(.spring(response: 0.3)) { step -= 1 }
                } else {
                    dismiss()
                }
            })

            Group {
                switch step {
                case 0: introStep
                case 1: dateRangeStep
                default: EmptyView()
                }
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            Spacer()

            if step == 0 {
                Button {
                    withAnimation(.spring(response: 0.3)) { step = 1 }
                } label: {
                    Text(Lang.s("next"))
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .clipShape(.rect(cornerRadius: 16))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            } else {
                Button {
                    generateAndShare()
                } label: {
                    HStack(spacing: 10) {
                        if isGenerating {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.85)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text(isGenerating ? Lang.s("pdf_generating") : Lang.s("pdf_generate_share"))
                            .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isGenerating ? Color(.systemGray3) : Color.black)
                    .clipShape(.rect(cornerRadius: 16))
                }
                .disabled(isGenerating)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showShareSheet) {
            if let data = pdfData {
                ShareSheet(items: [data as Any, "MyWellnessAIBodyScanner_Report.pdf"])
            }
        }
    }

    private var introStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 200, height: 200)
                    Image(systemName: "doc.richtext")
                        .font(.system(size: 60))
                        .foregroundStyle(.primary)
                }
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 8) {
                    Text(Lang.s("pdf_report_title"))
                        .font(.title.bold())
                    Text(Lang.s("pdf_what_find"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 20) {
                    reportFeature(icon: "fork.knife", title: Lang.s("pdf_user_profile"), subtitle: Lang.s("pdf_user_profile_desc"))
                    reportFeature(icon: "flame.fill", title: Lang.s("pdf_cal_macros"), subtitle: Lang.s("pdf_cal_macros_desc"))
                    reportFeature(icon: "chart.line.uptrend.xyaxis", title: Lang.s("pdf_weight_progress"), subtitle: Lang.s("pdf_weight_progress_desc"))
                    reportFeature(icon: "clock", title: Lang.s("pdf_daily_trends"), subtitle: Lang.s("pdf_daily_trends_desc"))
                }
                .padding(.horizontal, 16)

                HStack(spacing: 10) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    Text(Lang.s("pdf_device_share"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(Color(.systemGray6))
                .clipShape(.rect(cornerRadius: 12))
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 40)
        }
    }

    private var dateRangeStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Lang.s("pdf_select_period"))
                .font(.title.bold())
            Text(Lang.s("pdf_choose_range"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(DateRangeOption.allCases, id: \.self) { option in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedRange = option
                        }
                    } label: {
                        HStack {
                            Text(option.label)
                                .font(.body.weight(.medium))
                                .foregroundStyle(selectedRange == option ? .white : .primary)
                            Spacer()
                            if selectedRange == option {
                                Image(systemName: "checkmark")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 18)
                        .background(selectedRange == option ? Color.black : Color(.systemGray6))
                        .clipShape(.rect(cornerRadius: 14))
                    }
                }
            }
            .padding(.top, 8)

            let count = filteredSnapshots.count
            Text(count == 0 ? Lang.s("pdf_no_data_period") : Lang.s("pdf_days_recorded").replacingOccurrences(of: "%d", with: "\(count)"))
                .font(.caption)
                .foregroundStyle(count == 0 ? .red : .secondary)
                .padding(.top, 4)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }

    private var filteredSnapshots: [DaySnapshot] {
        let calendar = Calendar.current
        let now = Date()
        let cutoff: Date
        switch selectedRange {
        case .last7Days:
            cutoff = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .last30Days:
            cutoff = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case .last90Days:
            cutoff = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case .allTime:
            cutoff = Date.distantPast
        }
        return vm.dailySnapshots.values.filter { $0.date >= cutoff }
    }

    private var filteredWeightHistory: [WeightEntry] {
        let calendar = Calendar.current
        let now = Date()
        let cutoff: Date
        switch selectedRange {
        case .last7Days:
            cutoff = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .last30Days:
            cutoff = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case .last90Days:
            cutoff = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case .allTime:
            cutoff = Date.distantPast
        }
        return vm.weightHistory.filter { $0.date >= cutoff }
    }

    private func reportFeature(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.primary)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func generateAndShare() {
        isGenerating = true
        let snapshots = filteredSnapshots
        let weights = filteredWeightHistory
        let profile = vm.userProfile
        let rangeName = selectedRange.label

        Task.detached(priority: .userInitiated) {
            let generator = PDFReportGenerator(
                profile: profile,
                snapshots: snapshots,
                weightHistory: weights,
                rangeName: rangeName
            )
            let data = generator.generate()
            await MainActor.run {
                pdfData = data
                isGenerating = false
                showShareSheet = true
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
