import SwiftUI

struct HumanSilhouetteShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let cx = w / 2

        let headRadius = w * 0.12
        let headCY = h * 0.06 + headRadius
        path.addEllipse(in: CGRect(
            x: cx - headRadius,
            y: headCY - headRadius,
            width: headRadius * 2,
            height: headRadius * 2
        ))

        let neckTop = headCY + headRadius + h * 0.01
        let neckW = w * 0.07
        let shoulderY = neckTop + h * 0.04
        let shoulderW = w * 0.44
        let chestY = shoulderY + h * 0.02
        let torsoNarrow = w * 0.32
        let waistY = h * 0.42
        let hipW = w * 0.38
        let hipY = h * 0.48
        let crotchY = h * 0.54
        let kneeY = h * 0.72
        let ankleY = h * 0.90
        let footY = h * 0.95
        let legW = w * 0.13
        let calfW = w * 0.10
        let footW = w * 0.11

        path.move(to: CGPoint(x: cx - neckW, y: neckTop))

        path.addQuadCurve(
            to: CGPoint(x: cx - shoulderW, y: shoulderY),
            control: CGPoint(x: cx - shoulderW * 0.6, y: neckTop)
        )

        path.addQuadCurve(
            to: CGPoint(x: cx - shoulderW + w * 0.04, y: chestY + h * 0.06),
            control: CGPoint(x: cx - shoulderW - w * 0.02, y: shoulderY + h * 0.02)
        )

        path.addQuadCurve(
            to: CGPoint(x: cx - torsoNarrow / 2, y: waistY),
            control: CGPoint(x: cx - shoulderW + w * 0.06, y: waistY - h * 0.04)
        )

        path.addQuadCurve(
            to: CGPoint(x: cx - hipW / 2, y: hipY),
            control: CGPoint(x: cx - hipW / 2 - w * 0.02, y: waistY + h * 0.02)
        )

        path.addLine(to: CGPoint(x: cx - legW, y: crotchY))

        path.addQuadCurve(
            to: CGPoint(x: cx - legW - w * 0.01, y: kneeY),
            control: CGPoint(x: cx - legW - w * 0.02, y: (crotchY + kneeY) / 2)
        )

        path.addQuadCurve(
            to: CGPoint(x: cx - calfW, y: ankleY),
            control: CGPoint(x: cx - calfW - w * 0.02, y: (kneeY + ankleY) / 2)
        )

        path.addQuadCurve(
            to: CGPoint(x: cx - footW, y: footY),
            control: CGPoint(x: cx - calfW - w * 0.01, y: ankleY + h * 0.02)
        )

        path.addLine(to: CGPoint(x: cx - footW + w * 0.01, y: h * 0.98))

        path.addLine(to: CGPoint(x: cx - w * 0.02, y: h * 0.98))
        path.addLine(to: CGPoint(x: cx - w * 0.02, y: footY))

        path.addQuadCurve(
            to: CGPoint(x: cx, y: crotchY + h * 0.02),
            control: CGPoint(x: cx - w * 0.02, y: crotchY + h * 0.06)
        )

        path.addQuadCurve(
            to: CGPoint(x: cx + w * 0.02, y: footY),
            control: CGPoint(x: cx + w * 0.02, y: crotchY + h * 0.06)
        )

        path.addLine(to: CGPoint(x: cx + w * 0.02, y: h * 0.98))
        path.addLine(to: CGPoint(x: cx + footW - w * 0.01, y: h * 0.98))

        path.addLine(to: CGPoint(x: cx + footW, y: footY))

        path.addQuadCurve(
            to: CGPoint(x: cx + calfW, y: ankleY),
            control: CGPoint(x: cx + calfW + w * 0.01, y: ankleY + h * 0.02)
        )

        path.addQuadCurve(
            to: CGPoint(x: cx + legW + w * 0.01, y: kneeY),
            control: CGPoint(x: cx + calfW + w * 0.02, y: (kneeY + ankleY) / 2)
        )

        path.addQuadCurve(
            to: CGPoint(x: cx + legW, y: crotchY),
            control: CGPoint(x: cx + legW + w * 0.02, y: (crotchY + kneeY) / 2)
        )

        path.addLine(to: CGPoint(x: cx + hipW / 2, y: hipY))

        path.addQuadCurve(
            to: CGPoint(x: cx + torsoNarrow / 2, y: waistY),
            control: CGPoint(x: cx + hipW / 2 + w * 0.02, y: waistY + h * 0.02)
        )

        path.addQuadCurve(
            to: CGPoint(x: cx + shoulderW - w * 0.04, y: chestY + h * 0.06),
            control: CGPoint(x: cx + shoulderW - w * 0.06, y: waistY - h * 0.04)
        )

        path.addQuadCurve(
            to: CGPoint(x: cx + shoulderW, y: shoulderY),
            control: CGPoint(x: cx + shoulderW + w * 0.02, y: shoulderY + h * 0.02)
        )

        path.addQuadCurve(
            to: CGPoint(x: cx + neckW, y: neckTop),
            control: CGPoint(x: cx + shoulderW * 0.6, y: neckTop)
        )

        path.closeSubpath()

        return path
    }
}
