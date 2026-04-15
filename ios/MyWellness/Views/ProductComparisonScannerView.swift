import SwiftUI

nonisolated struct ScannedProduct: Identifiable, Sendable {
    let id: UUID = UUID()
    let barcode: String
    let name: String
    let brand: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugars: Double
    let saturatedFat: Double
    let salt: Double
    let servingSize: String
    let qualityScore: Int

    var qualityLabel: String {
        switch qualityScore {
        case 80...100: return Lang.s("excellent")
        case 60..<80: return Lang.s("good")
        case 40..<60: return Lang.s("average")
        case 20..<40: return Lang.s("poor")
        default: return Lang.s("very_poor")
        }
    }

    var qualityColor: Color {
        switch qualityScore {
        case 80...100: return .green
        case 60..<80: return .blue
        case 40..<60: return .orange
        default: return .red
        }
    }
}

struct ProductComparisonScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    let itemName: String

    @State private var scannedProducts: [ScannedProduct] = []
    @State private var isScanning: Bool = false
    @State private var isLookingUp: Bool = false
    @State private var errorMessage: String?
    @State private var showBarcodeScanner: Bool = false

    private var bestProduct: ScannedProduct? {
        scannedProducts.max(by: { $0.qualityScore < $1.qualityScore })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        headerCard
                        scanButton

                        if let error = errorMessage {
                            errorBanner(error)
                        }

                        if isLookingUp {
                            lookingUpView
                        }

                        if !scannedProducts.isEmpty {
                            comparisonSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.wellnessTeal)
                        Text(Lang.s("product_comparison"))
                            .font(.headline)
                    }
                }
            }
            .fullScreenCover(isPresented: $showBarcodeScanner) {
                BarcodeScannerView { barcode in
                    showBarcodeScanner = false
                    handleBarcodeScanned(barcode)
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "scalemass.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.wellnessTeal)
                .padding(.bottom, 2)

            Text(Lang.s("compare_products_title"))
                .font(.title3.weight(.bold))
                .multilineTextAlignment(.center)

            Text(Lang.s("compare_products_desc"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if !itemName.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "cart.fill")
                        .font(.caption)
                    Text(itemName)
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(Color.wellnessTeal)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.wellnessTeal.opacity(0.1))
                .clipShape(.capsule)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var scanButton: some View {
        Button {
            showBarcodeScanner = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "barcode.viewfinder")
                    .font(.title3.weight(.semibold))
                VStack(alignment: .leading, spacing: 2) {
                    Text(Lang.s("scan_new_product"))
                        .font(.subheadline.weight(.semibold))
                    Text(scannedProducts.isEmpty ? Lang.s("scan_first_product_hint") : Lang.s("scan_another_hint"))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(Color.wellnessTeal)
            .clipShape(.rect(cornerRadius: 14))
        }
        .disabled(isLookingUp)
        .opacity(isLookingUp ? 0.6 : 1)
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                withAnimation { errorMessage = nil }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background(.orange.opacity(0.08))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var lookingUpView: some View {
        HStack(spacing: 14) {
            ProgressView()
            Text(Lang.s("looking_up_product"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(16)
        .background(.white)
        .clipShape(.rect(cornerRadius: 14))
    }

    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(Lang.s("scanned_products_count").replacingOccurrences(of: "%d", with: "\(scannedProducts.count)"))
                    .font(.headline)
                Spacer()
                if scannedProducts.count > 1 {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                        Text(Lang.s("best_choice"))
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.green)
                }
            }

            ForEach(scannedProducts) { product in
                productCard(product, isBest: product.id == bestProduct?.id && scannedProducts.count > 1)
            }
        }
    }

    private func productCard(_ product: ScannedProduct, isBest: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(product.qualityColor.opacity(0.12))
                        .frame(width: 50, height: 50)
                    Text("\(product.qualityScore)")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(product.qualityColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(product.name)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(2)
                        if isBest {
                            Image(systemName: "crown.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                        }
                    }
                    if !product.brand.isEmpty {
                        Text(product.brand)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(product.qualityLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(product.qualityColor)
                        .clipShape(.capsule)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(product.calories)")
                            .font(.title3.weight(.bold))
                        Text("kcal")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Text(product.servingSize)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(14)

            Divider().padding(.horizontal, 14)

            HStack(spacing: 8) {
                miniMacroPill(label: Lang.s("protein"), value: product.protein, color: Color.wellnessTeal)
                miniMacroPill(label: Lang.s("carbs"), value: product.carbs, color: .orange)
                miniMacroPill(label: Lang.s("fat"), value: product.fat, color: Color(red: 0.72, green: 0.08, blue: 0.08))
                miniMacroPill(label: Lang.s("fiber"), value: product.fiber, color: .green)
                miniMacroPill(label: Lang.s("sugars"), value: product.sugars, color: .purple)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Button(role: .destructive) {
                withAnimation(.spring(response: 0.3)) {
                    scannedProducts.removeAll { $0.id == product.id }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                        .font(.caption2)
                    Text(Lang.s("remove"))
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(.red.opacity(0.7))
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
            }
        }
        .background(isBest ? Color.green.opacity(0.04) : Color.white)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(isBest ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1.5)
        )
    }

    private func miniMacroPill(label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(String(format: "%.1f", value))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.06))
        .clipShape(.rect(cornerRadius: 8))
    }

    private func handleBarcodeScanned(_ barcode: String) {
        guard !isLookingUp else { return }
        if scannedProducts.contains(where: { $0.barcode == barcode }) {
            errorMessage = Lang.s("product_already_scanned")
            return
        }

        isLookingUp = true
        errorMessage = nil

        Task {
            do {
                let result = try await AIService.lookupBarcode(barcode)
                let nutritionResult = NutritionTableResult(
                    productName: result.productName,
                    servingSize: result.servingSize,
                    calories: result.calories,
                    totalFat: result.fat,
                    saturatedFat: result.saturatedFat,
                    carbohydrates: result.carbs,
                    sugars: result.sugars,
                    protein: result.protein,
                    salt: 0,
                    fiber: result.fiber
                )
                let quality = FoodProductScanRecord.computeQuality(from: nutritionResult)
                let scanned = ScannedProduct(
                    barcode: barcode,
                    name: result.productName,
                    brand: result.brand,
                    calories: result.calories,
                    protein: result.protein,
                    carbs: result.carbs,
                    fat: result.fat,
                    fiber: result.fiber,
                    sugars: result.sugars,
                    saturatedFat: result.saturatedFat,
                    salt: 0,
                    servingSize: result.servingSize,
                    qualityScore: quality
                )
                withAnimation(.spring(response: 0.4)) {
                    scannedProducts.append(scanned)
                }
            } catch {
                errorMessage = Lang.s("barcode_not_found")
            }
            isLookingUp = false
        }
    }
}
