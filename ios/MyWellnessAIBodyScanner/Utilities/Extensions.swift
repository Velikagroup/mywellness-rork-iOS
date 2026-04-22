import SwiftUI

extension Color {
    static let wellnessTeal = Color(red: 43/255, green: 149/255, blue: 133/255)
    static let wellnessTealLight = Color(red: 43/255, green: 149/255, blue: 133/255).opacity(0.12)
    static let appBackground = Color(red: 232/255, green: 242/255, blue: 246/255)
}

struct WellnessLogo: View {
    var body: some View {
        Image("MyWellnessAIBodyScannerLogo")
            .resizable()
            .scaledToFit()
            .frame(height: 26.6)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(.regularMaterial)
                    .overlay(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.25), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 0.5))
            }
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }
}

struct WellnessNavBarOverlay: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                WellnessLogo()
                Spacer()
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MacroCircle: View {
    let value: Double
    let unit: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 4)
                    .frame(width: 68, height: 68)
                VStack(spacing: 0) {
                    Text(String(format: "%.0f", value))
                        .font(.system(.subheadline, weight: .bold))
                        .foregroundStyle(color)
                    Text(unit)
                        .font(.caption2)
                        .foregroundStyle(color.opacity(0.8))
                }
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct NutrientBar: View {
    let current: Double
    let target: Double
    let color: Color

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5).fill(color.opacity(0.12)).frame(height: 10)
                RoundedRectangle(cornerRadius: 5).fill(color).frame(width: geo.size.width * progress, height: 10)
                    .animation(.spring(response: 0.5), value: progress)
            }
        }
        .frame(height: 10)
    }
}

struct MealProgressBar: View {
    let meals: [Meal]
    let completedMealIds: Set<UUID>
    let totalScale: Double

    private let barHeight: CGFloat = 10
    private let gap: CGFloat = 3

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let consumed = Double(meals.filter { completedMealIds.contains($0.id) }.reduce(0) { $0 + $1.calories })
            let pending = meals.filter { !completedMealIds.contains($0.id) }
            let consumedWidth = totalScale > 0 ? w * CGFloat(consumed / totalScale) : 0

            let segments: [(x: CGFloat, width: CGFloat)] = {
                var result: [(CGFloat, CGFloat)] = []
                var currentX = consumedWidth + gap
                for meal in pending {
                    let mealW = totalScale > 0 ? w * CGFloat(Double(meal.calories) / totalScale) - gap : 0
                    if mealW > 2 {
                        result.append((currentX, mealW))
                        currentX += mealW + gap
                    }
                }
                return result
            }()

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: barHeight / 2)
                    .fill(Color.red.opacity(0.08))
                    .frame(height: barHeight)

                if consumedWidth > 0 {
                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .fill(Color.red)
                        .frame(width: consumedWidth, height: barHeight)
                }

                ForEach(Array(segments.enumerated()), id: \.offset) { _, seg in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red.opacity(0.28))
                        .frame(width: seg.width, height: barHeight)
                        .offset(x: seg.x)
                }
            }
            .animation(.spring(response: 0.5), value: consumed)
        }
        .frame(height: barHeight)
    }
}

struct DualNutrientBar: View {
    let bmr: Double
    let neat: Double
    var extra: Double = 0
    let bmrColor: Color
    let neatColor: Color
    var extraColor: Color = Color(red: 0.45, green: 0.92, blue: 0.18)

    private var total: Double { bmr + neat + extra }
    private var bmrFraction: CGFloat { total > 0 ? CGFloat(bmr / total) : 0 }
    private var neatFraction: CGFloat { total > 0 ? CGFloat(neat / total) : 0 }
    private var extraFraction: CGFloat { total > 0 ? CGFloat(extra / total) : 0 }

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let gap: CGFloat = 4
            let hasExtra = extra > 0
            let numGaps: CGFloat = hasExtra ? 2 : 1
            let totalGap = gap * numGaps
            let bmrWidth = max(0, totalWidth * bmrFraction - totalGap * bmrFraction)
            let neatWidth = max(0, totalWidth * neatFraction - totalGap * neatFraction)
            let extraWidth = max(0, totalWidth * extraFraction - totalGap * extraFraction)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(bmrColor.opacity(0.10))
                    .frame(height: 10)
                HStack(spacing: gap) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(bmrColor)
                        .frame(width: bmrWidth, height: 10)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(neatColor)
                        .frame(width: neatWidth, height: 10)
                    if hasExtra {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(extraColor)
                            .frame(width: extraWidth, height: 10)
                    }
                    Spacer(minLength: 0)
                }
                .animation(.spring(response: 0.5), value: bmrFraction)
                .animation(.spring(response: 0.5), value: extraFraction)
            }
        }
        .frame(height: 10)
    }
}

struct AsyncMealImage: View {
    let urlString: String?

    var body: some View {
        if let urlString, let url = URL(string: urlString) {
            Color(.secondarySystemBackground)
                .overlay {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .allowsHitTesting(false)
                        } else if phase.error != nil {
                            Image(systemName: "fork.knife")
                                .font(.title3)
                                .foregroundStyle(.tertiary)
                        } else {
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                    }
                }
        } else {
            Color(.secondarySystemBackground)
                .overlay {
                    Image(systemName: "fork.knife")
                        .font(.title3)
                        .foregroundStyle(.tertiary)
                }
        }
    }
}

extension DateFormatter {
    static let dayKey: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

extension Date {
    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
}

nonisolated enum DayNameNormalizer {
    private static let dayMap: [String: String] = [
        "monday": "Monday", "mon": "Monday", "lunes": "Monday", "lunedì": "Monday", "lunedi": "Monday", "lundi": "Monday", "montag": "Monday", "segunda": "Monday", "segunda-feira": "Monday",
        "tuesday": "Tuesday", "tue": "Tuesday", "martes": "Tuesday", "martedì": "Tuesday", "martedi": "Tuesday", "mardi": "Tuesday", "dienstag": "Tuesday", "terça": "Tuesday", "terça-feira": "Tuesday", "terca": "Tuesday",
        "wednesday": "Wednesday", "wed": "Wednesday", "miércoles": "Wednesday", "miercoles": "Wednesday", "mercoledì": "Wednesday", "mercoledi": "Wednesday", "mercredi": "Wednesday", "mittwoch": "Wednesday", "quarta": "Wednesday", "quarta-feira": "Wednesday",
        "thursday": "Thursday", "thu": "Thursday", "jueves": "Thursday", "giovedì": "Thursday", "giovedi": "Thursday", "jeudi": "Thursday", "donnerstag": "Thursday", "quinta": "Thursday", "quinta-feira": "Thursday",
        "friday": "Friday", "fri": "Friday", "viernes": "Friday", "venerdì": "Friday", "venerdi": "Friday", "vendredi": "Friday", "freitag": "Friday", "sexta": "Friday", "sexta-feira": "Friday",
        "saturday": "Saturday", "sat": "Saturday", "sábado": "Saturday", "sabado": "Saturday", "sabato": "Saturday", "samedi": "Saturday", "samstag": "Saturday",
        "sunday": "Sunday", "sun": "Sunday", "domingo": "Sunday", "domenica": "Sunday", "dimanche": "Sunday", "sonntag": "Sunday"
    ]

    static func normalize(_ dayName: String) -> String {
        let key = dayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let match = dayMap[key] { return match }
        for (k, v) in dayMap where key.contains(k) { return v }
        return dayName
    }
}

extension Int {
    var formattedCalories: String {
        "\(self) kcal"
    }
}
