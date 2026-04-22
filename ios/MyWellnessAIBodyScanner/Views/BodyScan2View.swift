import SwiftUI
import AVFoundation

enum FullScanPhase: Int, CaseIterable, Identifiable {
    var id: Int { rawValue }
    case front, rightSide, back, leftSide

    var label: String {
        switch self {
        case .front: return Lang.s("front")
        case .rightSide: return Lang.s("right")
        case .back: return Lang.s("back")
        case .leftSide: return Lang.s("left")
        }
    }

    var instruction: String {
        switch self {
        case .front: return Lang.s("scan_front_instruction")
        case .rightSide: return Lang.s("scan_right_instruction")
        case .back: return Lang.s("scan_back_instruction")
        case .leftSide: return Lang.s("scan_left_instruction")
        }
    }

    var icon: String {
        switch self {
        case .front: return "figure.stand"
        case .rightSide: return "figure.walk"
        case .back: return "figure.stand.dress"
        case .leftSide: return "figure.walk.departure"
        }
    }

    var next: FullScanPhase? {
        FullScanPhase(rawValue: rawValue + 1)
    }

    var startSegment: Int {
        switch self {
        case .front: return 0
        case .rightSide: return 3
        case .back: return 6
        case .leftSide: return 9
        }
    }

    var segmentCount: Int { 3 }
}

