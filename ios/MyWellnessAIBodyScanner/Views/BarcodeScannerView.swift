import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    let onBarcodeScanned: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                #if targetEnvironment(simulator)
                cameraUnavailablePlaceholder
                #else
                if AVCaptureDevice.default(for: .video) != nil {
                    BarcodeCameraRepresentable(onBarcodeScanned: { code in
                        onBarcodeScanned(code)
                        dismiss()
                    })
                    .ignoresSafeArea()

                    VStack {
                        Spacer()
                        barcodeScanOverlay
                            .offset(y: -20)
                        Spacer()
                        Text(Lang.s("barcode_point_camera"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.black.opacity(0.5))
                            .clipShape(Capsule())
                            .padding(.bottom, 60)
                    }
                } else {
                    cameraUnavailablePlaceholder
                }
                #endif
            }
            .navigationTitle(Lang.s("barcode_scanner_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var barcodeScanOverlay: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(.white.opacity(0.8), lineWidth: 2)
            .frame(width: 280, height: 114)
            .overlay {
                Rectangle()
                    .fill(.red.opacity(0.5))
                    .frame(height: 2)
            }
            .offset(y: -50)
    }

    private var cameraUnavailablePlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(Lang.s("barcode_scanner_placeholder"))
                .font(.title2)
                .fontWeight(.semibold)
            Text(Lang.s("barcode_install_msg"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct BarcodeCameraRepresentable: UIViewControllerRepresentable {
    let onBarcodeScanned: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onBarcodeScanned: onBarcodeScanned)
    }

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let vc = BarcodeScannerViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {}

    class Coordinator: NSObject, BarcodeScannerDelegate {
        let onBarcodeScanned: (String) -> Void
        private var hasScanned = false

        init(onBarcodeScanned: @escaping (String) -> Void) {
            self.onBarcodeScanned = onBarcodeScanned
        }

        func didScanBarcode(_ code: String) {
            guard !hasScanned else { return }
            hasScanned = true
            Task { @MainActor in
                self.onBarcodeScanned(code)
            }
        }
    }
}

protocol BarcodeScannerDelegate: AnyObject {
    func didScanBarcode(_ code: String)
}

class BarcodeScannerViewController: UIViewController {
    weak var delegate: BarcodeScannerDelegate?
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        captureSession.addInput(input)

        let output = AVCaptureMetadataOutput()
        captureSession.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.ean8, .ean13, .upce, .code128, .code39, .code93, .itf14]

        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.addSublayer(preview)
        previewLayer = preview

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
    }
}

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = metadataObject.stringValue else { return }
        Task { @MainActor in
            HapticHelper.vibrate()
            self.delegate?.didScanBarcode(code)
        }
    }
}
