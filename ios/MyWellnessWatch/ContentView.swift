import SwiftUI

private enum WatchLang {
    private static var code: String {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        return ["it", "en", "es", "de", "fr", "pt"].contains(lang) ? lang : "en"
    }

    private static let strings: [String: [String: String]] = [
        "steps": ["en": "Steps", "it": "Passi", "es": "Pasos", "de": "Schritte", "fr": "Pas", "pt": "Passos"],
        "sleep": ["en": "Sleep", "it": "Sonno", "es": "Sueño", "de": "Schlaf", "fr": "Sommeil", "pt": "Sono"],
        "cal": ["en": "Cal", "it": "Cal", "es": "Cal", "de": "Kal", "fr": "Cal", "pt": "Cal"],
        "bpm": ["en": "BPM", "it": "BPM", "es": "BPM", "de": "BPM", "fr": "BPM", "pt": "BPM"],
        "health": ["en": "Health", "it": "Salute", "es": "Salud", "de": "Gesundheit", "fr": "Santé", "pt": "Saúde"],
    ]

    static func s(_ key: String) -> String {
        strings[key]?[code] ?? strings[key]?["en"] ?? key
    }
}

struct ContentView: View {
    @State private var session = WatchSessionService.shared

    private var moodColor: Color {
        Color(red: session.moodColorR, green: session.moodColorG, blue: session.moodColorB)
    }

    var body: some View {
        ZStack {
            constellationStats
            memojiRingSection
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    private var memojiRingSection: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.22), lineWidth: 6)
                .frame(width: 94, height: 94)

            Circle()
                .trim(from: 0, to: session.wellnessScore)
                .stroke(
                    moodColor,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 94, height: 94)
                .rotationEffect(.degrees(-90))

            if let data = session.memojiData, let uiImage = UIImage(data: data) {
                Image(uiImage: removeWhiteBackground(from: uiImage) ?? uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 76, height: 76)
            } else {
                VStack(spacing: 2) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(moodColor)
                    Text("\(Int(session.wellnessScore * 100))%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(moodColor)
                }
            }
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
            if r > 240 && g > 240 && b > 240 {
                pixelData[i + 3] = 0
            } else if r > 220 && g > 220 && b > 220 {
                let minC = min(r, min(g, b))
                let distance = 255 - Int(minC)
                pixelData[i + 3] = UInt8(min(255, distance * 8))
            }
        }
        guard let output = context.makeImage() else { return nil }
        return UIImage(cgImage: output, scale: image.scale, orientation: image.imageOrientation)
    }

    private var constellationStats: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                ConstellationStat(
                    icon: "figure.walk",
                    value: session.steps > 0 ? formatNumber(Double(session.steps)) : "--",
                    label: WatchLang.s("steps"),
                    color: .blue
                )
                Spacer(minLength: 0)
                ConstellationStat(
                    icon: "heart.fill",
                    value: session.bpm > 25 ? "\(session.bpm)" : "--",
                    label: WatchLang.s("bpm"),
                    color: .red
                )
            }
            Spacer(minLength: 0)
            HStack(alignment: .bottom) {
                ConstellationStat(
                    icon: "moon.zzz.fill",
                    value: session.sleepHours > 0 ? String(format: "%.1f", session.sleepHours) : "--",
                    label: WatchLang.s("sleep"),
                    color: .indigo
                )
                Spacer(minLength: 0)
                ConstellationStat(
                    icon: "bolt.fill",
                    value: session.activeCalories > 0 ? "\(session.activeCalories)" : "--",
                    label: WatchLang.s("cal"),
                    color: .orange
                )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func formatNumber(_ value: Double) -> String {
        if value >= 10000 {
            return String(format: "%.1fk", value / 1000)
        }
        return "\(Int(value))"
    }
}

private struct ConstellationStat: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 1) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(color)
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .fixedSize()
    }
}
