import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct ImportWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM

    @State private var selectedFileURL: URL?
    @State private var fileName: String = ""
    @State private var showFilePicker: Bool = false
    @State private var isAnalyzing: Bool = false
    @State private var analysisError: String?
    @State private var importedPlan: WorkoutPlan?
    @State private var analysisStep: String = ""
    @State private var showConfirmReplace: Bool = false

    private let maxImportsPerMonth: Int = 2

    private var importCount: Int {
        let key = "workout_import_count"
        let monthKey = "workout_import_month"
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        let storedMonth = UserDefaults.standard.integer(forKey: monthKey)
        let storedYear = UserDefaults.standard.integer(forKey: "workout_import_year")
        if storedMonth != currentMonth || storedYear != currentYear {
            return 0
        }
        return UserDefaults.standard.integer(forKey: key)
    }

    private var hasReachedLimit: Bool {
        importCount >= maxImportsPerMonth
    }

    private func recordImport() {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        let storedMonth = UserDefaults.standard.integer(forKey: "workout_import_month")
        let storedYear = UserDefaults.standard.integer(forKey: "workout_import_year")
        var count = UserDefaults.standard.integer(forKey: "workout_import_count")
        if storedMonth != currentMonth || storedYear != currentYear {
            count = 0
        }
        count += 1
        UserDefaults.standard.set(count, forKey: "workout_import_count")
        UserDefaults.standard.set(currentMonth, forKey: "workout_import_month")
        UserDefaults.standard.set(currentYear, forKey: "workout_import_year")
    }

    private enum ImportPhase {
        case selectFile
        case analyzing
        case result
        case error
    }

    private var currentPhase: ImportPhase {
        if isAnalyzing { return .analyzing }
        if let _ = importedPlan { return .result }
        if analysisError != nil { return .error }
        return .selectFile
    }

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader
            ScrollView {
                VStack(spacing: 20) {
                    switch currentPhase {
                    case .selectFile:
                        fileSelectionContent
                    case .analyzing:
                        analyzingContent
                    case .result:
                        resultContent
                    case .error:
                        errorContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.pdf, .commaSeparatedText, .json, .plainText],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                selectedFileURL = url
                fileName = url.lastPathComponent
                analysisError = nil
                importedPlan = nil
            }
        }
        .alert(Lang.s("confirm_replace_plan"), isPresented: $showConfirmReplace) {
            Button(Lang.s("cancel"), role: .cancel) {}
            Button(Lang.s("replace_plan_confirm"), role: .destructive) {
                applyImportedPlan()
            }
        } message: {
            Text(Lang.s("replace_plan_message"))
        }
    }

    // MARK: - Header

    private var sheetHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.title2)
                .foregroundStyle(Color.wellnessTeal)
                .frame(width: 44, height: 44)
                .background(Color.wellnessTeal.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(Lang.s("import_workout_title"))
                    .font(.title3.bold())
                Text(Lang.s("ai_import"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    // MARK: - File Selection

    private var fileSelectionContent: some View {
        VStack(spacing: 20) {
            Text(Lang.s("import_pdf_desc"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button { showFilePicker = true } label: {
                fileDropZone
            }
            .buttonStyle(.plain)

            Spacer().frame(height: 8)

            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundStyle(hasReachedLimit ? .red : .secondary)
                Text(Lang.s("import_limit_info").replacingOccurrences(of: "%d", with: "\(importCount)", options: [], range: Lang.s("import_limit_info").range(of: "%d")).replacingOccurrences(of: "%d", with: "\(maxImportsPerMonth)"))
                    .font(.caption)
                    .foregroundStyle(hasReachedLimit ? .red : .secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if hasReachedLimit {
                Text(Lang.s("import_limit_reached"))
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.red.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Button {
                startAnalysis()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text(Lang.s("analyze_with_ai"))
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(selectedFileURL != nil && !hasReachedLimit ? Color.wellnessTeal : Color(.systemGray4))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(selectedFileURL == nil || hasReachedLimit)
        }
    }

    private var fileDropZone: some View {
        VStack(spacing: 12) {
            if let _ = selectedFileURL {
                Image(systemName: "doc.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.wellnessTeal)
                Text(fileName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                Text(Lang.s("tap_change_file"))
                    .font(.caption)
                    .foregroundStyle(Color.wellnessTeal)
            } else {
                Image(systemName: "doc.text")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.wellnessTeal.opacity(0.5))
                Text(Lang.s("drop_file_here"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(Lang.s("tap_select_file"))
                    .font(.caption)
                    .foregroundStyle(Color.wellnessTeal)
                Text("PDF, CSV, TXT o JSON")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [8, 5]))
                .foregroundStyle(selectedFileURL != nil ? Color.wellnessTeal.opacity(0.5) : Color(.systemGray3))
        )
    }

    // MARK: - Analyzing

    private var analyzingContent: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)

            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.wellnessTeal)

            VStack(spacing: 8) {
                Text(Lang.s("analyzing_pdf"))
                    .font(.title3.bold())
                Text(analysisStep)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer().frame(height: 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Result

    private var resultContent: some View {
        VStack(spacing: 16) {
            if let plan = importedPlan {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Lang.s("pdf_analysis_complete"))
                            .font(.headline)
                        let trainingDays = plan.days.filter { !$0.isRestDay }
                        let totalExercises = trainingDays.reduce(0) { $0 + $1.exercises.count }
                        Text("\(trainingDays.count) \(Lang.s("training_days_found")), \(totalExercises) \(Lang.s("exercises_found"))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(Color.green.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                ForEach(plan.days.filter { !$0.isRestDay }) { day in
                    importedDayCard(day)
                }

                Button {
                    showConfirmReplace = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text(Lang.s("apply_imported_plan"))
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.wellnessTeal)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    importedPlan = nil
                    analysisError = nil
                } label: {
                    Text(Lang.s("cancel"))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func importedDayCard(_ day: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(Lang.localizedDayName(day.dayName))
                    .font(.subheadline.bold())
                Spacer()
                Text(day.focus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(day.exercises) { exercise in
                HStack(spacing: 8) {
                    Circle()
                        .fill(categoryColor(exercise.category))
                        .frame(width: 6, height: 6)
                    Text(exercise.name)
                        .font(.caption)
                        .lineLimit(1)
                    Spacer()
                    Text(exercise.setDisplay)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func categoryColor(_ category: ExerciseCategory) -> Color {
        switch category {
        case .warmup: return .orange
        case .main: return Color.wellnessTeal
        case .cooldown: return .blue
        }
    }

    // MARK: - Error

    private var errorContent: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 20)

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)

            Text(Lang.s("pdf_analysis_failed"))
                .font(.title3.bold())

            Text(analysisError ?? "")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 8)

            Button {
                analysisError = nil
                startAnalysis()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text(Lang.s("retry_generation"))
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.wellnessTeal)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(selectedFileURL == nil)

            Button {
                analysisError = nil
            } label: {
                Text(Lang.s("back"))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Actions

    private func startAnalysis() {
        guard let fileURL = selectedFileURL else { return }

        isAnalyzing = true
        analysisError = nil
        importedPlan = nil
        analysisStep = Lang.s("reading_file")

        Task {
            do {
                guard fileURL.startAccessingSecurityScopedResource() else {
                    throw AIServiceError.networkError(Lang.s("file_access_error"))
                }
                defer { fileURL.stopAccessingSecurityScopedResource() }

                let text = try extractText(from: fileURL)

                guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw AIServiceError.noContent
                }

                analysisStep = Lang.s("ai_analyzing_exercises")

                let plan = try await AIService.analyzeWorkoutPDF(pdfText: text)

                importedPlan = plan
                isAnalyzing = false
            } catch {
                analysisError = error.localizedDescription
                isAnalyzing = false
            }
        }
    }

    private func extractText(from url: URL) throws -> String {
        let ext = url.pathExtension.lowercased()

        if ext == "pdf" {
            guard let document = PDFDocument(url: url) else {
                throw AIServiceError.networkError(Lang.s("pdf_read_error"))
            }
            var text = ""
            for i in 0..<document.pageCount {
                if let page = document.page(at: i), let pageText = page.string {
                    text += pageText + "\n"
                }
            }
            return text
        }

        let data = try Data(contentsOf: url)
        guard let text = String(data: data, encoding: .utf8) else {
            throw AIServiceError.networkError(Lang.s("file_read_error"))
        }
        return text
    }

    private func applyImportedPlan() {
        guard let plan = importedPlan else { return }
        recordImport()
        appVM.applyScanWorkoutPlan(plan)
        dismiss()
    }
}
