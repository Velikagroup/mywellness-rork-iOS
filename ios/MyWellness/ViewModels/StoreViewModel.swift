import Foundation
import RevenueCat
import Observation

@Observable
@MainActor
class StoreViewModel {
    var offerings: Offerings?
    var isPremium: Bool = false
    var isLoading: Bool = false
    var isPurchasing: Bool = false
    var error: String?

    init() {
        Task { await listenForUpdates() }
        Task { await fetchOfferings() }
    }

    private func listenForUpdates() async {
        for await info in Purchases.shared.customerInfoStream {
            self.isPremium = info.entitlements["premium"]?.isActive == true
        }
    }

    func fetchOfferings() async {
        isLoading = true
        do {
            offerings = try await Purchases.shared.offerings()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func purchase(package: Package) async {
        isPurchasing = true
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if !result.userCancelled {
                isPremium = result.customerInfo.entitlements["premium"]?.isActive == true
            }
        } catch ErrorCode.purchaseCancelledError {
        } catch ErrorCode.paymentPendingError {
        } catch {
            self.error = error.localizedDescription
        }
        isPurchasing = false
    }

    func purchaseMonthly() async {
        if offerings == nil {
            await fetchOfferings()
        }
        guard let monthly = offerings?.current?.monthly else {
            self.error = "Unable to load subscription. Please try again."
            return
        }
        await purchase(package: monthly)
    }

    func purchaseYearly() async {
        if offerings == nil {
            await fetchOfferings()
        }
        guard let annual = offerings?.current?.annual else {
            self.error = "Unable to load subscription. Please try again."
            return
        }
        await purchase(package: annual)
    }

    func presentCodeRedemption() {
        Purchases.shared.presentCodeRedemptionSheet()
    }

    func restore() async {
        do {
            let info = try await Purchases.shared.restorePurchases()
            isPremium = info.entitlements["premium"]?.isActive == true
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Localized Prices (from App Store / RevenueCat)

    var monthlyPackage: Package? { offerings?.current?.monthly }
    var yearlyPackage: Package? { offerings?.current?.annual }

    /// Full localized price for the monthly plan (e.g. "€9.99", "$9.99").
    var monthlyPriceString: String? {
        monthlyPackage?.storeProduct.localizedPriceString
    }

    /// Full localized price for the yearly plan (e.g. "€49.99").
    var yearlyPriceString: String? {
        yearlyPackage?.storeProduct.localizedPriceString
    }

    /// Yearly price divided by 12, localized to the product's currency.
    var yearlyPricePerMonthString: String? {
        guard let product = yearlyPackage?.storeProduct,
              let formatter = product.priceFormatter else { return nil }
        let perMonth = NSDecimalNumber(decimal: product.price / 12)
        return formatter.string(from: perMonth)
    }

    /// Monthly price localized (same as monthlyPriceString but kept for symmetry).
    var monthlyPricePerMonthString: String? {
        monthlyPriceString
    }
}
