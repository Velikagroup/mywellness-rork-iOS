import SwiftUI
import AuthenticationServices

struct WelcomeView: View {
    let onGetStarted: () -> Void
    let onSignInSuccess: () -> Void

    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @State private var showSignIn: Bool = false
    @State private var appeared: Bool = false
    @State private var showLanguagePicker: Bool = false

    private var lang: AppLanguage {
        AppLanguage.all.first { $0.code == appLanguage } ?? AppLanguage.all[1]
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    languageButton
                }
                .padding(.top, 8)
                .padding(.trailing, 20)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.05), value: appeared)

                Image("onboarding_hero")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.52)
                    .clipShape(.rect(cornerRadius: 32))
                    .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 10)
                    .padding(.horizontal, 32)
                    .padding(.top, 12)
                    .scaleEffect(appeared ? 1.0 : 0.93)
                    .opacity(appeared ? 1.0 : 0.0)
                    .animation(.spring(response: 0.75, dampingFraction: 0.72).delay(0.1), value: appeared)

                Spacer(minLength: 0)

                VStack(spacing: 28) {
                    Text(headlineText)
                        .font(.system(size: 36, weight: .heavy))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 28)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 18)
                        .animation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.28), value: appeared)

                    VStack(spacing: 0) {
                        Button(action: onGetStarted) {
                            Text(getStartedText)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(.black)
                                .clipShape(.rect(cornerRadius: 28))
                        }
                        .padding(.horizontal, 24)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(.spring(response: 0.5, dampingFraction: 0.82).delay(0.38), value: appeared)

                        Button {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                showSignIn = true
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(alreadyAccountText)
                                    .foregroundStyle(.black)
                                Text(signInBoldText)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.black)
                            }
                            .font(.system(size: 15))
                        }
                        .padding(.top, 18)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.48), value: appeared)
                    }
                }
                .padding(.bottom, 48)
            }

            // Language picker dropdown overlay
            if showLanguagePicker {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showLanguagePicker = false
                        }
                    }

                VStack {
                    HStack {
                        Spacer()
                        languageDropdown
                            .padding(.trailing, 20)
                    }
                    .padding(.top, 44)
                    Spacer()
                }
            }

            if showSignIn {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            showSignIn = false
                        }
                    }
            }

            if showSignIn {
                VStack {
                    Spacer()
                    SignInOverlayView(
                        language: appLanguage,
                        onDismiss: {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                showSignIn = false
                            }
                        },
                        onSuccess: {
                            showSignIn = false
                            onSignInSuccess()
                        }
                    )
                }
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear { appeared = true }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: showSignIn)
        .preferredColorScheme(.light)
    }

    private var languageButton: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                showLanguagePicker.toggle()
            }
        } label: {
            HStack(spacing: 5) {
                Text(lang.flag)
                    .font(.system(size: 15))
                Text(lang.code.uppercased())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.black)
                Image(systemName: showLanguagePicker ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color(.systemGray))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray5))
            .clipShape(.rect(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    private var languageDropdown: some View {
        VStack(spacing: 0) {
            ForEach(Array(AppLanguage.all.enumerated()), id: \.element.id) { idx, language in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        appLanguage = language.code
                        showLanguagePicker = false
                    }
                } label: {
                    HStack(spacing: 12) {
                        Text(language.flag)
                            .font(.system(size: 22))
                        Text(language.name)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.primary)
                        Spacer()
                        if appLanguage == language.code {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .background(appLanguage == language.code ? Color(.systemBlue).opacity(0.07) : Color.clear)
                }
                .buttonStyle(.plain)

                if idx < AppLanguage.all.count - 1 {
                    Divider().padding(.leading, 52)
                }
            }
        }
        .frame(width: 220)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 6)
        .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: .topTrailing)))
    }

    // MARK: - Localized

    private var headlineText: String {
        switch appLanguage {
        case "it": return "Fai scansionare\nil tuo corpo"
        case "es": return "Escanea\ntu cuerpo"
        case "de": return "Lass deinen\nKörper scannen"
        case "fr": return "Faites scanner\nvotre corps"
        case "pt": return "Escaneie\no seu corpo"
        default:   return "Get your\nbody scanned"
        }
    }

    private var getStartedText: String {
        switch appLanguage {
        case "it": return "Inizia"
        case "es": return "Comenzar"
        case "de": return "Loslegen"
        case "fr": return "Commencer"
        case "pt": return "Começar"
        default:   return "Get Started"
        }
    }

    private var alreadyAccountText: String {
        switch appLanguage {
        case "it": return "Hai già un account?"
        case "es": return "¿Ya tienes una cuenta?"
        case "de": return "Schon ein Konto?"
        case "fr": return "Déjà un compte?"
        case "pt": return "Já tem uma conta?"
        default:   return "Already have an account?"
        }
    }

    private var signInBoldText: String {
        switch appLanguage {
        case "it": return "Accedi"
        case "es": return "Inicia sesión"
        case "de": return "Anmelden"
        case "fr": return "Se connecter"
        case "pt": return "Entrar"
        default:   return "Sign In"
        }
    }
}

