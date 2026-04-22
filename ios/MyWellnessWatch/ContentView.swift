import SwiftUI

struct ContentView: View {
    @State private var session = WatchSessionService.shared

    private var moodColor: Color {
        Color(red: session.moodColorR, green: session.moodColorG, blue: session.moodColorB)
    }

    private var auraStyle: WatchAuraView.Style {
        let s = session.wellnessScore
        if s >= 0.78 { return .smooth }
        if s >= 0.55 { return .smooth }
        if s >= 0.33 { return .gentle }
        return .wild
    }

    var body: some View {
        ZStack {
            WatchAuraView(color: moodColor, style: auraStyle)
                .ignoresSafeArea()

            memojiRingSection
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    private var memojiRingSection: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.22), lineWidth: 7)
                    .frame(width: 122, height: 122)

                Circle()
                    .trim(from: 0, to: session.wellnessScore)
                    .stroke(
                        moodColor,
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .frame(width: 122, height: 122)
                    .rotationEffect(.degrees(-90))

                if let data = session.memojiData, let uiImage = UIImage(data: data) {
                    Image(uiImage: removeWhiteBackground(from: uiImage) ?? uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 99, height: 99)
                } else {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(moodColor)
                }
            }

            Text("\(Int(session.wellnessScore * 100))%")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(moodColor)
        }
    }

    private func removeWhiteBackground(from image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        guard let context = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        for i in stride(from: 0, to: pixelData.count, by: 4) {
            let r = pixelData[i]
            let g = pixelData[i + 1]
            let b = pixelData[i + 2]
            if r > 230 && g > 230 && b > 230 {
                pixelData[i + 3] = 0
            } else if r > 200 && g > 200 && b > 200 {
                let minC = min(r, min(g, b))
                let distance = 255 - Int(minC)
                pixelData[i + 3] = UInt8(min(255, distance * 6))
            }
        }
        guard let output = context.makeImage() else { return nil }
        return UIImage(cgImage: output, scale: image.scale, orientation: image.imageOrientation)
    }
}

struct WatchAuraView: View {
    let color: Color
    let style: Style

    enum Style { case smooth, gentle, wild }

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let cx = size.width / 2
                let cy = size.height / 2
                let baseR = min(size.width, size.height) * 0.38

                for i in 0..<5 {
                    let di = Double(i)
                    let ringR = baseR + di * 9.0
                    let opacity = 0.32 - di * 0.04
                    let lineW = 1.4

                    switch style {
                    case .smooth:
                        let rot = t * 0.25 + di * 0.3
                        let pulse = sin(t * 1.2 + di * 0.5) * 2.5
                        let r = ringR + pulse
                        var path = Path()
                        let steps = 120
                        for j in 0...steps {
                            let angle = Double(j) / Double(steps) * 2.0 * .pi + rot
                            let x = cx + r * cos(angle)
                            let y = cy + r * sin(angle)
                            if j == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        path.closeSubpath()
                        context.stroke(path, with: .color(color.opacity(opacity)), lineWidth: lineW)

                    case .gentle:
                        let rot = t * 0.35 + di * 0.4
                        let wavePhase = t * 1.0 + di * 0.6
                        let waveAmp = 3.0 + di * 0.8
                        let waveFreq = 5.0 + di * 0.8
                        var path = Path()
                        let steps = 140
                        for j in 0...steps {
                            let angle = Double(j) / Double(steps) * 2.0 * .pi
                            let wave = waveAmp * sin(waveFreq * angle + wavePhase)
                            let r = ringR + wave
                            let x = cx + r * cos(angle + rot)
                            let y = cy + r * sin(angle + rot)
                            if j == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        path.closeSubpath()
                        context.stroke(path, with: .color(color.opacity(opacity)), lineWidth: lineW)

                    case .wild:
                        let rot = t * 0.5 + di * 0.3
                        let wavePhase = t * 1.6 + di * 0.4
                        let waveAmp = 5.0 + di * 1.4
                        let waveFreq = 7.0 + di * 1.0
                        var path = Path()
                        let steps = 140
                        for j in 0...steps {
                            let angle = Double(j) / Double(steps) * 2.0 * .pi
                            let wave = waveAmp * sin(waveFreq * angle + wavePhase)
                            let r = ringR + wave
                            let x = cx + r * cos(angle + rot)
                            let y = cy + r * sin(angle + rot)
                            if j == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        path.closeSubpath()
                        context.stroke(path, with: .color(color.opacity(opacity)), lineWidth: lineW)
                    }
                }
            }
        }
    }
}
