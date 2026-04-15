import SwiftUI
import RevenueCat

struct FamilyPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreViewModel.self) private var storeVM
    @State private var isPurchasing: Bool = false
    @State private var isRestoring: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var familyPackage: Package?

    var body: some View {
        VStack(spacing: 0) {
            headerBar(title: nil, onBack: { dismiss() })

            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 220, height: 220)
                        Image(systemName: "figure.2.and.child.holdinghands")
                            .font(.system(size: 80))
                            .foregroundStyle(.primary)
                    }
                    .padding(.top, 20)

                    Text(Lang.s("family_plan_title"))
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 16) {
                        featureRow(icon: "person.2", text: Lang.s("family_feature_members"))
                        featureRow(icon: "camera.viewfinder", text: Lang.s("family_feature_scan"))
                        featureRow(icon: "rectangle.stack.badge.plus", text: Lang.s("family_feature_plans"))
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }

            VStack(spacing: 12) {
                Divider()

                if let pkg = familyPackage {
                    Text(pkg.localizedPriceString + "/year")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text(Lang.s("family_price"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button {
                    Task { await purchaseFamilyPlan() }
                } label: {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black.opacity(0.7))
                            .clipShape(.rect(cornerRadius: 16))
                    } else {
                        Text(Lang.s("switch_family"))
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .clipShape(.rect(cornerRadius: 16))
                    }
                }
                .disabled(isPurchasing || isRestoring)
                .padding(.horizontal, 16)

                HStack(spacing: 8) {
                    Button(Lang.s("terms")) {
                        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Text("•").foregroundStyle(.secondary)

                    Button(Lang.s("privacy")) {
                        if let url = URL(string: "https://www.apple.com/privacy/") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Text("•").foregroundStyle(.secondary)

                    Button(Lang.s("restore")) {
                        Task { await restorePurchases() }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .disabled(isRestoring)
                }
                .padding(.bottom, 8)
            }
        }
        .background(Color(.systemBackground))
        .task {
            await loadFamilyOffering()
        }
        .alert(Lang.s("error"), isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .onChange(of: storeVM.isPremium) { _, isPremium in
            if isPremium { dismiss() }
        }
    }

    private func loadFamilyOffering() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            if let familyOffering = offerings.offering(identifier: "family") {
                familyPackage = familyOffering.annual
            }
        } catch {}
    }

    private func purchaseFamilyPlan() async {
        guard let pkg = familyPackage else {
            do {
                let offerings = try await Purchases.shared.offerings()
                if let familyOffering = offerings.offering(identifier: "family"),
                   let annual = familyOffering.annual {
                    familyPackage = annual
                    await doPurchase(annual)
                } else {
                    errorMessage = "Family plan not available"
                    showError = true
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            return
        }
        await doPurchase(pkg)
    }

    private func doPurchase(_ pkg: Package) async {
        isPurchasing = true
        do {
            let result = try await Purchases.shared.purchase(package: pkg)
            if !result.userCancelled {
                let hasPremium = result.customerInfo.entitlements["premium"]?.isActive == true
                if hasPremium {
                    dismiss()
                }
            }
        } catch ErrorCode.purchaseCancelledError {
        } catch ErrorCode.paymentPendingError {
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isPurchasing = false
    }

    private func restorePurchases() async {
        isRestoring = true
        do {
            let info = try await Purchases.shared.restorePurchases()
            if info.entitlements["premium"]?.isActive == true {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isRestoring = false
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.primary)
                .frame(width: 28)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}
