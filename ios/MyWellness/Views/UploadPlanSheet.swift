import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import PhotosUI

struct UploadPlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM

    @State private var selectedFileURL: URL?
    @State private var fileName: String = ""
    @State private var showFilePicker: Bool = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoImages: [UIImage] = []
    @State private var isAnalyzing: Bool = false
    @State private var analysisError: String?
    @State private var importedPlan: NutritionPlan?
    @State private var analysisStep: String = ""
    @State private var showConfirmReplace: Bool = false
    @State private var uploadMode: UploadMode = .file
    @State private var selectedPreviewDay: String = "Monday"

    private let purpleAccent = Color(red: 0.48, green: 0.27, blue: 0.92)
    private let purpleLight = Color(red: 0.55, green: 0.27, blue: 0.88)

    private static let maxUploadsPerMonth = 2
    private static let uploadCountKey = "planUploadCount"
    private static let uploadMonthKey = "planUploadMonth"

    private var uploadsRemaining: Int {
        let currentMonth = Self.currentMonthString()
        let savedMonth = UserDefaults.standard.string(forKey: Self.uploadMonthKey) ?? ""
        if savedMonth != currentMonth { return Self.maxUploadsPerMonth }
        let used = UserDefaults.standard.integer(forKey: Self.uploadCountKey)
        return max(0, Self.maxUploadsPerMonth - used)
    }

    private var hasReachedLimit: Bool { uploadsRemaining <= 0 }

    private static func currentMonthString() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM"
        return df.string(from: Date())
    }

    private static func incrementUploadCount() {
        let currentMonth = currentMonthString()
        let savedMonth = UserDefaults.standard.string(forKey: uploadMonthKey) ?? ""
        if savedMonth != currentMonth {
            UserDefaults.standard.set(currentMonth, forKey: uploadMonthKey)
            UserDefaults.standard.set(1, forKey: uploadCountKey)
        } else {
            let current = UserDefaults.standard.integer(forKey: uploadCountKey)
            UserDefaults.standard.set(current + 1, forKey: uploadCountKey)
        }
    }

    private enum UploadMode {
        case file
        case photo
    }

    private enum ImportPhase {
        case selectSource
        case analyzing
        case result
        case error
    }

    private var currentPhase: ImportPhase {
        if isAnalyzing { return .analyzing }
        if importedPlan != nil { return .result }
        if analysisError != nil { return .error }
        return .selectSource
    }

    private let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    private let shortDayKeys = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                sheetHeader
                ScrollView {
                    VStack(spacing: 20) {
                        switch currentPhase {
                        case .selectSource:
                            sourceSelectionContent
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
                .scrollIndicators(.hidden)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
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
            .onChange(of: selectedPhotos) { _, newValue in
                Task {
                    var images: [UIImage] = []
                    for item in newValue {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let img = UIImage(data: data) {
                            images.append(img)
                        }
                    }
                    photoImages = images
                    analysisError = nil
                    importedPlan = nil
                }
            }
            .alert(Lang.s("upload_confirm_replace"), isPresented: $showConfirmReplace) {
                Button(Lang.s("cancel"), role: .cancel) {}
                Button(Lang.s("upload_apply_plan"), role: .destructive) {
                    applyImportedPlan()
                }
            } message: {
                Text(Lang.s("upload_replace_message"))
            }
        }
    }

    private var sheetHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(purpleAccent.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(purpleAccent)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(Lang.s("upload_your_plan"))
                    .font(.title3.bold())
                Text(Lang.s("upload_plan_subtitle"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    private var sourceSelectionContent: some View {
        VStack(spacing: 20) {
            if hasReachedLimit {
                uploadLimitBanner
            }

            howItWorksCard

            uploadRemainingBadge

            modePicker

            if uploadMode == .file {
                fileUploadSection
            } else {
                photoUploadSection
            }

            analyzeButton
        }
    }

    private var howItWorksCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(purpleAccent)
                Text(Lang.s("how_it_works"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(purpleAccent)
            }

            VStack(alignment: .leading, spacing: 6) {
                howItWorksStep(number: "1", text: Lang.s("upload_step_upload"))
                howItWorksStep(number: "2", text: Lang.s("upload_step_ai_reads"))
                howItWorksStep(number: "3", text: Lang.s("upload_step_plan_ready"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(purpleAccent.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(purpleAccent.opacity(0.15), lineWidth: 1)
        )
    }

    private func howItWorksStep(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(purpleAccent.opacity(0.7))
                .clipShape(Circle())
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var modePicker: some View {
        HStack(spacing: 0) {
            modeButton(title: Lang.s("upload_mode_file"), icon: "doc.fill", mode: .file)
            modeButton(title: Lang.s("upload_mode_photo"), icon: "camera.fill", mode: .photo)
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func modeButton(title: String, icon: String, mode: UploadMode) -> some View {
        let isSelected = uploadMode == mode
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                uploadMode = mode
                selectedFileURL = nil
                fileName = ""
                selectedPhotos = []
                photoImages = []
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? purpleAccent : Color.clear)
            .foregroundStyle(isSelected ? .white : .secondary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var fileUploadSection: some View {
        VStack(spacing: 12) {
            Button { showFilePicker = true } label: {
                VStack(spacing: 12) {
                    if selectedFileURL != nil {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(purpleAccent)
                        Text(fileName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                        Text(Lang.s("upload_tap_change"))
                            .font(.caption)
                            .foregroundStyle(purpleAccent)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 32))
                            .foregroundStyle(purpleAccent.opacity(0.5))
                        VStack(spacing: 4) {
                            Text(Lang.s("upload_drop_hint"))
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                            Text("PDF, CSV, TXT, JSON")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            selectedFileURL != nil ? purpleAccent.opacity(0.4) : Color(.systemGray3),
                            style: StrokeStyle(lineWidth: 1.5, dash: selectedFileURL != nil ? [] : [6, 4])
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var photoUploadSection: some View {
        VStack(spacing: 12) {
            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: 8,
                matching: .images
            ) {
                VStack(spacing: 12) {
                    if photoImages.isEmpty {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 32))
                            .foregroundStyle(purpleAccent.opacity(0.5))
                        VStack(spacing: 4) {
                            Text(Lang.s("upload_select_photos"))
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                            Text(Lang.s("upload_photos_hint"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(photoImages.indices, id: \.self) { index in
                                    Image(uiImage: photoImages[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(purpleAccent.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .frame(height: 88)

                        Text("\(photoImages.count) \(Lang.s("upload_photos_selected"))")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(purpleAccent)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 150)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            !photoImages.isEmpty ? purpleAccent.opacity(0.4) : Color(.systemGray3),
                            style: StrokeStyle(lineWidth: 1.5, dash: photoImages.isEmpty ? [6, 4] : [])
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var canAnalyze: Bool {
        if hasReachedLimit { return false }
        switch uploadMode {
        case .file: return selectedFileURL != nil
        case .photo: return !photoImages.isEmpty
        }
    }

    private var uploadLimitBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(Lang.s("upload_limit_reached"))
                    .font(.subheadline.bold())
                Text(Lang.s("upload_limit_reached_desc"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }

    private var uploadRemainingBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.up.circle")
                .font(.caption.weight(.semibold))
                .foregroundStyle(hasReachedLimit ? .orange : purpleAccent)
            Text(String(format: Lang.s("upload_remaining"), uploadsRemaining))
                .font(.caption.weight(.medium))
                .foregroundStyle(hasReachedLimit ? .orange : .secondary)
            Spacer()
        }
    }

    private var analyzeButton: some View {
        Button {
            startAnalysis()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.body.weight(.semibold))
                Text(Lang.s("upload_analyze_btn"))
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                canAnalyze
                    ? LinearGradient(colors: [purpleLight, Color(red: 0.45, green: 0.55, blue: 0.98)], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color(.systemGray4), Color(.systemGray4)], startPoint: .leading, endPoint: .trailing)
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: canAnalyze ? purpleAccent.opacity(0.3) : .clear, radius: 10, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(!canAnalyze)
    }

    private var analyzingContent: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 30)

            ZStack {
                Circle()
                    .stroke(purpleAccent.opacity(0.15), lineWidth: 4)
                    .frame(width: 80, height: 80)
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(purpleAccent)
            }

            VStack(spacing: 8) {
                Text(Lang.s("upload_analyzing"))
                    .font(.title3.bold())
                Text(analysisStep)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Text(Lang.s("upload_analyzing_hint"))
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 30)
        }
        .frame(maxWidth: .infinity)
    }

    private var resultContent: some View {
        VStack(spacing: 16) {
            if let plan = importedPlan {
                resultBanner(plan: plan)

                dayPreviewSelector(plan: plan)

                if let dayPlan = plan.days.first(where: { $0.dayName == selectedPreviewDay }) {
                    dayPreviewContent(dayPlan: dayPlan)
                }

                applyButton

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

    private func resultBanner(plan: NutritionPlan) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text(Lang.s("upload_analysis_complete"))
                    .font(.headline)
                let totalMeals = plan.days.reduce(0) { $0 + $1.meals.count }
                let avgCal = plan.days.isEmpty ? 0 : plan.days.reduce(0) { $0 + $1.totalCalories } / plan.days.count
                Text("\(plan.days.count) \(Lang.s("upload_days_found")), \(totalMeals) \(Lang.s("upload_meals_found")), ~\(avgCal) kcal/\(Lang.s("day"))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.green.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func dayPreviewSelector(plan: NutritionPlan) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(0..<7, id: \.self) { i in
                    let day = days[i]
                    let hasPlan = plan.days.contains(where: { $0.dayName == day })
                    let isSelected = selectedPreviewDay == day
                    Button {
                        selectedPreviewDay = day
                    } label: {
                        VStack(spacing: 3) {
                            Text(Lang.s(shortDayKeys[i]))
                                .font(.caption.weight(isSelected ? .bold : .regular))
                            if hasPlan {
                                Circle()
                                    .fill(isSelected ? purpleAccent : Color(.systemGray3))
                                    .frame(width: 5, height: 5)
                            } else {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 5, height: 5)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(isSelected ? purpleAccent.opacity(0.12) : Color.clear)
                        .foregroundStyle(isSelected ? purpleAccent : .secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func dayPreviewContent(dayPlan: DayPlan) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text(Lang.localizedDayName(dayPlan.dayName))
                    .font(.subheadline.bold())
                Spacer()
                Text("\(dayPlan.totalCalories) kcal")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(purpleAccent)
            }
            .padding(.horizontal, 4)

            ForEach(dayPlan.meals) { meal in
                importedMealCard(meal)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func importedMealCard(_ meal: Meal) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(meal.type.rawValue)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(purpleAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(purpleAccent.opacity(0.1))
                    .clipShape(Capsule())
                Spacer()
                Text("\(meal.calories) kcal")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
            }

            Text(meal.name)
                .font(.subheadline.weight(.medium))
                .lineLimit(2)

            if !meal.ingredients.isEmpty {
                HStack(spacing: 6) {
                    macroTag(value: Int(meal.protein), label: "P", color: .red)
                    Text("·").foregroundStyle(.tertiary).font(.caption2)
                    macroTag(value: Int(meal.carbs), label: "C", color: .blue)
                    Text("·").foregroundStyle(.tertiary).font(.caption2)
                    macroTag(value: Int(meal.fat), label: "G", color: .orange)
                }

                Text("\(meal.ingredients.count) \(Lang.s("ingredients").lowercased())")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func macroTag(value: Int, label: String, color: Color) -> some View {
        Text("\(value)\(label)")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color)
    }

    private var applyButton: some View {
        Button {
            showConfirmReplace = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.body.weight(.semibold))
                Text(Lang.s("upload_apply_plan"))
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: [purpleLight, Color(red: 0.45, green: 0.55, blue: 0.98)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: purpleAccent.opacity(0.3), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var errorContent: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 20)

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)

            Text(Lang.s("upload_analysis_failed"))
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
                .background(purpleAccent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

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

    private func startAnalysis() {
        isAnalyzing = true
        analysisError = nil
        importedPlan = nil

        Task {
            do {
                switch uploadMode {
                case .file:
                    guard let fileURL = selectedFileURL else {
                        isAnalyzing = false
                        return
                    }
                    analysisStep = Lang.s("upload_reading_file")

                    guard fileURL.startAccessingSecurityScopedResource() else {
                        throw AIServiceError.networkError(Lang.s("file_access_error"))
                    }
                    defer { fileURL.stopAccessingSecurityScopedResource() }

                    let text = try extractText(from: fileURL)

                    guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        throw AIServiceError.networkError(Lang.s("upload_analysis_failed_detail"))
                    }

                    analysisStep = Lang.s("upload_ai_analyzing_meals")

                    let plan = try await AIService.analyzeMealPlanText(text: text)
                    importedPlan = plan
                    if let firstDay = plan.days.first {
                        selectedPreviewDay = firstDay.dayName
                    }

                case .photo:
                    guard !photoImages.isEmpty else {
                        isAnalyzing = false
                        return
                    }
                    analysisStep = Lang.s("upload_processing_photos")

                    var base64Images: [String] = []
                    for image in photoImages {
                        if let b64 = AIService.compressImageForAI(image, maxDimension: 1400, quality: 0.75) {
                            base64Images.append(b64)
                        }
                    }

                    guard !base64Images.isEmpty else {
                        throw AIServiceError.networkError(Lang.s("upload_photo_error"))
                    }

                    analysisStep = Lang.s("upload_ai_analyzing_meals")

                    let plan = try await AIService.analyzeMealPlanImages(imageBase64Strings: base64Images)
                    importedPlan = plan
                    if let firstDay = plan.days.first {
                        selectedPreviewDay = firstDay.dayName
                    }
                }

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
        Self.incrementUploadCount()
        appVM.applyScanNutritionPlan(plan)
        HapticHelper.notification(.success)
        dismiss()
    }
}