// MARK: - Phone Mockup (Body Scan)

private struct WelcomePhoneMockupBodyScan: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 46)
                .fill(Color(red: 0.09, green: 0.09, blue: 0.09))
                .shadow(color: .black.opacity(0.32), radius: 30, x: 0, y: 14)

            RoundedRectangle(cornerRadius: 42)
                .fill(.black)
                .padding(4)

            cameraScreen
                .clipShape(.rect(cornerRadius: 38))
                .padding(8)
        }
        .frame(width: 228, height: 456)
    }

    private var cameraScreen: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.06, blue: 0.14),
                    Color(red: 0.06, green: 0.09, blue: 0.22)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            bodyScanGrid

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.6), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 148, height: 148)
                .offset(y: -10)

            bodySilhouette
                .offset(y: 10)

            scanLineOverlay

            measurementDots

            scanBrackets

            VStack {
                Capsule()
                    .fill(Color.black)
                    .frame(width: 82, height: 24)
                    .padding(.top, 5)
                Spacer()
            }

            VStack {
                HStack {
                    Text("2:10")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.leading, 14)
                        .padding(.top, 8)
                    Spacer()
                    Image(systemName: "wifi")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.trailing, 14)
                        .padding(.top, 8)
                }
                Spacer()
            }

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Capsule()
                        .fill(.white.opacity(0.12))
                        .frame(height: 36)

                    HStack(spacing: 14) {
                        HStack(spacing: 4) {
                            Image(systemName: "figure.arms.open")
                                .font(.system(size: 9))
                                .foregroundStyle(.white)
                            Text("Body Scan")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.55))
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.55))
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
                .padding(.horizontal, 14)

                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(width: 36)

                    Spacer()

                    ZStack {
                        Circle()
                            .stroke(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.5), lineWidth: 2)
                            .frame(width: 50, height: 50)
                        Circle()
                            .fill(Color(red: 0.3, green: 0.8, blue: 1.0))
                            .frame(width: 42, height: 42)
                        Image(systemName: "figure.arms.open")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    Spacer()
                    Color.clear.frame(width: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 7)
                .padding(.bottom, 10)
            }
        }
    }

    private var bodySilhouette: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.18))
                .frame(width: 34, height: 34)
                .offset(y: -90)
            Circle()
                .stroke(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.7), lineWidth: 1.5)
                .frame(width: 34, height: 34)
                .offset(y: -90)

            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.13))
                .frame(width: 52, height: 72)
                .offset(y: -36)
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.6), lineWidth: 1.5)
                .frame(width: 52, height: 72)
                .offset(y: -36)

            RoundedRectangle(cornerRadius: 7)
                .fill(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.12))
                .frame(width: 16, height: 56)
                .rotationEffect(.degrees(10))
                .offset(x: -38, y: -32)
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.55), lineWidth: 1.2)
                .frame(width: 16, height: 56)
                .rotationEffect(.degrees(10))
                .offset(x: -38, y: -32)

            RoundedRectangle(cornerRadius: 7)
                .fill(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.12))
                .frame(width: 16, height: 56)
                .rotationEffect(.degrees(-10))
                .offset(x: 38, y: -32)
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.55), lineWidth: 1.2)
                .frame(width: 16, height: 56)
                .rotationEffect(.degrees(-10))
                .offset(x: 38, y: -32)

            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.12))
                .frame(width: 20, height: 68)
                .rotationEffect(.degrees(4))
                .offset(x: -16, y: 40)
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.55), lineWidth: 1.2)
                .frame(width: 20, height: 68)
                .rotationEffect(.degrees(4))
                .offset(x: -16, y: 40)

            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.12))
                .frame(width: 20, height: 68)
                .rotationEffect(.degrees(-4))
                .offset(x: 16, y: 40)
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.55), lineWidth: 1.2)
                .frame(width: 20, height: 68)
                .rotationEffect(.degrees(-4))
                .offset(x: 16, y: 40)
        }
    }

    private var scanLineOverlay: some View {
        VStack {
            Spacer()
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.55), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 3)
                .padding(.horizontal, 24)
            Spacer()
        }
        .frame(maxHeight: 280)
        .offset(y: -30)
    }

    private var bodyScanGrid: some View {
        Canvas { ctx, size in
            let spacing: CGFloat = 22
            let color = GraphicsContext.Shading.color(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.06))
            let style = StrokeStyle(lineWidth: 0.5)
            var col: CGFloat = 0
            while col <= size.width {
                var p = Path()
                p.move(to: CGPoint(x: col, y: 0))
                p.addLine(to: CGPoint(x: col, y: size.height))
                ctx.stroke(p, with: color, style: style)
                col += spacing
            }
            var row: CGFloat = 0
            while row <= size.height {
                var p = Path()
                p.move(to: CGPoint(x: 0, y: row))
                p.addLine(to: CGPoint(x: size.width, y: row))
                ctx.stroke(p, with: color, style: style)
                row += spacing
            }
        }
        .allowsHitTesting(false)
    }

    private var measurementDots: some View {
        ZStack {
            ForEach([
                CGPoint(x: -62, y: -90),
                CGPoint(x: 62, y: -90),
                CGPoint(x: -70, y: -36),
                CGPoint(x: 70, y: -36),
                CGPoint(x: -40, y: 80),
                CGPoint(x: 40, y: 80)
            ], id: \.x) { point in
                Circle()
                    .fill(Color(red: 0.3, green: 0.8, blue: 1.0))
                    .frame(width: 4, height: 4)
                    .offset(x: point.x, y: point.y)
            }
        }
    }

    private var scanBrackets: some View {
        Canvas { ctx, size in
            let inset: CGFloat = 22
            let len: CGFloat = 18
            let lw: CGFloat = 2.5
            let color = GraphicsContext.Shading.color(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.9))
            let style = StrokeStyle(lineWidth: lw, lineCap: .round, lineJoin: .round)
            let w = size.width
            let h = size.height

            var tl = Path()
            tl.move(to: CGPoint(x: inset + len, y: inset))
            tl.addLine(to: CGPoint(x: inset, y: inset))
            tl.addLine(to: CGPoint(x: inset, y: inset + len))
            ctx.stroke(tl, with: color, style: style)

            var tr = Path()
            tr.move(to: CGPoint(x: w - inset - len, y: inset))
            tr.addLine(to: CGPoint(x: w - inset, y: inset))
            tr.addLine(to: CGPoint(x: w - inset, y: inset + len))
            ctx.stroke(tr, with: color, style: style)

            var bl = Path()
            bl.move(to: CGPoint(x: inset + len, y: h - inset))
            bl.addLine(to: CGPoint(x: inset, y: h - inset))
            bl.addLine(to: CGPoint(x: inset, y: h - inset - len))
            ctx.stroke(bl, with: color, style: style)

            var br = Path()
            br.move(to: CGPoint(x: w - inset - len, y: h - inset))
            br.addLine(to: CGPoint(x: w - inset, y: h - inset))
            br.addLine(to: CGPoint(x: w - inset, y: h - inset - len))
            ctx.stroke(br, with: color, style: style)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Mesh Background for Sign In Box

@available(iOS 18.0, *)
private struct SignInMeshBackground: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate
            let t1 = now * 0.28
            let t2 = now * 0.19
            let s1 = Float(sin(t1))
            let c1 = Float(cos(t1))
            let s2 = Float(sin(t2))
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0.0, 0.0], [0.5 + 0.05 * s1, 0.0], [1.0, 0.0],
                    [0.0, 0.5 + 0.06 * c1], [0.5 + 0.08 * s2, 0.5 + 0.07 * c1], [1.0, 0.5 + 0.06 * s1],
                    [0.0, 1.0], [0.5 + 0.05 * c1, 1.0], [1.0, 1.0]
                ],
                colors: [
                    Color(red: 0.72, green: 0.86, blue: 0.95),
                    Color(red: 0.88, green: 0.95, blue: 0.97),
                    Color(red: 0.65, green: 0.88, blue: 0.82),
                    Color(red: 0.68, green: 0.88, blue: 0.92),
                    Color(red: 0.85, green: 0.92, blue: 0.97),
                    Color(red: 0.66, green: 0.87, blue: 0.82),
                    Color(red: 0.58, green: 0.84, blue: 0.80),
                    Color(red: 0.92, green: 0.90, blue: 0.96),
                    Color(red: 0.91, green: 0.88, blue: 0.95)
                ],
                smoothsColors: true
            )
        }
    }
}

