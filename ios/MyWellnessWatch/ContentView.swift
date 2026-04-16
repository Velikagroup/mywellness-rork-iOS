import SwiftUI

private let appGroupID = "group.app.rork.zdxfa09dhovxfuxepqeqb"

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
    @State private var steps: Int = 0
    @State private var bpm: Int = 0
    @State private var sleepHours: Double = 0
    @State private var activeCalories: Int = 0
    @State private var wellnessScore: Double = 0.5
    @State private var moodLabel: String = "---"
    @State private var moodColorR: Double = 0.17
    @State private var moodColorG: Double = 0.60
    @State private var moodColorB: Double = 0.52
    @State private var memojiData: Data? = nil

    private var moodColor: Color {
        Color(red: moodColorR, green: moodColorG, blue: moodColorB)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                memojiRingSection
                statsSection
            }
            .padding(.horizontal, 4)
        }
        .onAppear { loadData() }
    }

    private var memojiRingSection: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(moodColor.opacity(0.10))
                    .frame(width: 90, height: 90)

                Circle()
                    .stroke(Color.gray.opacity(0.25), lineWidth: 5)
                    .frame(width: 90, height: 90)

                Circle()
                    .trim(from: 0, to: wellnessScore)
                    .stroke(
                        moodColor,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))

                if let data = memojiData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .clipShape(.circle)
                } else {
                    Image(systemName: "face.smiling.inverse")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(moodColor)
                }
            }

            Text(moodLabel)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(moodColor)
                .lineLimit(1)

            Text("\(Int(wellnessScore * 100))%")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    private var statsSection: some View {
        let columns = [
            GridItem(.flexible(), spacing: 6),
            GridItem(.flexible(), spacing: 6)
        ]

        return LazyVGrid(columns: columns, spacing: 6) {
            WatchStatCell(
                icon: "figure.walk",
                value: steps > 0 ? formatNumber(Double(steps)) : "--",
                label: WatchLang.s("steps"),
                color: .blue
            )
            WatchStatCell(
                icon: "heart.fill",
                value: bpm > 25 ? "\(bpm)" : "--",
                label: WatchLang.s("bpm"),
                color: .red
            )
            WatchStatCell(
                icon: "moon.zzz.fill",
                value: sleepHours > 0 ? String(format: "%.1f", sleepHours) : "--",
                label: WatchLang.s("sleep"),
                color: .indigo
            )
            WatchStatCell(
                icon: "bolt.fill",
                value: activeCalories > 0 ? "\(activeCalories)" : "--",
                label: WatchLang.s("cal"),
                color: .orange
            )
        }
    }

    private func loadData() {
        let shared = UserDefaults(suiteName: appGroupID)
        steps = shared?.integer(forKey: "widget_steps") ?? 0
        bpm = shared?.integer(forKey: "widget_bpm") ?? 0
        sleepHours = shared?.double(forKey: "widget_sleepHours") ?? 0
        activeCalories = shared?.integer(forKey: "widget_activeCalories") ?? 0
        wellnessScore = shared?.double(forKey: "widget_wellnessScore") ?? 0.5
        moodLabel = shared?.string(forKey: "widget_moodLabel") ?? "---"
        moodColorR = shared?.double(forKey: "widget_moodColorR") ?? 0.17
        moodColorG = shared?.double(forKey: "widget_moodColorG") ?? 0.60
        moodColorB = shared?.double(forKey: "widget_moodColorB") ?? 0.52
        memojiData = shared?.data(forKey: "widget_memojiData")
    }

    private func formatNumber(_ value: Double) -> String {
        if value >= 10000 {
            return String(format: "%.1fk", value / 1000)
        }
        return "\(Int(value))"
    }
}

private struct WatchStatCell: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(color)
                Text(value)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
        .background(color.opacity(0.12))
        .clipShape(.rect(cornerRadius: 10, style: .continuous))
    }
}
