import SwiftUI
import UIKit

// MARK: - Memoji Capture VC

class MemojiCaptureVC: UIViewController, UITextViewDelegate {
    var onCapture: ((UIImage) -> Void)?
    private let tv = UITextView()
    private var isCapturing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        tv.delegate = self
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.textColor = .clear
        tv.tintColor = .clear
        tv.font = UIFont.systemFont(ofSize: 1)
        tv.autocorrectionType = .no
        tv.spellCheckingType = .no
        tv.allowsEditingTextAttributes = true
        tv.isEditable = true
        tv.isSelectable = true
        tv.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        if #available(iOS 18.0, *) {
            tv.supportsAdaptiveImageGlyph = true
        }
        view.addSubview(tv)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(inputModeDidChange),
            name: UITextInputMode.currentInputModeDidChangeNotification,
            object: nil
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tv.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tv.resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func inputModeDidChange() {
        if !tv.isFirstResponder {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.tv.becomeFirstResponder()
            }
        }
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        false
    }

    func textViewDidChange(_ textView: UITextView) {
        guard !isCapturing else { return }
        let storage = textView.textStorage
        guard storage.length > 0 else { return }
        let range = NSRange(location: 0, length: storage.length)

        if #available(iOS 18.0, *) {
            storage.enumerateAttribute(.adaptiveImageGlyph, in: range, options: []) { [weak self] val, _, stop in
                guard let self, !self.isCapturing else { stop.pointee = true; return }
                guard let glyph = val as? NSAdaptiveImageGlyph else { return }
                if let img = UIImage(data: glyph.imageContent) {
                    self.isCapturing = true
                    stop.pointee = true
                    DispatchQueue.main.async {
                        self.onCapture?(img)
                        textView.attributedText = NSAttributedString()
                        textView.text = ""
                        self.isCapturing = false
                    }
                }
            }
            if isCapturing { return }
        }

        storage.enumerateAttribute(.attachment, in: range, options: []) { [weak self] val, _, stop in
            guard let self, !self.isCapturing else { stop.pointee = true; return }
            guard let att = val as? NSTextAttachment else { return }

            var img: UIImage? = att.image
            if img == nil {
                img = att.image(
                    forBounds: CGRect(x: 0, y: 0, width: 300, height: 300),
                    textContainer: nil,
                    characterIndex: 0
                )
            }
            if img == nil, let wrapper = att.fileWrapper, let data = wrapper.regularFileContents {
                img = UIImage(data: data)
            }

            if let img {
                self.isCapturing = true
                stop.pointee = true
                DispatchQueue.main.async {
                    self.onCapture?(img)
                    textView.attributedText = NSAttributedString()
                    textView.text = ""
                    self.isCapturing = false
                }
            }
        }
    }
}

// MARK: - UIViewControllerRepresentable

struct MemojiCaptureView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void

    func makeUIViewController(context: Context) -> MemojiCaptureVC {
        let vc = MemojiCaptureVC()
        vc.onCapture = onCapture
        return vc
    }
    func updateUIViewController(_ vc: MemojiCaptureVC, context: Context) {}
}

// MARK: - Step Model

private struct MemojiStep {
    let mood: WellnessMood
    let expressionEmoji: String
    let title: String
    let instruction: String
    let color: Color
}

private let memojiSteps: [MemojiStep] = [
    .init(mood: .excellent, expressionEmoji: "😄", title: Lang.s("memoji_super_happy"),
          instruction: Lang.s("memoji_super_happy_inst"),
          color: Color(red: 0.17, green: 0.72, blue: 0.45)),
    .init(mood: .good, expressionEmoji: "🙂", title: Lang.s("memoji_happy"),
          instruction: Lang.s("memoji_happy_inst"),
          color: Color(red: 0.17, green: 0.60, blue: 0.52)),
    .init(mood: .fair, expressionEmoji: "😐", title: Lang.s("memoji_neutral"),
          instruction: Lang.s("memoji_neutral_inst"),
          color: Color.orange),
    .init(mood: .poor, expressionEmoji: "😔", title: Lang.s("memoji_sad"),
          instruction: Lang.s("memoji_sad_inst"),
          color: Color.red),
]

// MARK: - Main Sheet

struct MemojiPickerSheet: View {
    @Binding var isPresented: Bool
    let onCapture: ([String: Data]) -> Void

    @State private var currentStepIndex: Int = 0
    @State private var capturedImages: [String: UIImage] = [:]
    @State private var showSummary: Bool = false
    @State private var flashKey: UUID = UUID()

    private var currentStep: MemojiStep { memojiSteps[currentStepIndex] }
    private var isLastStep: Bool { currentStepIndex == memojiSteps.count - 1 }
    private var currentCaptured: UIImage? { capturedImages[currentStep.mood.storageKey] }

    var body: some View {
        ZStack {
            MemojiCaptureView { img in
                if !showSummary {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        capturedImages[currentStep.mood.storageKey] = img
                        flashKey = UUID()
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: 1)
            .opacity(0.01)
            .allowsHitTesting(true)

            if showSummary {
                summaryView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            } else {
                stepView
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: showSummary)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: currentStepIndex)
    }

    // MARK: Step View

    private var stepView: some View {
        VStack(spacing: 0) {
            progressBar
                .padding(.top, 20)
                .padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 20) {
                    stepHeader
                    capturePreviewArea
                    howToCards
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)

            bottomBar
        }
    }

