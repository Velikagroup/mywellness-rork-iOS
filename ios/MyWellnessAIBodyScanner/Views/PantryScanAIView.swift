import SwiftUI
import PhotosUI

private enum ScanStep {
    case intro, photo, analyzing, result
}

private enum PhotoSlot {
    case front, nutrition
}

private enum CaptureSource {
    case camera, gallery
}

struct PantryScanAIView: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(\.dismiss) private var dismiss

    @State private var step: ScanStep = .intro
    @State private var frontImage: UIImage?
    @State private var nutritionImage: UIImage?
    @State private var result: PantryProductResult?
    @State private var errorMessage: String?
    @State private var scannedBarcode: String?

    @State private var activeSlot: PhotoSlot?
    @State private var showCamera: Bool = false
    @State private var showBarcodeScanner: Bool = false
    @State private var frontPickerItem: PhotosPickerItem?
    @State private var nutritionPickerItem: PhotosPickerItem?
    @State private var showFrontGallery: Bool = false
    @State private var showNutritionGallery: Bool = false
    @State private var analyzingBarcode: Bool = false

    @State private var editName: String = ""
    @State private var editBrand: String = ""
    @State private var editCategory: String = "Condiments and Spices"
    @State private var editCalories: String = ""
    @State private var editProtein: String = ""
    @State private var editCarbs: String = ""
    @State private var editFat: String = ""
    @State private var editServing: String = "100g"

    private let purpleMain = Color(red: 0.55, green: 0.27, blue: 0.88)
    private let pinkAccent = Color(red: 0.92, green: 0.27, blue: 0.55)

    private var purpleGradient: LinearGradient {
        LinearGradient(colors: [purpleMain, pinkAccent], startPoint: .leading, endPoint: .trailing)
    }

    private var tealGradient: LinearGradient {
        LinearGradient(colors: [Color.wellnessTeal, Color.wellnessTeal.opacity(0.85)], startPoint: .leading, endPoint: .trailing)
    }

    private var anyPhotoReady: Bool {
        frontImage != nil || nutritionImage != nil
    }

    private var bothPhotosReady: Bool {
        frontImage != nil && nutritionImage != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                VStack(spacing: 0) {
                    stepIndicator
                        .padding(.top, 8)
                        .padding(.horizontal, 24)

                    ScrollView {
                        VStack(spacing: 24) {
                            switch step {
                            case .intro:
                                introContent
                            case .photo:
                                photoStepContent
                            case .analyzing:
                                analyzingContent
                            case .result:
                                if result != nil {
                                    resultContent
                                }
                            }

                            if let err = errorMessage {
                                Text(err)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 48)
                    }
                    .scrollIndicators(.hidden)

                    if step != .analyzing {
                        bottomBar
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                            .background(Color(.systemGroupedBackground))
                    }
                }
            }
            .navigationTitle(Lang.s("scanner_title"))
            .navigationBarTitleDisplayMode(.inline)
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
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCapturePicker { image in
                showCamera = false
                guard let image else { return }
                switch activeSlot {
                case .front:
                    frontImage = image
                case .nutrition:
                    nutritionImage = image
                case nil:
                    break
                }
                activeSlot = nil
            }
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showBarcodeScanner) {
            BarcodeScannerView { code in
                scannedBarcode = code
                showBarcodeScanner = false
                Task { await runBarcodeAnalysis(code) }
            }
        }
        .photosPicker(isPresented: $showFrontGallery, selection: $frontPickerItem, matching: .images)
        .photosPicker(isPresented: $showNutritionGallery, selection: $nutritionPickerItem, matching: .images)
        .onChange(of: frontPickerItem) { _, item in
            handlePickerItem(item, for: .front)
        }
        .onChange(of: nutritionPickerItem) { _, item in
            handlePickerItem(item, for: .nutrition)
        }
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 6) {
            stepDot(index: 0, label: Lang.s("scanner_step_photo"), active: step == .photo || step == .intro, done: step == .analyzing || step == .result)
            stepLine(done: step == .analyzing || step == .result)
            stepDot(index: 1, label: Lang.s("scanner_step_analysis"), active: step == .analyzing, done: step == .result)
            stepLine(done: step == .result)
            stepDot(index: 2, label: Lang.s("scanner_step_result"), active: step == .result, done: false)
        }
        .padding(.vertical, 12)
    }

    private func stepDot(index: Int, label: String, active: Bool, done: Bool) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(done ? Color.wellnessTeal : active ? purpleMain : Color(.systemGray4))
                    .frame(width: 28, height: 28)
                if done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(index + 1)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(active ? .white : Color(.systemGray2))
                }
            }
            Text(label)
                .font(.caption2.weight(active ? .semibold : .regular))
                .foregroundStyle(active ? .primary : .secondary)
        }
    }

    private func stepLine(done: Bool) -> some View {
        Rectangle()
            .fill(done ? Color.wellnessTeal : Color(.systemGray4))
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 18)
    }

    // MARK: - Intro

    private var introContent: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [purpleMain.opacity(0.15), pinkAccent.opacity(0.10)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 110)
                Image(systemName: "sparkles")
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: [purpleMain, pinkAccent], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            .padding(.top, 12)

            VStack(spacing: 8) {
                Text(Lang.s("scanner_product_title"))
                    .font(.title2.bold())
                Text(Lang.s("scanner_product_desc"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                introStep(icon: "tag.fill", color: purpleMain,
                          title: Lang.s("scanner_front_label"),
                          description: Lang.s("scanner_front_desc"))
                introStep(icon: "tablecells.fill", color: Color.wellnessTeal,
                          title: Lang.s("scanner_nutri_label"),
                          description: Lang.s("scanner_nutri_desc"))
                introStep(icon: "barcode.viewfinder", color: .orange,
                          title: Lang.s("scanner_barcode"),
                          description: Lang.s("scanner_barcode_desc"))
            }
        }
    }

    private func introStep(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 46, height: 46)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Photo Step (Dual Slots + Barcode)

    private var photoStepContent: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "camera.viewfinder")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(purpleMain)
                    Text(Lang.s("scanner_take_photos"))
                        .font(.title3.bold())
                }
                Text(Lang.s("scanner_photo_both"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 12) {
                photoSlotCard(
                    slot: .front,
                    image: frontImage,
                    icon: "tag.fill",
                    label: Lang.s("scanner_front_slot"),
                    color: purpleMain
                )
                photoSlotCard(
                    slot: .nutrition,
                    image: nutritionImage,
                    icon: "tablecells.fill",
                    label: Lang.s("scanner_nutri_slot"),
                    color: Color.wellnessTeal
                )
            }

            barcodeButton
        }
    }

    private func photoSlotCard(slot: PhotoSlot, image: UIImage?, icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 0) {
            if let img = image {
                Color(.secondarySystemGroupedBackground)
                    .frame(height: 160)
                    .overlay {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(alignment: .topLeading) {
                        ZStack {
                            Circle().fill(Color.green).frame(width: 24, height: 24)
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .padding(8)
                    }
                    .overlay(alignment: .bottom) {
                        HStack(spacing: 8) {
                            Button {
                                activeSlot = slot
                                showCamera = true
                            } label: {
                                Label(Lang.s("scanner_retake"), systemImage: "camera.fill")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(.black.opacity(0.6))
                                    .clipShape(Capsule())
                            }
                            Button {
                                switch slot {
                                case .front: showFrontGallery = true
                                case .nutrition: showNutritionGallery = true
                                }
                            } label: {
                                Image(systemName: "photo")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(5)
                                    .background(.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.bottom, 8)
                    }
            } else {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.12))
                            .frame(width: 56, height: 56)
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundStyle(color)
                    }
                    Text(label)
                        .font(.caption.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                    HStack(spacing: 6) {
                        Button {
                            activeSlot = slot
                            showCamera = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 10))
                                Text(Lang.s("scanner_photo_btn"))
                                    .font(.caption2.weight(.semibold))
                            }
                            .foregroundStyle(color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(color.opacity(0.12))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)

                        Button {
                            switch slot {
                            case .front: showFrontGallery = true
                            case .nutrition: showNutritionGallery = true
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "photo")
                                    .font(.system(size: 10))
                                Text(Lang.s("scanner_gallery_btn"))
                                    .font(.caption2.weight(.semibold))
                            }
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(color.opacity(0.2), lineWidth: 1.5, antialiased: true)
                )
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var barcodeButton: some View {
        Button {
            showBarcodeScanner = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "barcode.viewfinder")
                    .font(.body.weight(.semibold))
                VStack(alignment: .leading, spacing: 2) {
                    Text(Lang.s("scanner_barcode_scan"))
                        .font(.subheadline.weight(.semibold))
                    Text(Lang.s("scanner_barcode_identify"))
                        .font(.caption)
                        .opacity(0.7)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                LinearGradient(colors: [.orange, .orange.opacity(0.85)], startPoint: .leading, endPoint: .trailing)
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Analyzing

    private var analyzingContent: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 10)

            if scannedBarcode != nil {
                HStack(spacing: 12) {
                    Image(systemName: "barcode")
                        .font(.title2)
                        .foregroundStyle(purpleMain)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(Lang.s("scanner_barcode_found"))\(scannedBarcode ?? "")")
                            .font(.subheadline.weight(.semibold))
                        Text(Lang.s("scanner_searching"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(14)
                .background(purpleMain.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                HStack(spacing: 12) {
                    if let front = frontImage {
                        photoThumb(front)
                    }
                    if let nutrition = nutritionImage {
                        photoThumb(nutrition)
                    }
                }
            }

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [purpleMain.opacity(0.12), Color.wellnessTeal.opacity(0.10)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                ProgressView()
                    .scaleEffect(1.8)
                    .tint(purpleMain)
            }

            VStack(spacing: 8) {
                Text(Lang.s("scanner_analyzing"))
                    .font(.title3.bold())
                Text(scannedBarcode != nil
                     ? Lang.s("scanner_barcode_identifying")
                     : Lang.s("scanner_reading_barcode"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 16) {
                analyzingPill(Lang.s("scanner_reading"), icon: "eye.fill", color: purpleMain)
                analyzingPill(Lang.s("scanner_extracting"), icon: "chart.bar.fill", color: Color.wellnessTeal)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private func photoThumb(_ image: UIImage) -> some View {
        Color(.secondarySystemGroupedBackground)
            .frame(width: 100, height: 80)
            .overlay {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(purpleMain.opacity(0.3), lineWidth: 2)
            )
    }

    private func analyzingPill(_ label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
            Text(label)
                .font(.caption.weight(.medium))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(color.opacity(0.10))
        .clipShape(Capsule())
    }

    // MARK: - Result

    private var resultContent: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text(Lang.s("scanner_identified"))
                        .font(.headline)
                    Text(Lang.s("scanner_review_save"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(14)
            .background(Color.green.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            if scannedBarcode != nil {
                HStack(spacing: 8) {
                    Image(systemName: "barcode")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Lang.s("scanner_barcode_scanned"))\(scannedBarcode ?? "")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(Capsule())
            } else {
                HStack(spacing: 10) {
                    if let front = frontImage {
                        photoThumbSmall(front, label: Lang.s("scanner_front_thumb"))
                    }
                    if let nutrition = nutritionImage {
                        photoThumbSmall(nutrition, label: Lang.s("scanner_back_thumb"))
                    }
                }
            }

            VStack(spacing: 0) {
                resultField(label: Lang.s("pantry_name"), systemIcon: "shippingbox.fill", iconColor: purpleMain) {
                    TextField(Lang.s("scanner_product_name"), text: $editName)
                }
                Divider().padding(.leading, 56)
                resultField(label: Lang.s("pantry_brand"), systemIcon: "building.2.fill", iconColor: .orange) {
                    TextField(Lang.s("pantry_brand_optional"), text: $editBrand)
                }
                Divider().padding(.leading, 56)
                resultField(label: Lang.s("pantry_category"), systemIcon: "tag.fill", iconColor: .blue) {
                    Picker("", selection: $editCategory) {
                        ForEach(ShoppingListItem.allCategories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .labelsHidden()
                }
                Divider().padding(.leading, 56)
                resultField(label: Lang.s("scanner_serving"), systemIcon: "scalemass.fill", iconColor: .purple) {
                    TextField(Lang.s("scanner_serving_ph"), text: $editServing)
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.wellnessTeal)
                    Text(Lang.s("scanner_nutri_values"))
                        .font(.subheadline.weight(.semibold))
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)

                VStack(spacing: 0) {
                    nutritionRow(label: Lang.s("calories"), unit: "kcal", value: $editCalories, color: Color.wellnessTeal, keyboardType: .numberPad)
                    Divider().padding(.leading, 16)
                    nutritionRow(label: Lang.s("protein"), unit: "g", value: $editProtein, color: .red, keyboardType: .decimalPad)
                    Divider().padding(.leading, 16)
                    nutritionRow(label: Lang.s("carbs"), unit: "g", value: $editCarbs, color: .blue, keyboardType: .decimalPad)
                    Divider().padding(.leading, 16)
                    nutritionRow(label: Lang.s("fat"), unit: "g", value: $editFat, color: .orange, keyboardType: .decimalPad)
                }
                .padding(.bottom, 8)
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func photoThumbSmall(_ image: UIImage, label: String) -> some View {
        VStack(spacing: 4) {
            Color(.secondarySystemGroupedBackground)
                .frame(width: 70, height: 55)
                .overlay {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func resultField<Content: View>(label: String, systemIcon: String, iconColor: Color, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: systemIcon)
                    .font(.system(size: 14))
                    .foregroundStyle(iconColor)
            }
            .padding(.leading, 14)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 90, alignment: .leading)
            content()
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 14)
        }
        .frame(minHeight: 50)
    }

    private func nutritionRow(label: String, unit: String, value: Binding<String>, color: Color, keyboardType: UIKeyboardType) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .padding(.leading, 16)
            Text(label)
                .font(.subheadline)
            Spacer()
            TextField("0", text: value)
                .keyboardType(keyboardType)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
                .foregroundStyle(color)
                .fontWeight(.semibold)
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .leading)
                .padding(.trailing, 14)
        }
        .frame(height: 46)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 10) {
            switch step {
            case .intro:
                primaryButton(Lang.s("scanner_start"), icon: "camera.fill", gradient: purpleGradient) {
                    withAnimation(.spring(response: 0.4)) {
                        step = .photo
                    }
                }

            case .photo:
                if bothPhotosReady {
                    primaryButton(Lang.s("scanner_analyze_ai"), icon: "sparkles", gradient: purpleGradient) {
                        Task { await runDualPhotoAnalysis() }
                    }
                } else {
                    primaryButton(Lang.s("scanner_analyze_ai"), icon: "sparkles", gradient: purpleGradient) {}
                        .opacity(0.4)
                        .allowsHitTesting(false)

                    if anyPhotoReady {
                        Text(Lang.s("scanner_better_both"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(Lang.s("scanner_take_one"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

            case .analyzing:
                EmptyView()

            case .result:
                primaryButton(Lang.s("scanner_save_pantry"), icon: "checkmark.circle.fill", gradient: tealGradient) {
                    saveProduct()
                }
                .disabled(editName.trimmingCharacters(in: .whitespaces).isEmpty)

                Button {
                    withAnimation(.spring(response: 0.4)) {
                        frontImage = nil
                        nutritionImage = nil
                        result = nil
                        scannedBarcode = nil
                        step = .photo
                        errorMessage = nil
                    }
                } label: {
                    Text(Lang.s("scanner_scan_again"))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func primaryButton(_ title: String, icon: String, gradient: LinearGradient, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(gradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func handlePickerItem(_ item: PhotosPickerItem?, for slot: PhotoSlot) {
        guard let item else { return }
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { return }
            switch slot {
            case .front:
                frontImage = image
                frontPickerItem = nil
            case .nutrition:
                nutritionImage = image
                nutritionPickerItem = nil
            }
        }
    }

    private func runDualPhotoAnalysis() async {
        withAnimation(.spring(response: 0.4)) {
            step = .analyzing
            errorMessage = nil
            scannedBarcode = nil
        }

        let frontBase64 = frontImage.flatMap { AIService.compressImageSmall($0) }
        let nutritionBase64 = nutritionImage.flatMap { AIService.compressImageSmall($0) }

        guard frontBase64 != nil || nutritionBase64 != nil else {
            errorMessage = Lang.s("scanner_err_no_images")
            withAnimation(.spring(response: 0.4)) { step = .photo }
            return
        }

        do {
            let product = try await AIService.analyzePantryProduct(frontBase64: frontBase64, nutritionBase64: nutritionBase64)
            if product.calories == 0 && product.protein == 0 && product.carbs == 0 && product.fat == 0 && product.productName == "Scanned Product" {
                errorMessage = Lang.s("scanner_err_no_values")
                withAnimation(.spring(response: 0.4)) { step = .photo }
            } else {
                populateResult(product)
            }
        } catch {
            let msg: String
            if let aiErr = error as? AIServiceError {
                switch aiErr {
                case .networkError:
                    msg = Lang.s("scanner_err_failed")
                case .decodingError:
                    msg = Lang.s("scanner_err_decode")
                case .noContent:
                    msg = Lang.s("scanner_err_no_content")
                case .invalidURL:
                    msg = Lang.s("scanner_err_not_configured")
                }
            } else {
                msg = Lang.s("scanner_err_failed")
            }
            errorMessage = msg
            withAnimation(.spring(response: 0.4)) { step = .photo }
        }
    }

    private func runBarcodeAnalysis(_ code: String) async {
        withAnimation(.spring(response: 0.4)) {
            step = .analyzing
            errorMessage = nil
            analyzingBarcode = true
        }

        do {
            let product = try await AIService.lookupBarcode(code)
            if product.calories == 0 && product.protein == 0 && product.carbs == 0 && product.fat == 0 {
                populateResult(product)
                errorMessage = Lang.s("scanner_err_barcode_no_nutri")
            } else {
                populateResult(product)
            }
        } catch {
            errorMessage = Lang.s("scanner_err_barcode_not_found").replacingOccurrences(of: "%@", with: code)
            withAnimation(.spring(response: 0.4)) {
                step = .photo
                scannedBarcode = nil
            }
        }
        analyzingBarcode = false
    }

    private func populateResult(_ product: PantryProductResult) {
        result = product
        editName = product.productName
        editBrand = product.brand
        editCategory = ShoppingListItem.allCategories.contains(product.category) ? product.category : "Condiments and Spices"
        editCalories = "\(product.calories)"
        editProtein = formatted(product.protein)
        editCarbs = formatted(product.carbs)
        editFat = formatted(product.fat)
        editServing = product.servingSize.isEmpty ? "100g" : product.servingSize
        withAnimation(.spring(response: 0.4)) {
            step = .result
        }
    }

    private func saveProduct() {
        let item = PantryItem(
            name: editName.trimmingCharacters(in: .whitespaces),
            brand: editBrand.trimmingCharacters(in: .whitespaces).isEmpty ? nil : editBrand.trimmingCharacters(in: .whitespaces),
            calories: Int(editCalories) ?? 0,
            protein: Double(editProtein.replacingOccurrences(of: ",", with: ".")) ?? 0,
            carbs: Double(editCarbs.replacingOccurrences(of: ",", with: ".")) ?? 0,
            fat: Double(editFat.replacingOccurrences(of: ",", with: ".")) ?? 0,
            unit: editServing.isEmpty ? "per 100g" : "per \(editServing)",
            category: editCategory
        )
        appVM.addPantryItem(item)
        dismiss()
    }

    private func formatted(_ value: Double) -> String {
        value == value.rounded() ? "\(Int(value))" : String(format: "%.1f", value)
    }


}
