import Foundation

nonisolated(unsafe) var env_kimiApiKey: String = ""
nonisolated(unsafe) var env_toolkitURL: String = ""
nonisolated(unsafe) var env_rorkApiBaseURL: String = ""
nonisolated(unsafe) var env_rorkToolkitSecretKey: String = ""
nonisolated(unsafe) var env_stabilityApiKey: String = ""
nonisolated(unsafe) var env_resendApiKey: String = ""
nonisolated(unsafe) var env_rorkAuthURL: String = ""
nonisolated(unsafe) var env_googleIOSClientID: String = ""

@MainActor
func initEnvBridge() {
    env_kimiApiKey = Config.EXPO_PUBLIC_KIMI_API_KEY
    env_toolkitURL = Config.EXPO_PUBLIC_TOOLKIT_URL
    env_rorkApiBaseURL = Config.EXPO_PUBLIC_RORK_API_BASE_URL
    env_rorkToolkitSecretKey = Config.EXPO_PUBLIC_RORK_TOOLKIT_SECRET_KEY
    env_stabilityApiKey = Config.EXPO_PUBLIC_STABILITY_API_KEY
    env_resendApiKey = Config.EXPO_PUBLIC_RESEND_API_KEY
    env_rorkAuthURL = Config.EXPO_PUBLIC_RORK_AUTH_URL
    env_googleIOSClientID = Config.EXPO_PUBLIC_GOOGLE_IOS_CLIENT_ID
}
