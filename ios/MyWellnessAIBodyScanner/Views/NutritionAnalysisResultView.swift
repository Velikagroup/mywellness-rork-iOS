import SwiftUI

struct NutritionAnalysisResultView: View {
    let result: NutritionTableResult
    let image: UIImage?
    @Environment(\.dismiss) private var dismiss

    private var qualityScore: Int {
        FoodProductScanRecord.computeQuality(from: result)
    }

    private var qualityLabel: String {
        switch qualityScore {
        case 80...100: return "Excellent"
        case 60..<80: return "Good"
        case 40..<60: return "Average"
        case 20..<40: return "Poor"
        default: return "Very Poor"
        }
    }

    private var qualityColor: Color {
        switch qualityScore {
        case 80...100: return .green
        case 60..<80: return Color(red: 0.17, green: 0.60, blue: 0.52)
        case 40..<60: return .orange
        default: return .red
        }
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header
                    VStack(spacing: 16) {
                        productCard
                        qualityScoreCard
                        caloriesCard
                        macroSection
                        otherNutrientsSection
                        doneButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 36, height: 36)
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(Lang.s("nutrition_mode"))
                .font(.headline)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var productCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.productName.isEmpty ? Lang.s("product") : result.productName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                Text("\(Lang.s("serving_size")): \(result.servingSize)")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "doc.text.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color(red: 0.17, green: 0.60, blue: 0.52).opacity(0.7))
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var qualityScoreCard: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nutri-Score")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text(qualityLabel)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(qualityColor)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                        .frame(width: 72, height: 72)
                    Circle()
                        .trim(from: 0, to: Double(qualityScore) / 100.0)
                        .stroke(qualityColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 72, height: 72)
                        .rotationEffect(.degrees(-90))
                    Text("\(qualityScore)")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(qualityColor)
                }
            }

            HStack(spacing: 4) {
                ForEach(0..<5) { i in
                    let segmentThreshold = (i + 1) * 20
                    RoundedRectangle(cornerRadius: 3)
                        .fill(qualityScore >= segmentThreshold ? qualityColor : Color(.systemGray5))
                        .frame(height: 6)
                }
            }

            Text(qualityAdvice)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(qualityColor.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(qualityColor.opacity(0.2), lineWidth: 1)
        )
    }

    private var qualityAdvice: String {
        switch qualityScore {
        case 80...100: return "Ottimo profilo nutrizionale. Ricco di nutrienti e bilanciato."
        case 60..<80: return "Buon profilo nutrizionale. Adatto per un consumo regolare."
        case 40..<60: return "Profilo nutrizionale nella media. Da consumare con moderazione."
        case 20..<40: return "Profilo nutrizionale scarso. Limitare il consumo."
        default: return "Profilo nutrizionale molto scarso. Evitare il consumo frequente."
        }
    }

    private var caloriesCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Lang.s("calories"))
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(result.calories)")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundStyle(Color(red: 0.17, green: 0.60, blue: 0.52))
                    Text("kcal")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 0.17, green: 0.60, blue: 0.52))
                }
            }
            Spacer()
            calorieRing
        }
        .padding(18)
        .background(Color(red: 0.17, green: 0.60, blue: 0.52).opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var calorieRing: some View {
        let total = result.totalFat * 9 + result.carbohydrates * 4 + result.protein * 4
        let fatFrac = total > 0 ? (result.totalFat * 9) / total : 0.33
        let carbFrac = total > 0 ? (result.carbohydrates * 4) / total : 0.33
        let protFrac = total > 0 ? (result.protein * 4) / total : 0.34

        return ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 10)
                .frame(width: 64, height: 64)
            Circle()
                .trim(from: 0, to: fatFrac)
                .stroke(Color(red: 0.72, green: 0.08, blue: 0.08), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 64, height: 64)
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: fatFrac, to: fatFrac + carbFrac)
                .stroke(.orange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 64, height: 64)
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: fatFrac + carbFrac, to: fatFrac + carbFrac + protFrac)
                .stroke(Color(red: 0.17, green: 0.60, blue: 0.52), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 64, height: 64)
                .rotationEffect(.degrees(-90))
        }
    }

    private var macroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Lang.s("macronutrients"))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            HStack(spacing: 10) {
                macroCard(label: Lang.s("protein"), value: result.protein, unit: "g", color: Color(red: 0.17, green: 0.60, blue: 0.52))
                macroCard(label: Lang.s("carbs"), value: result.carbohydrates, unit: "g", color: .orange)
                macroCard(label: Lang.s("fat"), value: result.totalFat, unit: "g", color: Color(red: 0.72, green: 0.08, blue: 0.08))
            }
        }
    }

    private func macroCard(label: String, value: Double, unit: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(String(format: "%.1f%@", value, unit))
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.08))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var otherNutrientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Lang.s("other_nutrients"))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                nutrientRow(label: Lang.s("sugars"), value: result.sugars, unit: "g")
                Divider().padding(.horizontal, 16)
                nutrientRow(label: Lang.s("saturated_fat"), value: result.saturatedFat, unit: "g")
                Divider().padding(.horizontal, 16)
                nutrientRow(label: Lang.s("fiber"), value: result.fiber, unit: "g")
                Divider().padding(.horizontal, 16)
                nutrientRow(label: Lang.s("salt"), value: result.salt, unit: "g")
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private func nutrientRow(label: String, value: Double, unit: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(.primary)
            Spacer()
            Text(String(format: "%.1f %@", value, unit))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var doneButton: some View {
        Button { dismiss() } label: {
            Text(Lang.s("done"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.wellnessTeal)
                .clipShape(.rect(cornerRadius: 16))
        }
    }
}
