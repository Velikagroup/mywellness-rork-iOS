import SwiftUI
import AVFoundation
import PhotosUI

enum CameraMode: Int, CaseIterable {
    case calories, nutrition, weight, scan360

    var label: String {
        switch self {
        case .calories: return Lang.s("calories_mode")
        case .nutrition: return Lang.s("nutrition_mode")
        case .weight: return Lang.s("weight_mode")
        case .scan360: return Lang.s("body_scan_mode")
        }
    }

    var icon: String {
        switch self {
        case .calories: return "fork.knife"
        case .nutrition: return "fork.knife.circle"
        case .weight: return "scalemass"
        case .scan360: return "figure.walk.motion"
        }
    }

    var instruction: String {
        switch self {
        case .calories: return Lang.s("center_food_frame")
        case .nutrition: return ""
        case .weight: return ""
        case .scan360: return ""
        }
    }

    var usesCamera: Bool {
        switch self {
        case .calories: return true
        case .nutrition, .weight, .scan360: return false
        }
    }

    var usesBarcode: Bool {
        switch self {
        case .nutrition: return true
        default: return false
        }
    }
}

struct CameraHubView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    @State private var selectedMode: CameraMode = .calories
    @State private var capturedImage: UIImage? = nil
    @State private var showingResult: Bool = false
    @State private var photoPickerItem: PhotosPickerItem? = nil
    @State private var isProcessing: Bool = false
    @State private var showWeightLog: Bool = false
    @State private var calorieResult: CalorieAnalysisResult? = nil
    @State private var nutritionResult: NutritionTableResult? = nil
    @State private var cameraPermissionGranted: Bool = false
    @State private var cameraAuthChecked: Bool = false
    @State private var showScan360: Bool = false
    @State private var showFoodScanHistory: Bool = false
    @State private var showFoodProductScanHistory: Bool = false
    @State private var cameraCapture: SilentCameraCapture? = nil
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert: Bool = false
    @State private var showBarcodeScanner: Bool = false
    @State private var isLookingUpBarcode: Bool = false

    var body: some View {
        ZStack {
            if selectedMode.usesCamera {
                cameraBackground
            } else if selectedMode.usesBarcode {
                barcodeBackground
            } else {
                Color.black.ignoresSafeArea()
            }

            if selectedMode.usesCamera {
                CameraCutoutOverlay(frameSize: CGSize(width: 320, height: 360), cornerRadius: 24)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.3), value: selectedMode)
            } else if selectedMode.usesBarcode {
                barcodeScanOverlayMask
                    .ignoresSafeArea()
            } else {
                Color.clear.ignoresSafeArea()
            }

            if selectedMode.usesBarcode {
                barcodeOverlayContent
            }

            VStack(spacing: 0) {
                topBar
                Spacer(minLength: 0)
                if selectedMode.usesCamera {
                    cameraOverlayContent
                } else if selectedMode == .weight {
                    weightModeContent
                }
                Spacer(minLength: 0)
                bottomControls
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { checkCameraPermission() }
        .sheet(isPresented: $showWeightLog) {
            WeightLogView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .alert(Lang.s("analysis_error_title"), isPresented: $showErrorAlert) {
            Button(Lang.s("retry")) {
                if let img = capturedImage {
                    processImage(img)
                }
            }
            Button(Lang.s("cancel"), role: .cancel) {}
        } message: {
            Text(errorMessage ?? Lang.s("analysis_failed"))
        }
        .fullScreenCover(isPresented: $showingResult) {
            if selectedMode == .calories, let result = calorieResult {
                CalorieAnalysisResultView(result: result, image: capturedImage)
            } else if selectedMode == .nutrition, let result = nutritionResult {
                NutritionAnalysisResultView(result: result, image: capturedImage)
            }
        }
        .fullScreenCover(isPresented: $showScan360) {
            BodyScan2View()
                .environment(appVM)
        }
        .sheet(isPresented: $showFoodScanHistory) {
            FoodScanHistoryView()
                .environment(appVM)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
        }
        .sheet(isPresented: $showFoodProductScanHistory) {
            FoodProductScanHistoryView()
                .environment(appVM)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
        }
        .sheet(isPresented: $showBarcodeScanner) {
            BarcodeScannerView { barcode in
                showBarcodeScanner = false
                handleBarcodeScanned(barcode)
            }
        }
    }

    @ViewBuilder
    private var cameraBackground: some View {
        #if targetEnvironment(simulator)
        Color.black.ignoresSafeArea()
        #else
        if cameraPermissionGranted {
            FullScreenCameraPreview()
                .ignoresSafeArea()
        } else {
            Color.black.ignoresSafeArea()
        }
        #endif
    }

    @ViewBuilder
    private var barcodeBackground: some View {
        #if targetEnvironment(simulator)
        Color.black.ignoresSafeArea()
        #else
        if cameraPermissionGranted {
            BarcodeCameraRepresentable { code in
                handleBarcodeScanned(code)
            }
            .ignoresSafeArea()
        } else {
            Color.black.ignoresSafeArea()
        }
        #endif
    }

    private var barcodeScanOverlayMask: some View {
        GeometryReader { geo in
            let frameW: CGFloat = 280
            let frameH: CGFloat = 137
            let cutoutRect = CGRect(
                x: (geo.size.width - frameW) / 2,
                y: (geo.size.height - 140) / 2 + 5,
                width: frameW,
                height: frameH
            )
            Canvas { context, size in
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(.black.opacity(0.65))
                )
                context.blendMode = .destinationOut
                context.fill(
                    Path(roundedRect: cutoutRect, cornerRadius: 16),
                    with: .color(.white)
                )
            }
            .compositingGroup()
        }
    }

    private var barcodeOverlayContent: some View {
        GeometryReader { geo in
            let frameW: CGFloat = 280
            let frameH: CGFloat = 140
            let centerX = geo.size.width / 2
            let centerY = geo.size.height / 2

            VStack(spacing: 16) {
                if isLookingUpBarcode {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.2)
                        Text(Lang.s("looking_up_product"))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: frameW, height: frameH)
                    .background(.black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(.white.opacity(0.8), lineWidth: 2)
                        .frame(width: frameW, height: frameH)
                        .overlay {
                            Rectangle()
                                .fill(.red.opacity(0.6))
                                .frame(height: 2)
                        }
                }

                Text(Lang.s("barcode_point_camera"))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.black.opacity(0.4))
                    .clipShape(Capsule())
            }
            .position(x: centerX, y: centerY + 30)
        }
        .ignoresSafeArea()
    }

    private var cameraOverlayContent: some View {
        VStack(spacing: 20) {
            if !selectedMode.instruction.isEmpty {
                Text(selectedMode.instruction)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.black.opacity(0.35))
                    .clipShape(Capsule())
            }
            scanFrameOverlay
        }
    }

    private var scanFrameOverlay: some View {
        ZStack {
            scanCorners
        }
        .frame(width: selectedMode == .nutrition ? 240 : 320, height: selectedMode == .nutrition ? 400 : 360)
    }

    private var scanCorners: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let len: CGFloat = 32
            let thick: CGFloat = 3.0
            let r: CGFloat = selectedMode == .nutrition ? 18 : 24
            let topAdj: CGFloat = 5
            let bottomAdj: CGFloat = 2
            let leftInset: CGFloat = 2
            let rightInset: CGFloat = 2
            ZStack {
                roundedCornerPath(origin: CGPoint(x: leftInset, y: topAdj), hDir: 1, vDir: 1, len: len, radius: r, thick: thick)
                roundedCornerPath(origin: CGPoint(x: w - rightInset, y: topAdj), hDir: -1, vDir: 1, len: len, radius: r, thick: thick)
                roundedCornerPath(origin: CGPoint(x: leftInset, y: h + bottomAdj), hDir: 1, vDir: -1, len: len, radius: r, thick: thick)
                roundedCornerPath(origin: CGPoint(x: w - rightInset, y: h + bottomAdj), hDir: -1, vDir: -1, len: len, radius: r, thick: thick)
            }
        }
    }

    private func roundedCornerPath(origin: CGPoint, hDir: CGFloat, vDir: CGFloat, len: CGFloat, radius: CGFloat, thick: CGFloat) -> some View {
        Path { p in
            p.move(to: CGPoint(x: origin.x + hDir * len, y: origin.y))
            p.addLine(to: CGPoint(x: origin.x + hDir * radius, y: origin.y))
            p.addQuadCurve(
                to: CGPoint(x: origin.x, y: origin.y + vDir * radius),
                control: origin
            )
            p.addLine(to: CGPoint(x: origin.x, y: origin.y + vDir * len))
        }
        .stroke(.white, lineWidth: thick)
    }

    private var weightModeContent: some View {
        VStack(spacing: 24) {
            Image(systemName: "scalemass.fill")
                .font(.system(size: 64))
                .foregroundStyle(.white.opacity(0.6))
            Text(Lang.s("log_your_weight"))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }

            Spacer()

            Image("MyWellnessLogo")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(height: 31.92)
                .foregroundStyle(.white)

            Spacer()

            if selectedMode == .calories || selectedMode == .nutrition {
                Button {
                    if selectedMode == .calories {
                        showFoodScanHistory = true
                    } else {
                        showFoodProductScanHistory = true
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var bottomControls: some View {
        VStack(spacing: 20) {
            modeSelector
            HStack(alignment: .center) {
                if selectedMode.usesCamera {
                    Color.clear.frame(width: 48, height: 48)
                } else if selectedMode.usesBarcode {
                    Color.clear.frame(width: 48, height: 48)
                } else {
                    Color.clear.frame(width: 48, height: 48)
                }
                Spacer()
                if selectedMode.usesCamera {
                    shutterButton
                } else if selectedMode.usesBarcode {
                    Color.clear.frame(width: 76, height: 76)
                } else if selectedMode == .weight {
                    Button { showWeightLog = true } label: {
                        ZStack {
                            Circle().fill(.white).frame(width: 76, height: 76)
                            Image(systemName: "plus").font(.system(size: 28, weight: .semibold)).foregroundStyle(.black)
                        }
                    }
                } else {
                    Color.clear.frame(width: 76, height: 76)
                }
                Spacer()
                if selectedMode.usesCamera {
                    PhotosPicker(selection: $photoPickerItem, matching: .images) {
                        ZStack {
                            Circle().fill(.black.opacity(0.45)).frame(width: 48, height: 48)
                            Image(systemName: "photo.on.rectangle").font(.system(size: 20)).foregroundStyle(.white)
                        }
                    }
                    .onChange(of: photoPickerItem) { _, newItem in handlePhotoPicker(newItem) }
                } else if selectedMode.usesBarcode {
                    PhotosPicker(selection: $photoPickerItem, matching: .images) {
                        ZStack {
                            Circle().fill(.black.opacity(0.45)).frame(width: 48, height: 48)
                            Image(systemName: "photo.on.rectangle").font(.system(size: 20)).foregroundStyle(.white)
                        }
                    }
                    .onChange(of: photoPickerItem) { _, newItem in handlePhotoPicker(newItem) }
                } else {
                    Color.clear.frame(width: 48, height: 48)
                }
            }
            .padding(.horizontal, 32)
        }
        .padding(.bottom, 40)
    }

    private var shutterButton: some View {
        Button {
            handleShutter()
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(.white, lineWidth: 3)
                    .frame(width: 76, height: 76)
                Circle()
                    .fill(.white)
                    .frame(width: 62, height: 62)
                if isProcessing {
                    ProgressView()
                        .tint(.black)
                }
            }
        }
        .disabled(isProcessing)
    }

    private var modeSelector: some View {
        HStack(spacing: 8) {
            ForEach(CameraMode.allCases, id: \.rawValue) { mode in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedMode = mode
                    }
                    if mode == .weight {
                        showWeightLog = true
                    }
                    if mode == .scan360 {
                        showScan360 = true
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 19))
                        Text(mode.label)
                            .font(.system(size: 10, weight: .medium))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(selectedMode == mode ? .white : .white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(selectedMode == mode ? .white.opacity(0.22) : .black.opacity(0.35))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(selectedMode == mode ? .white.opacity(0.5) : .clear, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }

    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            cameraPermissionGranted = true
            cameraAuthChecked = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    cameraPermissionGranted = granted
                    cameraAuthChecked = true
                }
            }
        default:
            cameraPermissionGranted = false
            cameraAuthChecked = true
        }
    }

    private func handleShutter() {
        if selectedMode == .weight {
            showWeightLog = true
            return
        }
        guard !isProcessing else { return }
        #if targetEnvironment(simulator)
        processImage(createMockImage())
        #else
        isProcessing = true
        let capture = SilentCameraCapture()
        cameraCapture = capture
        capture.capture(position: .back) { image in
            cameraCapture = nil
            guard let image else {
                isProcessing = false
                return
            }
            processImage(image)
        }
        #endif
    }

    private func handlePhotoPicker(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { return }
            processImage(image)
        }
    }

    private func processImage(_ image: UIImage) {
        guard selectedMode == .calories || selectedMode == .nutrition else { return }
        capturedImage = image
        if !isProcessing { isProcessing = true }

        guard let base64 = AIService.compressImageForAI(image) else {
            isProcessing = false
            return
        }

        Task {
            do {
                if selectedMode == .calories {
                    let result = try await AIService.analyzeCalories(imageBase64: base64)
                    calorieResult = result
                    let record = FoodScanRecord(
                        foodName: result.foodName,
                        totalCalories: result.calories,
                        totalProtein: result.protein,
                        totalCarbs: result.carbs,
                        totalFat: result.fat,
                        servingSize: result.servingSize,
                        confidence: result.confidence,
                        notes: result.notes,
                        ingredients: result.ingredients.isEmpty ? [
                            ScannedIngredient(name: result.foodName, quantity: result.servingSize, calories: result.calories, protein: result.protein, carbs: result.carbs, fat: result.fat)
                        ] : result.ingredients,
                        imageData: capturedImage?.jpegData(compressionQuality: 0.5)
                    )
                    appVM.addFoodScanRecord(record)
                } else if selectedMode == .nutrition {
                    let result = try await AIService.analyzeNutritionTable(imageBase64: base64)
                    nutritionResult = result
                    let quality = FoodProductScanRecord.computeQuality(from: result)
                    let record = FoodProductScanRecord(
                        productName: result.productName,
                        servingSize: result.servingSize,
                        calories: result.calories,
                        totalFat: result.totalFat,
                        saturatedFat: result.saturatedFat,
                        carbohydrates: result.carbohydrates,
                        sugars: result.sugars,
                        protein: result.protein,
                        salt: result.salt,
                        fiber: result.fiber,
                        imageData: capturedImage?.jpegData(compressionQuality: 0.5),
                        qualityScore: quality
                    )
                    appVM.addFoodProductScanRecord(record)
                }
                isProcessing = false
                showingResult = true
            } catch {
                isProcessing = false
                if let aiError = error as? AIServiceError {
                    switch aiError {
                    case .networkError(let msg): errorMessage = msg
                    case .noContent: errorMessage = Lang.s("ai_no_response")
                    default: errorMessage = Lang.s("analysis_failed")
                    }
                } else {
                    errorMessage = Lang.s("analysis_failed")
                }
                showErrorAlert = true
            }
        }
    }

    private func createMockImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
        return renderer.image { ctx in
            UIColor.orange.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
        }
    }

    private func handleBarcodeScanned(_ barcode: String) {
        guard !isLookingUpBarcode else { return }
        isLookingUpBarcode = true
        Task {
            do {
                let product = try await AIService.lookupBarcode(barcode)
                if selectedMode == .nutrition {
                    let result = NutritionTableResult(
                        productName: product.brand.isEmpty ? product.productName : "\(product.productName) (\(product.brand))",
                        servingSize: product.servingSize,
                        calories: product.calories,
                        totalFat: product.fat,
                        saturatedFat: product.saturatedFat,
                        carbohydrates: product.carbs,
                        sugars: product.sugars,
                        protein: product.protein,
                        salt: 0,
                        fiber: product.fiber
                    )
                    nutritionResult = result
                    let quality = FoodProductScanRecord.computeQuality(from: result)
                    let record = FoodProductScanRecord(
                        productName: result.productName,
                        servingSize: result.servingSize,
                        calories: result.calories,
                        totalFat: result.totalFat,
                        saturatedFat: result.saturatedFat,
                        carbohydrates: result.carbohydrates,
                        sugars: result.sugars,
                        protein: result.protein,
                        salt: result.salt,
                        fiber: result.fiber,
                        imageData: nil,
                        qualityScore: quality
                    )
                    appVM.addFoodProductScanRecord(record)
                    isLookingUpBarcode = false
                    showingResult = true
                }
            } catch {
                isLookingUpBarcode = false
                errorMessage = Lang.s("barcode_not_found")
                showErrorAlert = true
            }
        }
    }
}

