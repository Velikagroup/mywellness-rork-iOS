import UIKit
import AVFoundation

nonisolated final class SilentCameraCapture: NSObject, @unchecked Sendable {
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var completion: ((UIImage?) -> Void)?
    private var cameraPosition: AVCaptureDevice.Position = .back

    func capture(position: AVCaptureDevice.Position = .back, completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        self.cameraPosition = position

        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            startCapture()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted { self?.startCapture() } else { completion(nil) }
            }
        default:
            completion(nil)
        }
    }

    private func startCapture() {
        session.sessionPreset = .photo
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            completion?(nil)
            return
        }
        session.addInput(input)
        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                guard let self else { return }
                let settings = AVCapturePhotoSettings()
                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
    }
}

extension SilentCameraCapture: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        session.stopRunning()
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            Task { @MainActor [weak self] in self?.completion?(nil) }
            return
        }
        Task { @MainActor [weak self] in self?.completion?(image) }
    }
}
