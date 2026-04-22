import SwiftUI

struct WireframeBodyOverlay: View {
    @State private var glowPhase: Bool = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Canvas { context, size in
                drawWireframeBody(context: context, size: size)
            }
            .frame(width: w, height: h)
        }
        .opacity(0.55)
        .allowsHitTesting(false)
        .onAppear { glowPhase = true }
    }

    private func drawWireframeBody(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let cx = w / 2
        let color = Color.white

        let horizontalRows = 28
        let verticalCols = 12

        let headR = w * 0.1
        let headCY = h * 0.065 + headR

        let neckTop = headCY + headR + h * 0.008
        let shoulderY = neckTop + h * 0.035
        let shoulderW = w * 0.42
        let waistY = h * 0.42
        let waistW = w * 0.28
        let hipY = h * 0.50
        let hipW = w * 0.36
        let crotchY = h * 0.55
        let kneeY = h * 0.73
        let ankleY = h * 0.91
        let footY = h * 0.96

        let legOutW = w * 0.13
        let legInW = w * 0.03
        let calfOutW = w * 0.095
        let calfInW = w * 0.025
        let footW = w * 0.10

        func bodyLeftEdge(at y: CGFloat) -> CGFloat {
            if y < neckTop {
                return cx - w * 0.065
            } else if y < shoulderY {
                let t = (y - neckTop) / (shoulderY - neckTop)
                return cx - lerp(w * 0.065, shoulderW / 2, t)
            } else if y < waistY {
                let t = (y - shoulderY) / (waistY - shoulderY)
                let armPull = sin(t * .pi) * w * 0.04
                return cx - lerp(shoulderW / 2, waistW / 2, t) - armPull
            } else if y < hipY {
                let t = (y - waistY) / (hipY - waistY)
                return cx - lerp(waistW / 2, hipW / 2, t)
            } else if y < crotchY {
                let t = (y - hipY) / (crotchY - hipY)
                return cx - lerp(hipW / 2, legOutW + legInW, t)
            } else if y < kneeY {
                let t = (y - crotchY) / (kneeY - crotchY)
                return cx - lerp(legOutW + legInW, legOutW + legInW * 0.8, t)
            } else if y < ankleY {
                let t = (y - kneeY) / (ankleY - kneeY)
                return cx - lerp(calfOutW + calfInW, calfOutW * 0.8, t)
            } else {
                let t = (y - ankleY) / (footY - ankleY)
                return cx - lerp(calfOutW * 0.8, footW, t)
            }
        }

        func bodyRightEdge(at y: CGFloat) -> CGFloat {
            return cx + (cx - bodyLeftEdge(at: y))
        }

        func leftLegLeftEdge(at y: CGFloat) -> CGFloat {
            if y < kneeY {
                let t = (y - crotchY) / (kneeY - crotchY)
                return cx - lerp(legOutW + legInW, legOutW, clamp01(t))
            } else if y < ankleY {
                let t = (y - kneeY) / (ankleY - kneeY)
                return cx - lerp(calfOutW + calfInW, calfOutW * 0.85, t)
            } else {
                let t = (y - ankleY) / (footY - ankleY)
                return cx - lerp(calfOutW * 0.85, footW, t)
            }
        }

        func leftLegRightEdge(at y: CGFloat) -> CGFloat {
            if y < kneeY {
                let t = (y - crotchY) / (kneeY - crotchY)
                return cx - lerp(legInW * 0.3, legInW * 0.5, clamp01(t))
            } else if y < ankleY {
                let t = (y - kneeY) / (ankleY - kneeY)
                return cx - lerp(calfInW * 0.3, calfInW * 0.2, t)
            } else {
                return cx - calfInW * 0.15
            }
        }

        func rightLegLeftEdge(at y: CGFloat) -> CGFloat {
            return cx + (cx - leftLegRightEdge(at: y))
        }

        func rightLegRightEdge(at y: CGFloat) -> CGFloat {
            return cx + (cx - leftLegLeftEdge(at: y))
        }

        let strokeStyle = StrokeStyle(lineWidth: 1.5, lineCap: .round)
        let thinStroke = StrokeStyle(lineWidth: 0.9, lineCap: .round)

        let headSegments = 12
        for i in 0...headSegments {
            let angle = CGFloat(i) / CGFloat(headSegments) * .pi
            let y = headCY - headR * cos(angle)
            let xSpan = headR * sin(angle)
            var path = Path()
            path.move(to: CGPoint(x: cx - xSpan, y: y))
            path.addLine(to: CGPoint(x: cx + xSpan, y: y))
            context.stroke(path, with: .color(color.opacity(0.7)), style: thinStroke)
        }

        let headVLines = 8
        for i in 0...headVLines {
            let angle = CGFloat(i) / CGFloat(headVLines) * .pi - .pi / 2
            var path = Path()
            let steps = 20
            for s in 0...steps {
                let t = CGFloat(s) / CGFloat(steps)
                let theta = t * .pi
                let y = headCY - headR * cos(theta)
                let xSpan = headR * sin(theta)
                let x = cx + xSpan * sin(angle)
                if s == 0 { path.move(to: CGPoint(x: x, y: y)) }
                else { path.addLine(to: CGPoint(x: x, y: y)) }
            }
            context.stroke(path, with: .color(color.opacity(0.5)), style: thinStroke)
        }

        var headOutline = Path()
        headOutline.addEllipse(in: CGRect(x: cx - headR, y: headCY - headR, width: headR * 2, height: headR * 2))
        context.stroke(headOutline, with: .color(color.opacity(0.9)), style: strokeStyle)

        let bodyTop = neckTop
        let bodyBottom = crotchY
        let torsoRows = 16
        for i in 0...torsoRows {
            let t = CGFloat(i) / CGFloat(torsoRows)
            let y = lerp(bodyTop, bodyBottom, t)
            let leftX = bodyLeftEdge(at: y)
            let rightX = bodyRightEdge(at: y)
            var path = Path()
            path.move(to: CGPoint(x: leftX, y: y))
            path.addLine(to: CGPoint(x: rightX, y: y))
            context.stroke(path, with: .color(color.opacity(0.6)), style: thinStroke)
        }

        let torsoCols = 10
        for i in 0...torsoCols {
            let t = CGFloat(i) / CGFloat(torsoCols)
            var path = Path()
            let steps = 30
            for s in 0...steps {
                let st = CGFloat(s) / CGFloat(steps)
                let y = lerp(bodyTop, bodyBottom, st)
                let leftX = bodyLeftEdge(at: y)
                let rightX = bodyRightEdge(at: y)
                let x = lerp(leftX, rightX, t)
                if s == 0 { path.move(to: CGPoint(x: x, y: y)) }
                else { path.addLine(to: CGPoint(x: x, y: y)) }
            }
            context.stroke(path, with: .color(color.opacity(0.5)), style: thinStroke)
        }

        var leftOutline = Path()
        let outlineSteps = 50
        for s in 0...outlineSteps {
            let t = CGFloat(s) / CGFloat(outlineSteps)
            let y = lerp(bodyTop, bodyBottom, t)
            let x = bodyLeftEdge(at: y)
            if s == 0 { leftOutline.move(to: CGPoint(x: x, y: y)) }
            else { leftOutline.addLine(to: CGPoint(x: x, y: y)) }
        }
        context.stroke(leftOutline, with: .color(color.opacity(0.9)), style: strokeStyle)

        var rightOutline = Path()
        for s in 0...outlineSteps {
            let t = CGFloat(s) / CGFloat(outlineSteps)
            let y = lerp(bodyTop, bodyBottom, t)
            let x = bodyRightEdge(at: y)
            if s == 0 { rightOutline.move(to: CGPoint(x: x, y: y)) }
            else { rightOutline.addLine(to: CGPoint(x: x, y: y)) }
        }
        context.stroke(rightOutline, with: .color(color.opacity(0.9)), style: strokeStyle)

        drawLeg(context: context, color: color, strokeStyle: strokeStyle, thinStroke: thinStroke,
                leftEdge: leftLegLeftEdge, rightEdge: leftLegRightEdge,
                top: crotchY, bottom: footY)

        drawLeg(context: context, color: color, strokeStyle: strokeStyle, thinStroke: thinStroke,
                leftEdge: rightLegLeftEdge, rightEdge: rightLegRightEdge,
                top: crotchY, bottom: footY)

        let armTop = shoulderY
        let armBottom = hipY + h * 0.06
        let armSegments = 14
        drawArm(context: context, color: color, strokeStyle: strokeStyle, thinStroke: thinStroke,
                cx: cx, w: w, h: h, side: -1,
                shoulderW: shoulderW, armTop: armTop, armBottom: armBottom, segments: armSegments)
        drawArm(context: context, color: color, strokeStyle: strokeStyle, thinStroke: thinStroke,
                cx: cx, w: w, h: h, side: 1,
                shoulderW: shoulderW, armTop: armTop, armBottom: armBottom, segments: armSegments)
    }

    private func drawLeg(context: GraphicsContext, color: Color, strokeStyle: StrokeStyle, thinStroke: StrokeStyle,
                         leftEdge: (CGFloat) -> CGFloat, rightEdge: (CGFloat) -> CGFloat,
                         top: CGFloat, bottom: CGFloat) {
        let rows = 12
        for i in 0...rows {
            let t = CGFloat(i) / CGFloat(rows)
            let y = lerp(top, bottom, t)
            let lx = leftEdge(y)
            let rx = rightEdge(y)
            var path = Path()
            path.move(to: CGPoint(x: lx, y: y))
            path.addLine(to: CGPoint(x: rx, y: y))
            context.stroke(path, with: .color(color.opacity(0.5)), style: thinStroke)
        }

        let cols = 4
        for i in 0...cols {
            let ct = CGFloat(i) / CGFloat(cols)
            var path = Path()
            let steps = 24
            for s in 0...steps {
                let st = CGFloat(s) / CGFloat(steps)
                let y = lerp(top, bottom, st)
                let lx = leftEdge(y)
                let rx = rightEdge(y)
                let x = lerp(lx, rx, ct)
                if s == 0 { path.move(to: CGPoint(x: x, y: y)) }
                else { path.addLine(to: CGPoint(x: x, y: y)) }
            }
            context.stroke(path, with: .color(color.opacity(0.4)), style: thinStroke)
        }

        var leftPath = Path()
        var rightPath = Path()
        let steps = 30
        for s in 0...steps {
            let t = CGFloat(s) / CGFloat(steps)
            let y = lerp(top, bottom, t)
            let lx = leftEdge(y)
            let rx = rightEdge(y)
            if s == 0 {
                leftPath.move(to: CGPoint(x: lx, y: y))
                rightPath.move(to: CGPoint(x: rx, y: y))
            } else {
                leftPath.addLine(to: CGPoint(x: lx, y: y))
                rightPath.addLine(to: CGPoint(x: rx, y: y))
            }
        }
        context.stroke(leftPath, with: .color(color.opacity(0.8)), style: strokeStyle)
        context.stroke(rightPath, with: .color(color.opacity(0.8)), style: strokeStyle)
    }

    private func drawArm(context: GraphicsContext, color: Color, strokeStyle: StrokeStyle, thinStroke: StrokeStyle,
                         cx: CGFloat, w: CGFloat, h: CGFloat, side: CGFloat,
                         shoulderW: CGFloat, armTop: CGFloat, armBottom: CGFloat, segments: Int) {
        let shoulderX = cx + side * shoulderW / 2
        let elbowY = lerp(armTop, armBottom, 0.5)
        let elbowX = shoulderX + side * w * 0.03
        let wristY = armBottom
        let wristX = shoulderX + side * w * 0.01
        let armWidth = w * 0.055

        func armCenter(at t: CGFloat) -> CGPoint {
            if t < 0.5 {
                let lt = t / 0.5
                let x = lerp(shoulderX, elbowX, lt)
                let y = lerp(armTop, elbowY, lt)
                return CGPoint(x: x, y: y)
            } else {
                let lt = (t - 0.5) / 0.5
                let x = lerp(elbowX, wristX, lt)
                let y = lerp(elbowY, wristY, lt)
                return CGPoint(x: x, y: y)
            }
        }

        func armWidthAt(t: CGFloat) -> CGFloat {
            let taper: CGFloat
            if t < 0.3 {
                taper = lerp(1.0, 0.85, t / 0.3)
            } else if t < 0.7 {
                taper = lerp(0.85, 0.75, (t - 0.3) / 0.4)
            } else {
                taper = lerp(0.75, 0.5, (t - 0.7) / 0.3)
            }
            return armWidth * taper
        }

        let rows = segments
        for i in 0...rows {
            let t = CGFloat(i) / CGFloat(rows)
            let center = armCenter(at: t)
            let halfW = armWidthAt(t: t)
            var path = Path()
            path.move(to: CGPoint(x: center.x - halfW, y: center.y))
            path.addLine(to: CGPoint(x: center.x + halfW, y: center.y))
            context.stroke(path, with: .color(color.opacity(0.5)), style: thinStroke)
        }

        for col in 0...3 {
            let ct = CGFloat(col) / 3.0
            var path = Path()
            let steps = 24
            for s in 0...steps {
                let t = CGFloat(s) / CGFloat(steps)
                let center = armCenter(at: t)
                let halfW = armWidthAt(t: t)
                let x = lerp(center.x - halfW, center.x + halfW, ct)
                if s == 0 { path.move(to: CGPoint(x: x, y: center.y)) }
                else { path.addLine(to: CGPoint(x: x, y: center.y)) }
            }
            context.stroke(path, with: .color(color.opacity(0.4)), style: thinStroke)
        }

        var leftArmPath = Path()
        var rightArmPath = Path()
        let steps = 30
        for s in 0...steps {
            let t = CGFloat(s) / CGFloat(steps)
            let center = armCenter(at: t)
            let halfW = armWidthAt(t: t)
            if s == 0 {
                leftArmPath.move(to: CGPoint(x: center.x - halfW, y: center.y))
                rightArmPath.move(to: CGPoint(x: center.x + halfW, y: center.y))
            } else {
                leftArmPath.addLine(to: CGPoint(x: center.x - halfW, y: center.y))
                rightArmPath.addLine(to: CGPoint(x: center.x + halfW, y: center.y))
            }
        }
        context.stroke(leftArmPath, with: .color(color.opacity(0.8)), style: strokeStyle)
        context.stroke(rightArmPath, with: .color(color.opacity(0.8)), style: strokeStyle)
    }

    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + (b - a) * t
    }

    private func clamp01(_ t: CGFloat) -> CGFloat {
        min(max(t, 0), 1)
    }
}
