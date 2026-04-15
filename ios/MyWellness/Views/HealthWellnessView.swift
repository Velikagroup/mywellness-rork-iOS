import SwiftUI

struct HealthWellnessView: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(\.dismiss) private var dismiss
    @State private var showMemojiPicker: Bool = false
    @State private var animateScore: Bool = false

    private var result: (parameters: [WellnessParameter], score: Double, mood: WellnessMood) {
        appVM.wellnessResult
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerCard
                    wearableToggleCard
                    if result.parameters.isEmpty {
                        emptyState
                    } else {
                        parametersSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(Lang.s("health_status"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.s("close")) { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showMemojiPicker) {
            MemojiPickerSheet(isPresented: $showMemojiPicker) { images in
                appVM.saveMemojiImages(images)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.2)) {
                animateScore = true
            }
            Task {
                await appVM.fetchHealthData()
            }
        }
    }

    private var headerCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 24) {
                avatarSection
                VStack(alignment: .leading, spacing: 10) {
                    scoreRing
                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.mood.fullLabel)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(scoreDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(20)

            Divider().padding(.horizontal, 20)

            HStack(spacing: 6) {
                Image(systemName: "face.smiling")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                Text(Lang.s("memoji_setup_hint"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(.white.opacity(0.88))
        .clipShape(.rect(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 14, y: 4)
    }

    private var avatarSection: some View {
        Button {
            showMemojiPicker = true
        } label: {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(result.mood.color.opacity(0.10))
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle()
                            .strokeBorder(result.mood.color.opacity(0.3), lineWidth: 2)
                    )

                if let uiImage = appVM.memojiUIImage(for: result.mood) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 84, height: 84)
                        .clipShape(.circle)
                } else {
                    Text(result.mood.emoji)
                        .font(.system(size: 52))
                }

                Circle()
                    .fill(result.mood.color)
                    .frame(width: 26, height: 26)
                    .overlay(
                        Image(systemName: "face.smiling")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
            }
        }
        .buttonStyle(.plain)
    }

    private var scoreRing: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 7)
                    .frame(width: 56, height: 56)

                Circle()
                    .trim(from: 0, to: animateScore ? result.score : 0)
                    .stroke(
                        result.mood.color,
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.2, dampingFraction: 0.7).delay(0.3), value: animateScore)

                Text("\(Int(result.score * 100))")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(result.mood.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(Lang.s("score"))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(result.mood.shortLabel)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(result.mood.color)
            }
        }
    }

    private var scoreDescription: String {
        let withData = result.parameters.filter { $0.hasData }
        let goodCount = withData.filter { $0.status == .good }.count
        let total = withData.count
        guard total > 0 else { return Lang.s("connect_health_score") }
        return "\(goodCount)/\(total) \(Lang.s("params_great_condition"))"
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 44))
                .foregroundStyle(Color.wellnessTeal.opacity(0.5))
            Text(Lang.s("no_data_available"))
                .font(.headline)
            Text(Lang.s("connect_health_msg"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(.white.opacity(0.88))
        .clipShape(.rect(cornerRadius: 24, style: .continuous))
    }

    private var wearableToggleCard: some View {
        @Bindable var vm = appVM
        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(appVM.wearableDeviceEnabled ? Color(red: 0.17, green: 0.72, blue: 0.45).opacity(0.12) : Color(.systemGray5))
                    .frame(width: 44, height: 44)
                Image(systemName: "applewatch")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(appVM.wearableDeviceEnabled ? Color(red: 0.17, green: 0.72, blue: 0.45) : .secondary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Apple Watch")
                    .font(.subheadline.weight(.semibold))
                Text(appVM.wearableDeviceEnabled ? Lang.s("wearable_enabled_desc") : Lang.s("wearable_disabled_desc"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { appVM.wearableDeviceEnabled },
                set: { appVM.toggleWearableDevice($0) }
            ))
            .labelsHidden()
            .tint(Color(red: 0.17, green: 0.72, blue: 0.45))
        }
        .padding(16)
        .background(.white.opacity(0.88))
        .clipShape(.rect(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private var parametersSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text(Lang.s("parameters_label"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.bottom, 10)
            .padding(.horizontal, 4)

            VStack(spacing: 10) {
                ForEach(result.parameters) { param in
                    WellnessParameterRow(param: param)
                }
            }
        }
    }
}

private struct WellnessParameterRow: View {
    let param: WellnessParameter
    @State private var animateBar: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(param.status.color.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: param.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(param.status.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(param.name)
                        .font(.subheadline.weight(.semibold))
                    Text(param.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 1) {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(param.displayValue)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(param.status.color)
                        Text(param.unit)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(param.status.color.opacity(0.7))
                    }
                    HStack(spacing: 4) {
                        Circle()
                            .fill(param.status.color)
                            .frame(width: 6, height: 6)
                        Text(param.status.label)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(param.status.color)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            WellnessRangeBar(normalized: animateBar ? param.currentNormalized : 0, status: param.status)
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
        }
        .background(.white.opacity(0.88))
        .clipShape(.rect(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(Double.random(in: 0.1...0.4))) {
                animateBar = true
            }
        }
    }
}

private struct WellnessRangeBar: View {
    let normalized: Double
    let status: WellnessParameterStatus

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let dotSize: CGFloat = 16
            let dotX = max(dotSize / 2, min(totalWidth - dotSize / 2, totalWidth * normalized))

            ZStack(alignment: .leading) {
                LinearGradient(
                    colors: [
                        Color.red.opacity(0.35),
                        Color.orange.opacity(0.35),
                        Color.green.opacity(0.4),
                        Color.orange.opacity(0.35),
                        Color.red.opacity(0.35)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 6)
                .clipShape(.capsule)

                RoundedRectangle(cornerRadius: 3)
                    .fill(status.color)
                    .frame(width: dotX, height: 6)
                    .animation(.spring(response: 0.8, dampingFraction: 0.75), value: normalized)

                Circle()
                    .fill(.white)
                    .frame(width: dotSize, height: dotSize)
                    .shadow(color: status.color.opacity(0.5), radius: 5, y: 2)
                    .overlay(
                        Circle()
                            .fill(status.color)
                            .frame(width: 8, height: 8)
                    )
                    .offset(x: dotX - dotSize / 2)
                    .animation(.spring(response: 0.8, dampingFraction: 0.75), value: normalized)
            }
        }
        .frame(height: 16)
    }
}
