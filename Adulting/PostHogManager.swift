import Foundation
import PostHog
import UIKit

/// Manager class for PostHog analytics and session replay
class PostHogManager {
    // MARK: - Singleton
    static let shared = PostHogManager()
    
    // MARK: - Constants
    private let POSTHOG_API_KEY = "<api_key>"
    private let POSTHOG_HOST = "<host>"
    
    // MARK: - Properties
    private(set) var isConfigured = false
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Setup
    func setup() {
        guard !isConfigured else { return }
        
        // Create and configure PostHog
        let config = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)
        
        // Enable session replay with optimal settings
        config.sessionReplay = true
        config.sessionReplayConfig.captureNetworkTelemetry = true
        config.sessionReplayConfig.screenshotMode = true
        config.sessionReplayConfig.maskAllTextInputs = false // Allow seeing text inputs for debugging
        config.sessionReplayConfig.maskAllImages = false
        config.sessionReplayConfig.maskAllSandboxedViews = false // Disable masking to see more content
        config.sessionReplayConfig.throttleDelay = 0.5 // Faster capture rate
        
        // Enable debug mode in development
        #if DEBUG
        config.debug = true
        #endif
        
        // Initialize PostHog
        PostHogSDK.shared.setup(config)
        
        isConfigured = true
        
        // Log app launch event
        trackEvent("app_launched")
    }

    // MARK: - Analytics
    
    /// Track a screen view
    func trackScreen(_ screenName: String, properties: [String: Any]? = nil) {
        var props = properties ?? [String: Any]()
        props["screen_name"] = screenName
        
        // First, capture a screen view event
        PostHogSDK.shared.screen(screenName, properties: props)
        
        // Also track as a regular event to ensure it's captured
        trackEvent("screen_viewed", properties: props)
    }
    
    // MARK: - Critical Events
    
    /// Track when a user signs in
    func trackSignIn(method: String, success: Bool, error: Error? = nil) {
        var properties: [String: Any] = [
            "method": method,
            "success": success
        ]
        
        if let error = error {
            properties["error"] = error.localizedDescription
        }
        
        trackEvent("user_sign_in", properties: properties)
    }
    
    /// Track when a user signs out
    func trackSignOut() {
        trackEvent("user_sign_out")
    }
    
    /// Track when a user completes onboarding
    func trackOnboardingComplete(steps: Int) {
        trackEvent("onboarding_complete", properties: ["steps_completed": steps])
    }
    
    /// Track an event with optional properties
    func trackEvent(_ eventName: String, properties: [String: Any]? = nil) {
        PostHogSDK.shared.capture(eventName, properties: properties)
    }

    /// Track when an error occurs
    func trackError(domain: String, code: Int, description: String) {
        trackEvent("error_occurred", properties: [
            "error_domain": domain,
            "error_code": code,
            "error_description": description
        ])
    }
}
