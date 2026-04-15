import SwiftUI

struct WellnessAuraView: View {
    let mood: WellnessMood

    private var auraStyle: AuraStyle {
        switch mood {
        case .excellent, .good: return .smooth
        case .fair: return .gentle
        case .poor: return .wild
        }
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let cx = size.width / 2
                let cy = size.height / 2
                let baseR = size.width * 0.23

                for i in 0..<4 {
                    let di = Double(i)
                    let ringR = baseR + di * 10.4
                    let opacity = 0.28
                    let lineW = 1.5

                    switch auraStyle {
                    case .smooth:
                        let pulsePhase = t * 1.2 + di * 0.5
                        let pulse = sin(pulsePhase) * 2.0
                        let r = ringR + pulse
                        let rect = CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)
                        context.stroke(
                            Path(ellipseIn: rect),
                            with: .color(mood.color.opacity(opacity)),
                            lineWidth: lineW
                        )

                    case .gentle:
                        let wavePhase = t * 1.0 + di * 0.6
                        let waveAmp = 2.5 + di * 0.8
                        let waveFreq = 5.0 + di * 0.8
                        var path = Path()
                        let steps = 140
                        for j in 0...steps {
                            let angle = Double(j) / Double(steps) * 2.0 * .pi
                            let wave = waveAmp * sin(waveFreq * angle + wavePhase)
                            let r = ringR + wave
                            let x = cx + r * cos(angle)
                            let y = cy + r * sin(angle)
                            if j == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        path.closeSubpath()
                        context.stroke(
                            path,
                            with: .color(mood.color.opacity(opacity)),
                            lineWidth: lineW
                        )

                    case .wild:
                        let wavePhase = t * 1.6 + di * 0.4
                        let waveAmp = 5.0 + di * 1.5
                        let waveFreq = 7.0 + di * 1.0
                        var path = Path()
                        let steps = 140
                        for j in 0...steps {
                            let angle = Double(j) / Double(steps) * 2.0 * .pi
                            let wave = waveAmp * sin(waveFreq * angle + wavePhase)
                            let r = ringR + wave
                            let x = cx + r * cos(angle)
                            let y = cy + r * sin(angle)
                            if j == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        path.closeSubpath()
                        context.stroke(
                            path,
                            with: .color(mood.color.opacity(opacity)),
                            lineWidth: lineW
                        )
                    }
                }
            }
        }
    }

    private enum AuraStyle { case smooth, gentle, wild }
}

struct WellnessMoodLabel: View {
    let mood: WellnessMood
    @State private var appear = false

    var body: some View {
        Text(mood.moodLabel)
            .font(.system(size: 11, weight: .bold, design: .rounded))
        .foregroundStyle(mood.color)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(mood.color.opacity(0.10))
        .clipShape(.capsule)
        .opacity(appear ? 1 : 0)
        .scaleEffect(appear ? 1 : 0.85)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                appear = true
            }
        }
        .onChange(of: mood) { _, _ in
            appear = false
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                appear = true
            }
        }
    }
}
