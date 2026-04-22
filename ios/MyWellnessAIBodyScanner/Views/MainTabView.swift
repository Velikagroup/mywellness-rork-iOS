import SwiftUI

struct MainTabView: View {
    @Environment(AppViewModel.self) private var appVM
    @State private var selectedTab: Int = 0
    @State private var showCameraHub: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if #available(iOS 18.0, *) {
                AnimatedMeshBackground()
            } else {
                Color(red: 0.72, green: 0.86, blue: 0.95).ignoresSafeArea()
            }

            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                NutritionView()
                    .tag(1)
                WorkoutView()
                    .tag(2)
                SettingsView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            bottomBar
        }
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $showCameraHub) {
            CameraHubView()
        }
        .onChange(of: appVM.shouldOpenCameraHub) { _, newValue in
            if newValue {
                appVM.shouldOpenCameraHub = false
                showCameraHub = true
            }
        }
    }

    private var bottomBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            tabPill
                .padding(.bottom, 22)
            Spacer()
            plusButton
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var tabPill: some View {
        HStack(spacing: 0) {
            tabBarItem(icon: "house.fill", label: Lang.s("tab_home"), tag: 0)
            tabBarItem(icon: "fork.knife", label: Lang.s("tab_nutrition"), tag: 1)
            tabBarItem(icon: "figure.strengthtraining.traditional", label: Lang.s("tab_training"), tag: 2)
            tabBarItem(icon: "gearshape.fill", label: Lang.s("tab_settings"), tag: 3)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 14)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 20, y: -4)
    }

    private var plusButton: some View {
        Button {
            showCameraHub = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.15), radius: 20, y: -4)
                Image(systemName: "plus")
                    .font(.system(size: 47, weight: .semibold))
                    .foregroundStyle(Color(red: 0/255, green: 131/255, blue: 137/255))
            }
            .frame(width: 122, height: 122)
            .padding(.bottom, 22)
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.impact(weight: .medium), trigger: showCameraHub)
    }

    private func tabBarItem(icon: String, label: String, tag: Int) -> some View {
        let isSelected = selectedTab == tag
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tag
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Color.wellnessTeal : Color(.tertiaryLabel))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isSelected)
            }
            .frame(width: 52)
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: selectedTab)
    }
}
