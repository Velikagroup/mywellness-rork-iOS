import SwiftUI
import AVFoundation

nonisolated final class BodyScanCameraSession: NSObject, @unchecked Sendable {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var currentPosition: AVCaptureDevice.Position = .back
    private var photoCompletion: ((UIImage?) -> Void)?

    private let sessionQueue = DispatchQueue(label: "com.bodyscan.session", qos: .userInitiated)

    func setup(position: AVCaptureDevice.Position = .back) {
        currentPosition = position
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            self.session.inputs.forEach { self.session.removeInput($0) }

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else {
                self.session.commitConfiguration()
                return
            }
            self.session.addInput(input)
            if self.session.outputs.isEmpty, self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            }
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }

    func switchCamera(to position: AVCaptureDevice.Position) {
        guard position != currentPosition else { return }
        currentPosition = position
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.session.stopRunning()
            self.session.beginConfiguration()
            self.session.inputs.forEach { self.session.removeInput($0) }
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else {
                self.session.commitConfiguration()
                self.session.startRunning()
                return
            }
            self.session.addInput(input)
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }

    func stopRunning() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func capturePhoto(completion: @escaping @Sendable (UIImage?) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self else {
                Task { @MainActor in completion(nil) }
                return
            }
            self.photoCompletion = completion
            let settings = AVCapturePhotoSettings()
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

extension BodyScanCameraSession: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let image: UIImage?
        if let data = photo.fileDataRepresentation() {
            image = UIImage(data: data)
        } else if let pixelBuffer = photo.pixelBuffer {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                image = UIImage(cgImage: cgImage)
            } else {
                image = nil
            }
        } else {
            image = nil
        }
        let cb = photoCompletion
        photoCompletion = nil
        Task { @MainActor in cb?(image) }
    }
}

struct BodyScanCameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}
