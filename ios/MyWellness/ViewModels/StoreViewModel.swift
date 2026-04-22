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
        defer { isPurchasing = false }
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if !result.userCancelled {
                isPremium = result.customerInfo.entitlements["premium"]?.isActive == true
            }
        } catch ErrorCode.purchaseCancelledError {
            // user canceled — nothing to do
        } catch ErrorCode.paymentPendingError {
            // awaiting parental approval or SCA — not a failure
        } catch ErrorCode.productAlreadyPurchasedError {
            // already subscribed on this Apple ID — auto-restore
            do {
                let info = try await Purchases.shared.restorePurchases()
                isPremium = info.entitlements["premium"]?.isActive == true
                if !isPremium {
                    self.error = "You already have an active subscription. Try Restore Purchases."
                }
            } catch {
                self.error = "You already have an active subscription. Try Restore Purchases."
            }
        } catch ErrorCode.receiptAlreadyInUseError {
            self.error = "This subscription is already in use by another Apple ID. Please sign in with the correct account."
        } catch ErrorCode.ineligibleError {
            self.error = "You are not eligible for this offer."
        } catch ErrorCode.storeProblemError {
            self.error = "The App Store is temporarily unavailable. Please try again in a moment."
        } catch ErrorCode.networkError {
            self.error = "Network error. Check your connection and try again."
        } catch {
            self.error = error.localizedDescription
        }
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
