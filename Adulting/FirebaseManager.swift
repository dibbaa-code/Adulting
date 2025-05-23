//
//  FirebaseManager.swift
//  Adulting
//
//  Created by Divya Saini on 5/22/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    // Authentication
    @Published var user: User?
    @Published var isSignedIn = false
    
    // User data
    @Published var userProfile: UserProfile?
    
    // Firestore
    private let db = Firestore.firestore()
    
    // Date formatter for Firestore dates
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    private init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isSignedIn = user != nil
            
            if let user = user {
                self?.fetchUserProfile(userId: user.uid)
            } else {
                self?.userProfile = nil
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    func signInAnonymously() async throws {
        let result = try await Auth.auth().signInAnonymously()
        print("User signed in anonymously with ID: \(result.user.uid)")
        
        // Create a default user profile for new users
        if try await db.collection("users").document(result.user.uid).getDocument().exists == false {
            try await createUserProfile(userId: result.user.uid)
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - User Profile Methods
    
    private func createUserProfile(userId: String) async throws {
        // Create profile data dictionary manually
        let morningTime = Date(timeIntervalSince1970: TimeInterval(8 * 3600)) // 8:00 AM
        let eveningTime = Date(timeIntervalSince1970: TimeInterval(21 * 3600)) // 9:00 PM
        
        let userData: [String: Any] = [
            "id": userId,
            "name": "New User",
            "phoneNumber": "",
            "email": "",
            "callStreak": 0,
            "morningCallTime": morningTime,
            "eveningCallTime": eveningTime,
            "createdAt": Date()
        ]
        
        try await db.collection("users").document(userId).setData(userData)
        
        // Create local user profile object
        let newProfile = UserProfile(
            id: userId,
            name: "New User",
            phoneNumber: "",
            email: "",
            callStreak: 0,
            morningCallTime: morningTime,
            eveningCallTime: eveningTime,
            createdAt: Date()
        )
        
        // Update the published property on the main thread
        DispatchQueue.main.async {
            self.userProfile = newProfile
        }
    }
    
    func fetchUserProfile(userId: String) {
        db.collection("users").document(userId).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let snapshot = snapshot, snapshot.exists, error == nil else {
                print("Error fetching user profile: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let data = snapshot.data() {
                // Manually convert Firestore data to UserProfile
                let id = data["id"] as? String ?? userId
                let name = data["name"] as? String ?? ""
                let phoneNumber = data["phoneNumber"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let callStreak = data["callStreak"] as? Int ?? 0
                
                // Handle dates
                var morningCallTime = Date(timeIntervalSince1970: TimeInterval(8 * 3600))
                var eveningCallTime = Date(timeIntervalSince1970: TimeInterval(21 * 3600))
                var createdAt = Date()
                
                if let morningTimestamp = data["morningCallTime"] as? Timestamp {
                    morningCallTime = morningTimestamp.dateValue()
                }
                
                if let eveningTimestamp = data["eveningCallTime"] as? Timestamp {
                    eveningCallTime = eveningTimestamp.dateValue()
                }
                
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
    
    // MARK: - Call Schedule Methods
    
    func updateCallSchedule(morningCallTime: Date, eveningCallTime: Date) async throws {
        guard let userId = user?.uid else { return }
        
        try await db.collection("users").document(userId).updateData([
            "morningCallTime": morningCallTime,
            "eveningCallTime": eveningCallTime
        ])
        
        // Update local user profile
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
    var morningCallTime: Date
    var eveningCallTime: Date
    var createdAt: Date
}