struct BodyScan2View: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    @State private var photos: [FullScanPhase: UIImage] = [:]
    @State private var completedPhases: Set<FullScanPhase> = []
    @State private var currentPhase: FullScanPhase = .front
    @State private var isScanning: Bool = false
    @State private var isAnalyzing: Bool = false
    @State private var scanResult: BodyScan2Result?
    @State private var showResult: Bool = false
    @State private var cameraSession = BodyScanCameraSession()
    @State private var scanTask: Task<Void, Never>?
    @State private var pulseAnimation: Bool = false
    @State private var showHistory: Bool = false

    @State private var completedSegments: Set<Int> = []
    @State private var activeSegment: Int = -1
    @State private var scanPulse: Bool = false
    @State private var ringRotation: Double = 0
    @State private var phaseProgress: CGFloat = 0

    private let totalSegments: Int = 12
    private let accentGreen = Color(red: 0.2, green: 0.78, blue: 0.45)
    private let scanTeal = Color(red: 0.0, green: 0.75, blue: 0.7)
    private let segmentGap: Double = 2.5

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isAnalyzing {
                analyzingView
                    .transition(.opacity)
            } else {
                scanContent
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.3), value: isAnalyzing)
        .onAppear { setupCamera() }
        .onDisappear {
            cameraSession.stopRunning()
            scanTask?.cancel()
        }
        .sheet(isPresented: $showHistory) {
            BodyScanHistoryView()
                .environment(appVM)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .fullScreenCover(isPresented: $showResult) {
            if let result = scanResult {
                BodyScan2ResultView(result: result, photos: photos) {
                    showResult = false
                    dismiss()
                }
                .environment(appVM)
            }
        }
    }

    private var scanContent: some View {
        VStack(spacing: 0) {
            topBar

            ZStack {
                cameraSection

                scanRingOverlay
                    .allowsHitTesting(false)

                if showCountdown {
                    Text("\(countdownValue)")
                        .font(.system(size: 100, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 10)
                        .transition(.scale.combined(with: .opacity))
                        .id(countdownValue)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: countdownValue)
                }
            }
            .padding(.top, 12)

            instructionSection

            bottomSection
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
            Image("MyWellnessAIBodyScannerLogo")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(height: 31.92)
                .foregroundStyle(.white)
            Spacer()
            Button { showHistory = true } label: {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 4)
    }

    private var cameraSection: some View {
        ZStack {
            #if targetEnvironment(simulator)
            RoundedRectangle(cornerRadius: 28)
                .fill(.black.opacity(0.6))
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.3))
                        Text(Lang.s("front_camera"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
            #else
            BodyScanCameraPreviewView(session: cameraSession.session)
                .clipShape(RoundedRectangle(cornerRadius: 28))
            #endif

            WireframeBodyOverlay()
                .padding(.horizontal, 60)
                .padding(.vertical, 40)
                .allowsHitTesting(false)

            RoundedRectangle(cornerRadius: 28)
                .stroke(isScanning ? scanTeal.opacity(0.4) : .white.opacity(0.1), lineWidth: isScanning ? 2 : 1)

            if isScanning {
                scanOverlayCorners
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private let ovalTickCount: Int = 60

    private var scanRingOverlay: some View {
        ZStack {
            faceIDStyleOvalRing

            if isScanning {
                bodyDirectionIndicator
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var faceIDStyleOvalRing: some View {
        GeometryReader { geo in
            let frameW = geo.size.width
            let frameH = geo.size.height
            Canvas { context, size in
                let centerX = size.width / 2
                let centerY = (size.height - 20) / 2
                let radiusX = (size.width - 48) / 2
                let radiusY = (size.height - 60) / 2

                let completedTickCount = Int(CGFloat(ovalTickCount) * CGFloat(completedSegments.count) / CGFloat(totalSegments))
                let activeTickIndex: Int = {
                    if activeSegment >= 0 {
                        let progress = CGFloat(activeSegment) / CGFloat(totalSegments)
                        return Int(progress * CGFloat(ovalTickCount))
                    }
                    return -1
                }()

                for i in 0..<ovalTickCount {
                    let angle = (CGFloat(i) / CGFloat(ovalTickCount)) * 2 * .pi - .pi / 2

                    let px = centerX + radiusX * Darwin.cos(angle)
                    let py = centerY + radiusY * Darwin.sin(angle)

                    let nx = Darwin.cos(angle) / radiusX
                    let ny = Darwin.sin(angle) / radiusY
                    let nLen = Darwin.sqrt(nx * nx + ny * ny)
                    let normX = nx / nLen
                    let normY = ny / nLen

                    let innerOffset: CGFloat = 0.0
                    let outerOffset: CGFloat = 12.0

                    let x1 = px + normX * innerOffset
                    let y1 = py + normY * innerOffset
                    let x2 = px + normX * outerOffset
                    let y2 = py + normY * outerOffset

                    var path = Path()
                    path.move(to: CGPoint(x: x1, y: y1))
                    path.addLine(to: CGPoint(x: x2, y: y2))

                    let isCompleted = i < completedTickCount
                    let isActive = i == activeTickIndex

                    let color: Color
                    let width: CGFloat
                    if isCompleted {
                        color = accentGreen
                        width = 3.5
                    } else if isActive {
                        color = scanTeal
                        width = 3.0
                    } else {
                        color = .white.opacity(0.2)
                        width = 2.0
                    }

                    context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round))

                    if isCompleted {
                        context.stroke(path, with: .color(accentGreen.opacity(0.4)), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    }
                }
            }
            .frame(width: frameW, height: frameH)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .animation(.easeInOut(duration: 0.3), value: completedSegments)
        .animation(.easeInOut(duration: 0.2), value: activeSegment)
    }

    private var circularSegmentRing: some View {
        ZStack {
            ForEach(0..<totalSegments, id: \.self) { index in
                segmentArc(index: index)
            }

            if isScanning {
                Circle()
                    .stroke(scanTeal.opacity(scanPulse ? 0.0 : 0.3), lineWidth: 2)
                    .frame(width: 260 + (scanPulse ? 30 : 0), height: 260 + (scanPulse ? 30 : 0))
                    .animation(.easeOut(duration: 1.2).repeatForever(autoreverses: false), value: scanPulse)
            }
        }
    }

    private func segmentArc(index: Int) -> some View {
        let segmentAngle = 360.0 / Double(totalSegments)
        let gapAngle = segmentGap
        let startAngle = Double(index) * segmentAngle + gapAngle / 2 - 90
        let endAngle = startAngle + segmentAngle - gapAngle

        let isCompleted = completedSegments.contains(index)
        let isActive = activeSegment == index

        return Path { path in
            path.addArc(
                center: CGPoint(x: 130, y: 130),
                radius: 125,
                startAngle: .degrees(startAngle),
                endAngle: .degrees(endAngle),
                clockwise: false
            )
        }
        .stroke(
            isCompleted ? accentGreen : (isActive ? scanTeal : .white.opacity(0.12)),
            style: StrokeStyle(lineWidth: isCompleted ? 6 : (isActive ? 5 : 3.5), lineCap: .round)
        )
        .shadow(color: isCompleted ? accentGreen.opacity(0.5) : .clear, radius: isCompleted ? 6 : 0)
        .animation(.easeInOut(duration: 0.35), value: isCompleted)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }

    private var bodyDirectionIndicator: some View {
        VStack(spacing: 6) {
            Image(systemName: currentPhase.icon)
                .font(.system(size: 36, weight: .ultraLight))
                .foregroundStyle(scanTeal)
                .id(currentPhase.rawValue)
                .transition(.scale.combined(with: .opacity))

            Text(currentPhase.label.uppercased())
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(2)
                .foregroundStyle(scanTeal.opacity(0.8))
                .id("label-\(currentPhase.rawValue)")
                .transition(.opacity)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPhase)
    }

    private var scanOverlayCorners: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let len: CGFloat = 40
            let thick: CGFloat = 3.5
            let r: CGFloat = 28

            ZStack {
                scan2CornerPath(origin: CGPoint(x: 0, y: 0), hDir: 1, vDir: 1, len: len, radius: r, thick: thick)
                scan2CornerPath(origin: CGPoint(x: w, y: 0), hDir: -1, vDir: 1, len: len, radius: r, thick: thick)
                scan2CornerPath(origin: CGPoint(x: 0, y: h), hDir: 1, vDir: -1, len: len, radius: r, thick: thick)
                scan2CornerPath(origin: CGPoint(x: w, y: h), hDir: -1, vDir: -1, len: len, radius: r, thick: thick)
            }
        }
        .allowsHitTesting(false)
    }

    private func scan2CornerPath(origin: CGPoint, hDir: CGFloat, vDir: CGFloat, len: CGFloat, radius: CGFloat, thick: CGFloat) -> some View {
        Path { p in
            p.move(to: CGPoint(x: origin.x + hDir * len, y: origin.y))
            p.addLine(to: CGPoint(x: origin.x + hDir * radius, y: origin.y))
            p.addQuadCurve(
                to: CGPoint(x: origin.x, y: origin.y + vDir * radius),
                control: origin
            )
            p.addLine(to: CGPoint(x: origin.x, y: origin.y + vDir * len))
        }
        .stroke(scanTeal, lineWidth: thick)
    }

    private var instructionSection: some View {
        VStack(spacing: 10) {
            if isScanning {
                HStack(spacing: 8) {
                    Circle()
                        .fill(scanTeal)
                        .frame(width: 8, height: 8)
                        .opacity(scanPulse ? 0.3 : 1)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: scanPulse)

                    Text(Lang.s("scanning_in_progress"))
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(scanTeal)
                }

                Text(currentPhase.instruction)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .id(currentPhase.rawValue)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

                progressLabel
            } else if completedPhases.count == FullScanPhase.allCases.count {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(accentGreen)

                Text(Lang.s("scan_complete"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(accentGreen)
            } else {
                Text(Lang.s("position_body"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)

                Text("\(completedSegments.count)/\(totalSegments) \(Lang.s("segments"))")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
        .padding(.horizontal, 32)
        .animation(.easeInOut(duration: 0.3), value: currentPhase)
    }

    private var progressLabel: some View {
        HStack(spacing: 12) {
            ForEach(FullScanPhase.allCases) { phase in
                HStack(spacing: 4) {
                    Image(systemName: completedPhases.contains(phase) ? "checkmark.circle.fill" : (currentPhase == phase ? "circle.dotted" : "circle"))
                        .font(.system(size: 12))
                        .foregroundStyle(completedPhases.contains(phase) ? accentGreen : (currentPhase == phase ? scanTeal : .white.opacity(0.25)))

                    Text(phase.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(completedPhases.contains(phase) ? accentGreen : (currentPhase == phase ? .white : .white.opacity(0.3)))
                }
            }
        }
        .padding(.top, 4)
    }

    private var bottomSection: some View {
        VStack(spacing: 16) {
            if !isScanning && completedPhases.count == FullScanPhase.allCases.count {
                Button {
                    analyzeAllPhotos()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                        Text(Lang.s("analyze_body"))
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(accentGreen)
                    .clipShape(.rect(cornerRadius: 16))
                }
                .padding(.horizontal, 28)
            } else if !isScanning {
                Button {
                    startScan()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "viewfinder.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text(completedPhases.isEmpty ? Lang.s("start_scan") : Lang.s("resume_scan"))
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(scanTeal)
                    .clipShape(.rect(cornerRadius: 16))
                }
                .padding(.horizontal, 28)

                if !completedPhases.isEmpty {
                    Button {
                        completedPhases.removeAll()
                        completedSegments.removeAll()
                        photos.removeAll()
                        currentPhase = .front
                        activeSegment = -1
                    } label: {
                        Text(Lang.s("restart"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            } else {
                Text(Lang.s("slowly_rotate"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.35))
                    .padding(.bottom, 8)
            }
        }
        .padding(.bottom, 50)
        .padding(.top, 12)
    }

    private var analyzingView: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(scanTeal.opacity(0.15), lineWidth: 4)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(scanTeal, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(pulseAnimation ? 360 : 0))
                    .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: pulseAnimation)

                VStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 28))
                        .foregroundStyle(scanTeal)
                    Text("AI")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(scanTeal)
                }
            }

            VStack(spacing: 12) {
                Text(Lang.s("analyzing"))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                Text(Lang.s("analyzing_body_desc"))
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                analyzeStep(Lang.s("body_composition_analysis"))
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding(.horizontal, 32)
        .onAppear { pulseAnimation = true }
    }

    private func analyzeStep(_ text: String) -> some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(scanTeal)
                .scaleEffect(0.8)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
        }
    }

    private func setupCamera() {
        #if !targetEnvironment(simulator)
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized {
            cameraSession.setup(position: .front)
        } else if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    Task { @MainActor in
                        cameraSession.setup(position: .front)
                    }
                }
            }
        }
        #endif
    }

    @State private var countdownValue: Int = 0
    @State private var showCountdown: Bool = false

    private func startScan() {
        let startPhase = FullScanPhase.allCases.first(where: { !completedPhases.contains($0) }) ?? .front
        currentPhase = startPhase
        showCountdown = true
        countdownValue = 3

        scanTask = Task {
            for i in (1...3).reversed() {
                countdownValue = i
                HapticHelper.impact(style: .medium)
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
            }
            showCountdown = false
            isScanning = true
            scanPulse = true
            await runContinuousScan(from: startPhase)
        }
    }

    private func runContinuousScan(from startPhase: FullScanPhase) async {
        var phase: FullScanPhase? = startPhase

        while let current = phase, !Task.isCancelled {
            if completedPhases.contains(current) {
                phase = current.next
                continue
            }

            currentPhase = current
            HapticHelper.impact(style: .medium)

            let start = current.startSegment
            let count = current.segmentCount

            for i in 0..<count {
                guard !Task.isCancelled else { return }

                let segIndex = start + i
                activeSegment = segIndex

                HapticHelper.impact(style: .light)

                try? await Task.sleep(for: .milliseconds(800))

                guard !Task.isCancelled else { return }

                _ = withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    completedSegments.insert(segIndex)
                }

                HapticHelper.impact(style: .rigid)

                try? await Task.sleep(for: .milliseconds(200))
            }

            guard !Task.isCancelled else { return }

            activeSegment = -1
            await capturePhoto(for: current)

            HapticHelper.notification(.success)
            _ = withAnimation(.spring(response: 0.4)) {
                completedPhases.insert(current)
            }

            try? await Task.sleep(for: .milliseconds(400))

            phase = current.next
        }

        isScanning = false
        scanPulse = false

        if completedPhases.count == FullScanPhase.allCases.count {
            HapticHelper.notification(.success)
            try? await Task.sleep(for: .milliseconds(600))
            analyzeAllPhotos()
        }
    }

    private func capturePhoto(for phase: FullScanPhase) async {
        #if targetEnvironment(simulator)
        let placeholder = UIImage(systemName: "person.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        photos[phase] = placeholder
        #else
        await withCheckedContinuation { continuation in
            cameraSession.capturePhoto { image in
                if let image {
                    photos[phase] = image
                }
                continuation.resume()
            }
        }
        #endif
    }

    private func analyzeAllPhotos() {
        isAnalyzing = true
        pulseAnimation = false
        cameraSession.stopRunning()

        let capturedPhotos = photos
        let profile = appVM.userProfile

        Task.detached(priority: .userInitiated) {
            let frontB64: String? = autoreleasepool {
                capturedPhotos[.front].flatMap { AIService.compressImageForAI($0, maxDimension: 768, quality: 0.5) }
            }
            let rightB64: String? = autoreleasepool {
                capturedPhotos[.rightSide].flatMap { AIService.compressImageForAI($0, maxDimension: 768, quality: 0.5) }
            }
            let backB64: String? = autoreleasepool {
                capturedPhotos[.back].flatMap { AIService.compressImageForAI($0, maxDimension: 768, quality: 0.5) }
            }
            let leftB64: String? = autoreleasepool {
                capturedPhotos[.leftSide].flatMap { AIService.compressImageForAI($0, maxDimension: 768, quality: 0.5) }
            }

            let finalResult: BodyScan2Result
            do {
                finalResult = try await AIService.analyzeFullBodyScan(
                    frontBase64: frontB64,
                    rightBase64: rightB64,
                    backBase64: backB64,
                    leftBase64: leftB64,
                    profile: profile
                )
            } catch {
                finalResult = BodyScan2Result.fallback()
            }

            let resultToUse = finalResult
            await MainActor.run {
                scanResult = resultToUse
                appVM.addBodyScanRecord(resultToUse)
                appVM.generatePlanFromBodyScanSafe()
                isAnalyzing = false
                showResult = true
            }
        }
    }
}
