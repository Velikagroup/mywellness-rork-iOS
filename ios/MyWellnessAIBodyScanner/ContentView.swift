import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) private var appVM
    @State private var onboardingStarted: Bool = false

    var body: some View {
        Group {
            if appVM.hasCompletedOnboarding {
                MainTabView()
                    .transition(.opacity)
            } else if onboardingStarted {
                OnboardingView(onDismiss: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        onboardingStarted = false
                    }
                })
                .transition(.opacity)
            } else {
                WelcomeView(
                    onGetStarted: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            onboardingStarted = true
                        }
                    },
                    onSignInSuccess: {
                        if appVM.hasExistingProfile {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                appVM.hasCompletedOnboarding = true
                                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                onboardingStarted = true
                            }
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appVM.hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.4), value: onboardingStarted)
        .onChange(of: appVM.hasCompletedOnboarding) { _, newValue in
            if !newValue {
                onboardingStarted = false
            }
        }
    }
}
