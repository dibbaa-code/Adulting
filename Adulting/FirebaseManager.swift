//
//  FirebaseManager.swift
//  Firebase integration wrapper class
//
//  Created by Divya Saini on 5/22/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    // Authentication
    @Published var user: User?
    @Published var isSignedIn = false
    
    // User data
    @Published var userProfile: UserProfile?
    
    // Firestore
    private let db = Firestore.firestore()
    
    // Time formatter for displaying time
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    // Get the local timezone
    private var localTimezone: String {
        return TimeZone.current.identifier
    }
    
    private init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isSignedIn = user != nil
            
            if let user = user {
                // Don't fetch profile immediately after sign in
                // The signInAnonymously method will handle initial profile creation and fetching
                if self?.userProfile == nil {
                    self?.fetchUserProfile(userId: user.uid)
                }
            } else {
                self?.userProfile = nil
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    func signInWithGoogle(idToken: String, accessToken: String) async throws {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let result = try await Auth.auth().signIn(with: credential)
        
        print("User signed in with Google: \(result.user.uid)")
        
        // Check if user profile exists, create if not
        let docRef = db.collection("users").document(result.user.uid)
        let docSnapshot = try await docRef.getDocument()
        
        if !docSnapshot.exists {
            try await createUserProfile(userId: result.user.uid)
        }
        
        // Update Google credentials in the user profile using GoogleAuthenticator methods
        let googleAuth = GoogleAuthenticator.shared
        if let refreshToken = googleAuth.getRefreshToken(),
            let email = googleAuth.getEmail() {
            try await updateGoogleCredentials(accessToken: accessToken, refreshToken: refreshToken, email: email)
        }
        
        // Fetch the updated profile
        fetchUserProfile(userId: result.user.uid)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - User Profile Methods
    private func createUserProfile(userId: String) async throws {
        // Get the user's local timezone
        let localTimezone = TimeZone.current.identifier
        
        // Get user info from Google Sign-In
        let googleAuth = GoogleAuthenticator.shared
        let userName = googleAuth.getUserName() ?? ""
        let userEmail = googleAuth.getEmail() ?? ""
        
        // Create profile data dictionary manually
        let userData: [String: Any] = [
            "id": userId,
            "name": userName,
            "phoneNumber": "",
            "email": userEmail,
            "callStreak": 0,
            "morningCallTime":  "",
            "eveningCallTime": "",
            "timezone": localTimezone,
            "createdAt": Date(),
            "googleAccessToken": "",
            "googleRefreshToken": "",
            "isGoogleCalendarConnected": false
        ]
        
        try await db.collection("users").document(userId).setData(userData)
        
        // Create local UserProfile object
        let newProfile = UserProfile(
            id: userId,
            name: userName,
            phoneNumber: "",
            email: userEmail,
            callStreak: 0,
            morningCallTime: "",
            eveningCallTime: "",
            timezone: localTimezone,
            createdAt: Date()
        )
        
        // Update the published property on the main thread
        DispatchQueue.main.async {
            self.userProfile = newProfile
        }
    }
    
    func fetchUserProfile(userId: String) {
        print("Fetching user profile for user ID: \(userId)")
        db.collection("users").document(userId).addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else {
                print("No snapshot available")
                return
            }
            
            if !snapshot.exists {
                print("User profile document does not exist")
                return
            }
            
            guard let self = self else { return }
            
            if let data = snapshot.data() {
                // Manually convert Firestore data to UserProfile
                let id = data["id"] as? String ?? userId
                let name = data["name"] as? String ?? ""
                let phoneNumber = data["phoneNumber"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let callStreak = data["callStreak"] as? Int ?? 0
                
                // Get timezone first
                let timezone = data["timezone"] as? String ?? TimeZone.current.identifier
                
                // Get call times as strings (these are stored in UTC) and convert to local time
                let utcMorningCallTime = data["morningCallTime"] as? String ?? ""
                let utcEveningCallTime = data["eveningCallTime"] as? String ?? ""
                
                // Convert UTC times to local time for display
                let morningCallTime = TimeUtility.convertFromUTC(timeString: utcMorningCallTime, toTimezone: timezone)
                let eveningCallTime = TimeUtility.convertFromUTC(timeString: utcEveningCallTime, toTimezone: timezone)
                
                // Handle created date
                var createdAt = Date()
                if let createdTimestamp = data["createdAt"] as? Timestamp {
                    createdAt = createdTimestamp.dateValue()
                }
                
                let profile = UserProfile(
                    id: id,
                    name: name,
                    phoneNumber: phoneNumber,
                    email: email,
                    callStreak: callStreak,
                    morningCallTime: morningCallTime,
                    eveningCallTime: eveningCallTime,
                    timezone: timezone,
                    createdAt: createdAt
                )
                
                self.userProfile = profile
            }
        }
    }
    
    func updateUserProfile(name: String? = nil, phoneNumber: String? = nil, email: String? = nil) async throws {
        guard let userId = user?.uid else { return }
        
        var data: [String: Any] = [:]
        
        if let name = name { data["name"] = name }
        if let phoneNumber = phoneNumber { data["phoneNumber"] = phoneNumber }
        if let email = email { data["email"] = email }
        
        try await db.collection("users").document(userId).updateData(data)
        
        // Update local user profile
        DispatchQueue.main.async {
            if let name = name { self.userProfile?.name = name }
            if let phoneNumber = phoneNumber { self.userProfile?.phoneNumber = phoneNumber }
            if let email = email { self.userProfile?.email = email }
        }
    }
    
    func updateGoogleCredentials(accessToken: String, refreshToken: String, email: String) async throws {
        guard let userId = user?.uid else { return }
        
        try await db.collection("users").document(userId).updateData([
            "googleAccessToken": accessToken,
            "googleRefreshToken": refreshToken,
            "googleEmail": email
        ])
        
        // Update local user profile
        DispatchQueue.main.async {
            self.userProfile?.googleAccessToken = accessToken
            self.userProfile?.googleRefreshToken = refreshToken
            self.userProfile?.googleEmail = email
        }
    }
    
    // MARK: - Call Schedule Methods
    
    func updateCallSchedule(morningCallTime: String, eveningCallTime: String) async throws {
        guard let userId = user?.uid else { return }
        
        // Get the user's timezone
        let timezone = userProfile?.timezone ?? TimeZone.current.identifier
        
        // Convert local times to UTC for storage
        let utcMorningCallTime = TimeUtility.convertToUTC(timeString: morningCallTime, fromTimezone: timezone)
        let utcEveningCallTime = TimeUtility.convertToUTC(timeString: eveningCallTime, fromTimezone: timezone)
    
        try await db.collection("users").document(userId).updateData([
            "morningCallTime": utcMorningCallTime,
            "eveningCallTime": utcEveningCallTime
        ])
        
        // Update local user profile with the local time (not UTC)
        DispatchQueue.main.async {
            self.userProfile?.morningCallTime = morningCallTime
            self.userProfile?.eveningCallTime = eveningCallTime
        }
    }
    
    // MARK: - Streak Methods
    
    func incrementStreak() async throws {
        guard let userId = user?.uid else { return }
        
        try await db.collection("users").document(userId).updateData([
            "callStreak": FieldValue.increment(Int64(1))
        ])
        
        // Update local user profile
        DispatchQueue.main.async {
            if let currentStreak = self.userProfile?.callStreak {
                self.userProfile?.callStreak = currentStreak + 1
            }
        }
    }
    
    func resetStreak() async throws {
        guard let userId = user?.uid else { return }
        
        try await db.collection("users").document(userId).updateData([
            "callStreak": 0
        ])
        
        // Update local user profile
        DispatchQueue.main.async {
            self.userProfile?.callStreak = 0
        }
    }
}

// MARK: - Data Models

struct UserProfile: Identifiable {
    var id: String
    var name: String
    var phoneNumber: String
    var email: String
    var callStreak: Int
    var morningCallTime: String
    var eveningCallTime: String
    var timezone: String
    var createdAt: Date
    var googleAccessToken: String?
    var googleRefreshToken: String?
    var googleEmail: String?
}
