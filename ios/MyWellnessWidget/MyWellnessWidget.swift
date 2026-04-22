import WidgetKit
import SwiftUI

nonisolated let appGroupID = "group.app.rork.zdxfa09dhovxfuxepqeqb"

nonisolated private enum WidgetLang {
    private static var code: String {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        return ["it", "en", "es", "de", "fr", "pt"].contains(lang) ? lang : "en"
    }

    private static let strings: [String: [String: String]] = [
        "steps": ["en": "Steps", "it": "Passi", "es": "Pasos", "de": "Schritte", "fr": "Pas", "pt": "Passos"],
        "sleep": ["en": "Sleep", "it": "Sonno", "es": "Sueño", "de": "Schlaf", "fr": "Sommeil", "pt": "Sono"],
        "cal": ["en": "Cal", "it": "Cal", "es": "Cal", "de": "Kal", "fr": "Cal", "pt": "Cal"],
        "bpm": ["en": "BPM", "it": "BPM", "es": "BPM", "de": "BPM", "fr": "BPM", "pt": "BPM"],
        "feeling_good": ["en": "Feeling Good!", "it": "Stai Bene!", "es": "¡Te Sientes Bien!", "de": "Geht Dir Gut!", "fr": "Ça Va Bien !", "pt": "Está Bem!"],
    ]

    static func s(_ key: String) -> String {
        strings[key]?[code] ?? strings[key]?["en"] ?? key
    }
}

nonisolated struct WellnessEntry: TimelineEntry {
    let date: Date
    let steps: Int
    let bpm: Int
    let sleepHours: Double
    let activeCalories: Int
    let calorieBalance: Int
    let wellnessScore: Double
    let moodLabel: String
    let moodColorR: Double
    let moodColorG: Double
    let moodColorB: Double
    let bmi: Double
    let memojiData: Data?
}