// MARK: - Sign In Overlay (Squircle)

struct SignInOverlayView: View {
    let language: String
    let onDismiss: () -> Void
    let onSuccess: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 8)

            HStack(alignment: .center) {
                Spacer()
                Text(signInTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.black)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(.systemGray))
                        .frame(width: 28, height: 28)
                        .background(Color.black.opacity(0.07))
                        .clipShape(.circle)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 6)
            .padding(.bottom, 14)

            Divider().opacity(0.2)

            mainButtonsContent

            VStack(spacing: 2) {
                Text(continuingText)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Link(termsText, destination: URL(string: "https://projectmywellness.com/terms")!)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .underline()
                    Text("&")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Link(privacyText, destination: URL(string: "https://projectmywellness.com/privacy")!)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .underline()
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.top, 10)
            .padding(.bottom, 36)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: 32,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: 32,
            style: .continuous
        ))
        .shadow(color: .black.opacity(0.14), radius: 24, x: 0, y: -4)
        .alert("Error", isPresented: Binding<Bool>(
            get: { AuthService.shared.errorMessage != nil },
            set: { if !$0 { AuthService.shared.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(AuthService.shared.errorMessage ?? "")
        }
    }

    private var mainButtonsContent: some View {
        VStack(spacing: 10) {
            Button {
                AuthService.shared.performAppleSignIn { success in
                    if success {
                        onSuccess()
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 18, weight: .semibold))
                    if AuthService.shared.isAppleSigningIn {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(appleText)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                .foregroundStyle(.white)
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background(.black)
                .clipShape(.rect(cornerRadius: 27))
            }
            .buttonStyle(.plain)
            .disabled(AuthService.shared.isAppleSigningIn)

            Button {
                Task {
                    await AuthService.shared.handleGoogleSignIn()
                    if AuthService.shared.isSignedIn {
                        onSuccess()
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    googleGLogo
                    if AuthService.shared.isGoogleSigningIn {
                        ProgressView()
                            .tint(.primary)
                    } else {
                        Text(googleText)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                }
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(.rect(cornerRadius: 27))
            }
            .buttonStyle(.plain)
            .disabled(AuthService.shared.isGoogleSigningIn)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 4)
    }

    private var googleGLogo: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 26, height: 26)
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
            Text("G")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 0.98, green: 0.27, blue: 0.23), location: 0),
                            .init(color: Color(red: 0.98, green: 0.73, blue: 0.01), location: 0.5),
                            .init(color: Color(red: 0.26, green: 0.52, blue: 0.96), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }

    private var signInTitle: String {
        switch language {
        case "it": return "Accedi"
        case "es": return "Iniciar sesión"
        case "de": return "Anmelden"
        case "fr": return "Connexion"
        case "pt": return "Entrar"
        default:   return "Sign In"
        }
    }

    private var appleText: String {
        switch language {
        case "it": return "Accedi con Apple"
        case "es": return "Continuar con Apple"
        case "de": return "Mit Apple anmelden"
        case "fr": return "Continuer avec Apple"
        case "pt": return "Entrar com Apple"
        default:   return "Sign in with Apple"
        }
    }

    private var googleText: String {
        switch language {
        case "it": return "Accedi con Google"
        case "es": return "Continuar con Google"
        case "de": return "Mit Google anmelden"
        case "fr": return "Continuer avec Google"
        case "pt": return "Entrar com Google"
        default:   return "Continue with Google"
        }
    }

    private var emailText: String {
        switch language {
        case "it": return "Continua con email"
        case "es": return "Continuar con email"
        case "de": return "Mit E-Mail fortfahren"
        case "fr": return "Continuer avec l'email"
        case "pt": return "Continuar com email"
        default:   return "Continue with email"
        }
    }

    private var backText: String {
        switch language {
        case "it": return "Indietro"
        case "es": return "Atrás"
        case "de": return "Zurück"
        case "fr": return "Retour"
        case "pt": return "Voltar"
        default:   return "Back"
        }
    }

    private var emailPlaceholder: String {
        switch language {
        case "it": return "Email"
        case "es": return "Correo electrónico"
        case "de": return "E-Mail"
        case "fr": return "Adresse e-mail"
        case "pt": return "E-mail"
        default:   return "Email"
        }
    }

    private var passwordPlaceholder: String {
        switch language {
        case "it": return "Password"
        case "de": return "Passwort"
        case "fr": return "Mot de passe"
        case "pt": return "Senha"
        default:   return "Password"
        }
    }

    private var continuingText: String {
        switch language {
        case "it": return "Continuando accetti le condizioni di MyWellnessAIBodyScanner"
        case "es": return "Al continuar aceptas los términos de MyWellnessAIBodyScanner"
        case "de": return "Du stimmst den Bedingungen von MyWellnessAIBodyScanner zu"
        case "fr": return "En continuant vous acceptez les conditions"
        case "pt": return "Ao continuar você aceita os termos de MyWellnessAIBodyScanner"
        default:   return "By continuing you accept MyWellnessAIBodyScanner"
        }
    }

    private var termsText: String {
        switch language {
        case "it": return "Termini e condizioni"
        case "es": return "Términos y condiciones"
        case "de": return "Nutzungsbedingungen"
        case "fr": return "Conditions d'utilisation"
        case "pt": return "Termos e condições"
        default:   return "Terms & Conditions"
        }
    }

    private var privacyText: String {
        switch language {
        case "it": return "Informativa sulla privacy"
        case "es": return "Política de privacidad"
        case "de": return "Datenschutzrichtlinie"
        case "fr": return "Politique de confidentialité"
        case "pt": return "Política de privacidade"
        default:   return "Privacy Policy"
        }
    }
}
