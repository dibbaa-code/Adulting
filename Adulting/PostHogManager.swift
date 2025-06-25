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

    // Track an event with optional properties
    func trackEvent(_ eventName: String, properties: [String: Any]? = nil) {
        PostHogSDK.shared.capture(eventName, properties: properties)
    }
}
