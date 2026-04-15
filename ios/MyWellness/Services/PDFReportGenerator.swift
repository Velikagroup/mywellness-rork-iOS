import UIKit
import Foundation

nonisolated struct PDFReportGenerator: Sendable {

    private let pageWidth: CGFloat = 595
    private let pageHeight: CGFloat = 842
    private let margin: CGFloat = 48
    private var contentWidth: CGFloat { pageWidth - margin * 2 }

    private let profile: UserProfile
    private let snapshots: [DaySnapshot]
    private let weightHistory: [WeightEntry]
    private let rangeName: String

    init(profile: UserProfile, snapshots: [DaySnapshot], weightHistory: [WeightEntry], rangeName: String) {
        self.profile = profile
        self.snapshots = snapshots.sorted { $0.date < $1.date }
        self.weightHistory = weightHistory.sorted { $0.date < $1.date }
        self.rangeName = rangeName
    }

    func generate() -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        return renderer.pdfData { ctx in
            var y: CGFloat = 0

            func startPage() {
                ctx.beginPage()
                y = margin
                drawHeader(y: &y)
            }

            func checkPageBreak(needed: CGFloat) {
                if y + needed > pageHeight - margin {
                    startPage()
                }
            }

            startPage()
            drawProfileSection(y: &y, checkBreak: checkPageBreak)
            drawSectionTitle(Lang.s("pdf_period_summary"), y: &y, checkBreak: checkPageBreak)
            drawSummaryCards(y: &y, checkBreak: checkPageBreak)
            drawSectionTitle(Lang.s("pdf_weight_progress_title"), y: &y, checkBreak: checkPageBreak)
            drawWeightTable(y: &y, checkBreak: checkPageBreak)
            drawSectionTitle(Lang.s("pdf_daily_trends_title"), y: &y, checkBreak: checkPageBreak)
            drawDailyTable(y: &y, checkBreak: checkPageBreak)
            drawFooter()
        }
    }

    private func drawHeader(y: inout CGFloat) {
        let accentColor = UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1)

        let appName = "MyWellness"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: accentColor
        ]
        appName.draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)

        let dateStr = "\(Lang.s("pdf_generated_on")) \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))"
        let dateAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let dateSize = dateStr.size(withAttributes: dateAttrs)
        dateStr.draw(at: CGPoint(x: pageWidth - margin - dateSize.width, y: y + 5), withAttributes: dateAttrs)

        y += 28

        let rangeAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let rangeStr = "\(Lang.s("pdf_period")): \(rangeName)"
        rangeStr.draw(at: CGPoint(x: margin, y: y), withAttributes: rangeAttrs)
        y += 18

        UIColor.separator.setFill()
        UIBezierPath(rect: CGRect(x: margin, y: y, width: contentWidth, height: 0.5)).fill()
        y += 16
    }

    private func drawFooter() {
        let text = "\(Lang.s("pdf_auto_report")) · \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none))"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8, weight: .regular),
            .foregroundColor: UIColor.tertiaryLabel
        ]
        let size = text.size(withAttributes: attrs)
        text.draw(at: CGPoint(x: (pageWidth - size.width) / 2, y: pageHeight - 28), withAttributes: attrs)
    }

    private func drawProfileSection(y: inout CGFloat, checkBreak: (CGFloat) -> Void) {
        checkBreak(100)
        let boxH: CGFloat = 88
        let boxRect = CGRect(x: margin, y: y, width: contentWidth, height: boxH)
        UIColor.systemGray6.setFill()
        UIBezierPath(roundedRect: boxRect, cornerRadius: 10).fill()

        let nameAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        let nameStr = profile.name.isEmpty ? "User" : profile.name
        nameStr.draw(at: CGPoint(x: margin + 16, y: y + 14), withAttributes: nameAttrs)

        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let sub = "\(profile.goal.rawValue) · \(profile.gender.rawValue) · \(profile.age) yrs · \(profile.activityLevel.rawValue)"
        sub.draw(at: CGPoint(x: margin + 16, y: y + 34), withAttributes: subAttrs)

        let statAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .medium),
            .foregroundColor: UIColor.label
        ]

        let useMetric = profile.isMetric
        let weightUnit = useMetric ? "kg" : "lbs"
        let currentW = useMetric ? profile.currentWeightKg : profile.currentWeightKg * 2.20462
        let targetW = useMetric ? profile.targetWeightKg : profile.targetWeightKg * 2.20462

        let stats: [(String, String)] = [
            (Lang.s("pdf_current_weight"), String(format: "%.1f %@", currentW, weightUnit)),
            (Lang.s("pdf_target_label"), String(format: "%.1f %@", targetW, weightUnit)),
            ("BMI", String(format: "%.1f", profile.bmi)),
            ("Kcal/day", "\(Int(profile.dailyCalorieTarget))")
        ]

        let colW = contentWidth / CGFloat(stats.count)
        for (i, stat) in stats.enumerated() {
            let x = margin + CGFloat(i) * colW
            let labelAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9, weight: .regular),
                .foregroundColor: UIColor.secondaryLabel
            ]
            stat.0.draw(at: CGPoint(x: x + 16, y: y + 54), withAttributes: labelAttrs)
            stat.1.draw(at: CGPoint(x: x + 16, y: y + 67), withAttributes: statAttrs)
        }

        y += boxH + 20
    }

    private func drawSectionTitle(_ title: String, y: inout CGFloat, checkBreak: (CGFloat) -> Void) {
        checkBreak(30)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        title.draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)
        y += 20
    }

    private func drawSummaryCards(y: inout CGFloat, checkBreak: (CGFloat) -> Void) {
        checkBreak(80)
        guard !snapshots.isEmpty else {
            drawNoData(y: &y)
            return
        }

        let total = snapshots.count
        let avgCalIn = snapshots.map { $0.caloriesConsumed }.reduce(0, +) / total
        let avgCalOut = snapshots.map { $0.caloriesBurned }.reduce(0, +) / total
        let avgProtein = snapshots.map { $0.proteinConsumed }.reduce(0, +) / Double(total)
        let avgCarbs = snapshots.map { $0.carbsConsumed }.reduce(0, +) / Double(total)
        let avgFat = snapshots.map { $0.fatConsumed }.reduce(0, +) / Double(total)

        let cards: [(String, String)] = [
            (Lang.s("pdf_tracked_days"), "\(total)"),
            (Lang.s("pdf_avg_kcal_consumed"), "\(avgCalIn)"),
            (Lang.s("pdf_avg_kcal_burned"), "\(avgCalOut)"),
            (Lang.s("pdf_avg_protein"), String(format: "%.0fg", avgProtein)),
            (Lang.s("pdf_avg_carbs"), String(format: "%.0fg", avgCarbs)),
            (Lang.s("pdf_avg_fat"), String(format: "%.0fg", avgFat))
        ]

        let cardW = (contentWidth - 12) / 3
        let cardH: CGFloat = 60

        for row in 0..<2 {
            for col in 0..<3 {
                let idx = row * 3 + col
                guard idx < cards.count else { continue }
                let card = cards[idx]
                let x = margin + CGFloat(col) * (cardW + 6)
                let cy = y + CGFloat(row) * (cardH + 8)
                let rect = CGRect(x: x, y: cy, width: cardW, height: cardH)
                UIColor.systemGray6.setFill()
                UIBezierPath(roundedRect: rect, cornerRadius: 8).fill()

                let labelAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 8, weight: .regular),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let valueAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                    .foregroundColor: UIColor.label
                ]
                card.0.draw(at: CGPoint(x: x + 10, y: cy + 10), withAttributes: labelAttrs)
                card.1.draw(at: CGPoint(x: x + 10, y: cy + 28), withAttributes: valueAttrs)
            }
        }

        y += 2 * (cardH + 8) + 12
    }

    private func drawWeightTable(y: inout CGFloat, checkBreak: (CGFloat) -> Void) {
        let entries = Array(weightHistory.prefix(20))
        guard !entries.isEmpty else {
            drawNoData(y: &y)
            return
        }

        let useMetric = profile.isMetric
        let weightUnit = useMetric ? "kg" : "lbs"
        let headers = [Lang.s("pdf_date"), "\(Lang.s("pdf_weight_col")) (\(weightUnit))"]
        let colWidths: [CGFloat] = [contentWidth * 0.6, contentWidth * 0.4]

        drawTableHeader(headers: headers, colWidths: colWidths, y: &y)

        for entry in entries {
            checkPageBreak(needed: 22, y: y, checkBreak: checkBreak)
            let dateStr = DateFormatter.localizedString(from: entry.date, dateStyle: .medium, timeStyle: .none)
            let w = useMetric ? entry.weightKg : entry.weightKg * 2.20462
            drawTableRow(cells: [dateStr, String(format: "%.1f", w)], colWidths: colWidths, y: &y)
        }
        y += 16
    }

    private func drawDailyTable(y: inout CGFloat, checkBreak: (CGFloat) -> Void) {
        guard !snapshots.isEmpty else {
            drawNoData(y: &y)
            return
        }

        let headers = [Lang.s("pdf_date"), Lang.s("pdf_kcal_in"), Lang.s("pdf_kcal_out"), Lang.s("protein"), Lang.s("carbs"), Lang.s("fat")]
        let colWidths: [CGFloat] = [
            contentWidth * 0.22,
            contentWidth * 0.14,
            contentWidth * 0.14,
            contentWidth * 0.17,
            contentWidth * 0.17,
            contentWidth * 0.16
        ]

        drawTableHeader(headers: headers, colWidths: colWidths, y: &y)

        for snap in snapshots.prefix(30) {
            checkPageBreak(needed: 22, y: y, checkBreak: checkBreak)
            let dateStr = DateFormatter.localizedString(from: snap.date, dateStyle: .short, timeStyle: .none)
            let cells = [
                dateStr,
                "\(snap.caloriesConsumed)",
                "\(snap.caloriesBurned)",
                String(format: "%.0fg", snap.proteinConsumed),
                String(format: "%.0fg", snap.carbsConsumed),
                String(format: "%.0fg", snap.fatConsumed)
            ]
            drawTableRow(cells: cells, colWidths: colWidths, y: &y)
        }
        y += 16
    }

    private func checkPageBreak(needed: CGFloat, y: CGFloat, checkBreak: (CGFloat) -> Void) {
        checkBreak(needed)
    }

    private func drawTableHeader(headers: [String], colWidths: [CGFloat], y: inout CGFloat) {
        UIColor.systemGray5.setFill()
        UIBezierPath(rect: CGRect(x: margin, y: y, width: contentWidth, height: 22)).fill()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
            .foregroundColor: UIColor.secondaryLabel
        ]
        var x = margin
        for (i, header) in headers.enumerated() {
            header.draw(at: CGPoint(x: x + 6, y: y + 6), withAttributes: attrs)
            x += colWidths[i]
        }
        y += 22
    }

    private func drawTableRow(cells: [String], colWidths: [CGFloat], y: inout CGFloat) {
        UIColor.separator.withAlphaComponent(0.3).setFill()
        UIBezierPath(rect: CGRect(x: margin, y: y + 21, width: contentWidth, height: 0.5)).fill()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: UIColor.label
        ]
        var x = margin
        for (i, cell) in cells.enumerated() {
            cell.draw(at: CGPoint(x: x + 6, y: y + 6), withAttributes: attrs)
            x += colWidths[i]
        }
        y += 22
    }

    private func drawNoData(y: inout CGFloat) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.tertiaryLabel
        ]
        Lang.s("pdf_no_data_period_long").draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)
        y += 24
    }
}