struct CameraCutoutOverlay: View {
    let frameSize: CGSize
    var cornerRadius: CGFloat = 24

    var body: some View {
        GeometryReader { geo in
            let cutoutRect = CGRect(
                x: (geo.size.width - frameSize.width) / 2,
                y: (geo.size.height - frameSize.height) / 2 - 20,
                width: frameSize.width,
                height: frameSize.height
            )
            Canvas { context, size in
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(.black.opacity(0.70))
                )
                context.blendMode = .destinationOut
                context.fill(
                    Path(roundedRect: cutoutRect, cornerRadius: cornerRadius),
                    with: .color(.white)
                )
            }
            .compositingGroup()
        }
    }
}

struct FullScreenCameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> FullScreenCameraView {
        FullScreenCameraView()
    }
    func updateUIView(_ uiView: FullScreenCameraView, context: Context) {}
}

class FullScreenCameraView: UIView {
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCamera()
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        session.addInput(input)
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        layer.addSublayer(preview)
        previewLayer = preview
        captureSession = session
        DispatchQueue.global(qos: .userInitiated).async { session.startRunning() }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

struct CameraCapturePicker: UIViewControllerRepresentable {
    let onCapture: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onCapture: onCapture) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage?) -> Void
        init(onCapture: @escaping (UIImage?) -> Void) { self.onCapture = onCapture }

        nonisolated func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = info[.originalImage] as? UIImage
            Task { @MainActor in self.onCapture(image) }
        }

        nonisolated func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            Task { @MainActor in self.onCapture(nil) }
        }
    }
}