    // MARK: Progress Bar

    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text(String(format: Lang.s("step_x_of_y"), currentStepIndex + 1, memojiSteps.count))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: Lang.s("captured_count"), capturedImages.count, memojiSteps.count))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(capturedImages.isEmpty ? Color.secondary : Color(red: 0.17, green: 0.72, blue: 0.45))
            }

            HStack(spacing: 4) {
                ForEach(memojiSteps.indices, id: \.self) { idx in
                    let step = memojiSteps[idx]
                    let captured = capturedImages[step.mood.storageKey] != nil
                    let isCurrent = idx == currentStepIndex

                    Capsule()
                        .fill(captured ? step.color : (isCurrent ? step.color.opacity(0.4) : Color(.systemGray5)))
                        .frame(height: 4)
                        .overlay {
                            if isCurrent && !captured {
                                Capsule()
                                    .fill(step.color.opacity(0.7))
                                    .frame(height: 4)
                                    .mask(alignment: .leading) {
                                        Rectangle()
                                            .frame(width: .infinity)
                                    }
                            }
                        }
                        .animation(.spring(response: 0.4), value: captured)
                }
            }
        }
    }

    // MARK: Step Header

    private var stepHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(currentStep.color.opacity(0.12))
                    .frame(width: 100, height: 100)

                if let img = currentCaptured {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 88, height: 88)
                        .clipShape(.circle)
                        .id(flashKey)
                        .transition(.scale(scale: 0.7).combined(with: .opacity))
                } else {
                    Text(currentStep.expressionEmoji)
                        .font(.system(size: 52))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentCaptured != nil)

            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(currentStep.color)
                        .frame(width: 8, height: 8)
                    Text(currentStep.title)
                        .font(.title2.bold())
                }

                Text(currentStep.instruction)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
            .animation(.easeInOut(duration: 0.25), value: currentStepIndex)

            if currentCaptured != nil {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(currentStep.color)
                        .font(.subheadline)
                    Text(Lang.s("memoji_captured"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(currentStep.color)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: Capture Preview Area

    private var capturePreviewArea: some View {
        Group {
            if currentCaptured == nil {
                HStack(spacing: 8) {
                    Image(systemName: "hand.tap.fill")
                        .foregroundStyle(currentStep.color)
                    Text(Lang.s("tap_memoji_below"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(currentStep.color)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(currentStep.color.opacity(0.1))
                .clipShape(.capsule)
            }
        }
    }

    // MARK: How-To Cards

    private var howToCards: some View {
        VStack(spacing: 8) {
            instructionRow(step: "1", icon: "keyboard", text: Lang.s("memoji_step_1"))
            instructionRow(step: "2", icon: "face.smiling", text: Lang.s("memoji_step_2"))
            instructionRow(step: "3", icon: "hand.draw", text: Lang.s("memoji_step_3"))
            instructionRow(step: "4", icon: "hand.tap",
                           text: Lang.s("memoji_step_4").replacingOccurrences(of: "%@", with: currentStep.expressionEmoji))
        }
        .animation(.easeInOut(duration: 0.2), value: currentStepIndex)
    }

    private func instructionRow(step: String, icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(currentStep.color)
                    .frame(width: 28, height: 28)
                Text(step)
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
            }
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(currentStep.color)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    // MARK: Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                Button {
                    advance()
                } label: {
                    Text(currentCaptured == nil ? Lang.s("skip") : "")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(width: currentCaptured == nil ? 60 : 0)
                }
                .opacity(currentCaptured == nil ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: currentCaptured == nil)

                Button {
                    advance()
                } label: {
                    HStack(spacing: 8) {
                        Text(isLastStep ? Lang.s("go_to_summary") : Lang.s("next"))
                            .font(.headline)
                        Image(systemName: isLastStep ? "checkmark" : "arrow.right")
                            .font(.subheadline.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(currentCaptured != nil ? currentStep.color : Color(.systemGray4))
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.3), value: currentCaptured != nil)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    private func advance() {
        if isLastStep {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                showSummary = true
            }
        } else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                currentStepIndex += 1
            }
        }
    }

    // MARK: Summary View

    private var summaryView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    ForEach(memojiSteps, id: \.mood.storageKey) { step in
                        let img = capturedImages[step.mood.storageKey]
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(step.color.opacity(0.12))
                                    .frame(width: 62, height: 62)

                                if let img {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 54, height: 54)
                                        .clipShape(.circle)
                                } else {
                                    Image(systemName: "questionmark")
                                        .font(.title3)
                                        .foregroundStyle(step.color.opacity(0.4))
                                }
                            }
                            .overlay(alignment: .bottomTrailing) {
                                if img != nil {
                                    Circle()
                                        .fill(step.color)
                                        .frame(width: 16, height: 16)
                                        .overlay {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                }
                            }

                            Text(step.expressionEmoji)
                                .font(.caption)
                        }
                    }
                }
                .padding(.top, 32)

                VStack(spacing: 6) {
                    Text(capturedImages.isEmpty ? Lang.s("no_memoji_captured") : capturedImages.count == memojiSteps.count ? Lang.s("all_expressions_captured") : String(format: Lang.s("x_expressions_captured"), capturedImages.count))
                        .font(.title3.bold())
                    Text(Lang.s("auto_expression_desc"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }

            Spacer()

            VStack(spacing: 10) {
                if !capturedImages.isEmpty {
                    Button {
                        let result = capturedImages.compactMapValues { $0.pngData() }
                        onCapture(result)
                        isPresented = false
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text(Lang.s("save_memoji"))
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 0.17, green: 0.72, blue: 0.45))
                        .foregroundStyle(.white)
                        .clipShape(.capsule)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        showSummary = false
                        currentStepIndex = memojiSteps.count - 1
                    }
                } label: {
                    Text(Lang.s("go_back"))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}
