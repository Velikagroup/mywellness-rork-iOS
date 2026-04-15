import SwiftUI

@available(iOS 18.0, *)
struct AnimatedMeshBackground: View {

    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate
            let t1 = now * 0.28
            let t2 = now * 0.19
            let t3 = now * 0.23
            MeshGradient(
                width: 3,
                height: 3,
                points: computePoints(t1: t1, t2: t2, t3: t3),
                colors: computeColors(t1: t1, t2: t2, t3: t3),
                smoothsColors: true
            )
            .ignoresSafeArea()
        }
    }

    private func computePoints(t1: Double, t2: Double, t3: Double) -> [SIMD2<Float>] {
        let s1 = Float(sin(t1))
        let c1 = Float(cos(t1))
        let s2 = Float(sin(t2))
        let c2 = Float(cos(t2))
        let s3 = Float(sin(t3))
        let c3 = Float(cos(t3))
        return [
            [0.0,  0.0],
            [0.5 + 0.05 * s1,  0.0],
            [1.0,  0.0],
            [0.0,  0.5 + 0.06 * c2],
            [0.5 + 0.08 * s2,  0.5 + 0.07 * c1],
            [1.0,  0.5 + 0.06 * s3],
            [0.0,  1.0],
            [0.5 + 0.05 * c3,  1.0],
            [1.0,  1.0]
        ]
    }

    private func computeColors(t1: Double, t2: Double, t3: Double) -> [Color] {
        let p1 = (sin(t1) + 1) / 2
        let p2 = (sin(t2 * 0.7 + 1.2) + 1) / 2
        let p3 = (sin(t3 * 0.5 + 2.4) + 1) / 2
        let p4 = (cos(t1 * 0.8 + 0.5) + 1) / 2

        let palette: [(r1: Double, g1: Double, b1: Double, r2: Double, g2: Double, b2: Double)] = [
            (0.72, 0.86, 0.95,   0.55, 0.78, 0.94),
            (0.88, 0.95, 0.97,   0.62, 0.86, 0.97),
            (0.65, 0.88, 0.82,   0.52, 0.80, 0.90),
            (0.68, 0.88, 0.92,   0.76, 0.92, 0.84),
            (0.85, 0.92, 0.97,   0.70, 0.86, 0.90),
            (0.66, 0.87, 0.82,   0.58, 0.91, 0.87),
            (0.58, 0.84, 0.80,   0.68, 0.87, 0.95),
            (0.92, 0.90, 0.96,   0.74, 0.84, 0.95),
            (0.91, 0.88, 0.95,   0.62, 0.82, 0.93)
        ]

        let ts = [p1, p2, p3, p4, p1, p2, p3, p4, p1]

        var result: [Color] = []
        for (idx, c) in palette.enumerated() {
            let t = ts[idx]
            let r = c.r1 + (c.r2 - c.r1) * t
            let g = c.g1 + (c.g2 - c.g1) * t
            let b = c.b1 + (c.b2 - c.b1) * t
            result.append(Color(red: r, green: g, blue: b))
        }
        return result
    }
}