nonisolated struct WellnessProvider: TimelineProvider {
    func placeholder(in context: Context) -> WellnessEntry {
        WellnessEntry(
            date: .now, steps: 6420, bpm: 68, sleepHours: 7.2,
            activeCalories: 340, calorieBalance: -450, wellnessScore: 0.72,
            moodLabel: WidgetLang.s("feeling_good"), moodColorR: 0.17, moodColorG: 0.60, moodColorB: 0.52,
            bmi: 24.1, memojiData: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WellnessEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WellnessEntry>) -> Void) {
        let entry = readEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func readEntry() -> WellnessEntry {
        let shared = UserDefaults(suiteName: appGroupID)
        return WellnessEntry(
            date: .now,
            steps: shared?.integer(forKey: "widget_steps") ?? 0,
            bpm: shared?.integer(forKey: "widget_bpm") ?? 0,
            sleepHours: shared?.double(forKey: "widget_sleepHours") ?? 0,
            activeCalories: shared?.integer(forKey: "widget_activeCalories") ?? 0,
            calorieBalance: shared?.integer(forKey: "widget_calorieBalance") ?? 0,
            wellnessScore: shared?.double(forKey: "widget_wellnessScore") ?? 0.5,
            moodLabel: shared?.string(forKey: "widget_moodLabel") ?? "---",
            moodColorR: shared?.double(forKey: "widget_moodColorR") ?? 0.17,
            moodColorG: shared?.double(forKey: "widget_moodColorG") ?? 0.60,
            moodColorB: shared?.double(forKey: "widget_moodColorB") ?? 0.52,
            bmi: shared?.double(forKey: "widget_bmi") ?? 0,
            memojiData: shared?.data(forKey: "widget_memojiData")
        )
    }
}

struct WellnessWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: WellnessEntry

    private var moodColor: Color {
        Color(red: entry.moodColorR, green: entry.moodColorG, blue: entry.moodColorB)
    }

    private var memojiImage: UIImage? {
        if let data = entry.memojiData {
            return UIImage(data: data)
        }
        return nil
    }

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .accessoryCircular:
            accessoryCircularWidget
        case .accessoryRectangular:
            accessoryRectangularWidget
        case .accessoryInline:
            accessoryInlineWidget
        default:
            mediumWidget
        }
    }

    private var memojiWithRings: some View {
        ZStack {
            Circle()
                .fill(moodColor.opacity(0.08))

            Circle()
                .stroke(Color(.systemGray5), lineWidth: 4)
                .opacity(0.5)

            Circle()
                .trim(from: 0, to: entry.wellnessScore)
                .stroke(
                    moodColor,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            if let uiImage = memojiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(.circle)
                    .padding(8)
            } else {
                Image(systemName: "face.smiling.inverse")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(moodColor)
            }
        }
    }

    private var accessoryCircularWidget: some View {
        ZStack {
            AccessoryWidgetBackground()

            Circle()
                .stroke(Color.secondary.opacity(0.3), lineWidth: 3)

            Circle()
                .trim(from: 0, to: entry.wellnessScore)
                .stroke(
                    Color.primary,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            if let uiImage = memojiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(.circle)
                    .padding(5)
            } else {
                VStack(spacing: 0) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text("\(Int(entry.wellnessScore * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
            }
        }
        .containerBackground(.clear, for: .widget)
    }

    private var accessoryRectangularWidget: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 12, weight: .bold))
                Text(entry.moodLabel)
                    .font(.system(size: 12, weight: .bold))
                    .lineLimit(1)
                Spacer()
                Text("\(Int(entry.wellnessScore * 100))%")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            HStack(spacing: 10) {
                Label("\(entry.steps)", systemImage: "figure.walk")
                Label(entry.bpm > 0 ? "\(entry.bpm)" : "--", systemImage: "heart.fill")
                Label(entry.sleepHours > 0 ? String(format: "%.1f", entry.sleepHours) + "h" : "--", systemImage: "moon.zzz.fill")
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
        }
        .containerBackground(.clear, for: .widget)
    }

    private var accessoryInlineWidget: some View {
        HStack(spacing: 4) {
            Image(systemName: "heart.fill")
            Text("\(entry.moodLabel) · \(Int(entry.wellnessScore * 100))%")
        }
        .containerBackground(.clear, for: .widget)
    }

    private var smallWidget: some View {
        VStack(spacing: 6) {
            memojiWithRings
                .frame(width: 72, height: 72)

            Text(entry.moodLabel)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(moodColor)
                .lineLimit(1)

            Text("\(Int(entry.wellnessScore * 100))%")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Label("\(entry.steps)", systemImage: "figure.walk")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
                Label("\(entry.bpm > 0 ? "\(entry.bpm)" : "--")", systemImage: "heart.fill")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [moodColor.opacity(0.06), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var mediumWidget: some View {
        HStack(spacing: 14) {
            VStack(spacing: 6) {
                memojiWithRings
                    .frame(width: 80, height: 80)

                VStack(spacing: 1) {
                    Text(entry.moodLabel)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(moodColor)
                        .lineLimit(1)

                    Text("\(Int(entry.wellnessScore * 100))%")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 100)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    widgetStat(icon: "figure.walk", value: "\(entry.steps)", label: WidgetLang.s("steps"), color: .blue)
                    widgetStat(icon: "heart.fill", value: entry.bpm > 0 ? "\(entry.bpm)" : "--", label: WidgetLang.s("bpm"), color: .red)
                }
                HStack(spacing: 12) {
                    widgetStat(icon: "moon.zzz.fill", value: entry.sleepHours > 0 ? String(format: "%.1f", entry.sleepHours) : "--", label: WidgetLang.s("sleep"), color: .indigo)
                    widgetStat(icon: "bolt.fill", value: entry.activeCalories > 0 ? "\(entry.activeCalories)" : "--", label: WidgetLang.s("cal"), color: .orange)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [moodColor.opacity(0.06), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func widgetStat(icon: String, value: String, label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MyWellnessWidget: Widget {
    let kind: String = "MyWellnessWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WellnessProvider()) { entry in
            WellnessWidgetView(entry: entry)
        }
        .configurationDisplayName("MyWellness")
        .description("View your health status in real time.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
