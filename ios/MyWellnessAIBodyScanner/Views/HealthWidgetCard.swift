import SwiftUI

struct HealthWidgetCard: View {
    @Environment(AppViewModel.self) private var appVM
    @State private var animateRing: Bool = false
    @State private var pulse: Bool = false

    private var mood: WellnessMood { appVM.wellnessMood }
    private var score: Double { appVM.wellnessScore }
    private var snapshot: HealthSnapshot { appVM.healthSnapshot }
    var body: some View {
        HStack(spacing: 16) {
            faceSection
            Spacer(minLength: 0)
            statsGrid
        }
        .padding(20)
        .background(.white.opacity(0.80))
        .clipShape(.rect(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, y: 4)
        .padding(.horizontal, 16)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.2)) {
                animateRing = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private var faceSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(mood.color.opacity(pulse ? 0.12 : 0.06))
                    .frame(width: 100, height: 100)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulse)

                Circle()
                    .trim(from: 0, to: animateRing ? score : 0)
                    .stroke(
                        mood.color,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 5)
                    .frame(width: 100, height: 100)
                    .opacity(0.5)

                Circle()
                    .trim(from: 0, to: animateRing ? score : 0)
                    .stroke(
                        mood.color,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                if let uiImage = appVM.memojiUIImage(for: mood) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 72, height: 72)
                        .clipShape(.circle)
                } else {
                    Text(mood.emoji)
                        .font(.system(size: 44))
                }
            }

            VStack(spacing: 2) {
                Text(mood.moodLabel)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(mood.color)

                Text("\(Int(score * 100))%")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var statsGrid: some View {
        let gridItems = [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ]

        return LazyVGrid(columns: gridItems, spacing: 10) {
            MiniStatCell(
                icon: "figure.walk",
                value: snapshot.steps > 0 ? formatNumber(snapshot.steps) : "--",
                label: Lang.s("hw_steps"),
                color: .blue
            )
            MiniStatCell(
                icon: "heart.fill",
                value: snapshot.restingHeartRate > 25 ? "\(Int(snapshot.restingHeartRate))" : "--",
                label: Lang.s("hw_bpm"),
                color: .red
            )
            MiniStatCell(
                icon: "moon.zzz.fill",
                value: snapshot.sleepHours > 0 ? String(format: "%.1f", snapshot.sleepHours) : "--",
                label: Lang.s("hw_sleep_hours"),
                color: .indigo
            )
            MiniStatCell(
                icon: "bolt.fill",
                value: snapshot.activeCalories > 0 ? "\(Int(snapshot.activeCalories))" : "--",
                label: Lang.s("hw_active_cal"),
                color: .orange
            )
        }
        .frame(maxWidth: 170)
    }

    private func formatNumber(_ value: Double) -> String {
        if value >= 10000 {
            return String(format: "%.1fk", value / 1000)
        }
        return "\(Int(value))"
    }
}

private struct MiniStatCell: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(color)
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.06))
        .clipShape(.rect(cornerRadius: 10, style: .continuous))
    }
}
