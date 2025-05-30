import SwiftUI
import Firebase
import FirebaseFirestore

struct PlannerView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @State private var planner: DayPlanner?
    @State private var isLoading = true
    
    // Firestore reference
    private let db = Firestore.firestore()
    
    // Get today's date in YYYY-MM-DD format in UTC
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: Date())
    }
    
    // Format date for display in local timezone
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HeaderView(todayDateString: todayDateString)
                        
                        // Meals Widget
                        MealsWidget(meals: planner?.meals)
                        
                        // Tasks Widget
                        TasksWidget(
                            tasks: planner?.tasks ?? [],
                            onTaskToggle: toggleTaskCompletion
                        )
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            setupPlannerListener()
        }
    }
    
    // Setup Firestore listener for real-time updates
    private func setupPlannerListener() {
        guard let userId = firebaseManager.user?.uid else { return }
        
        let plannerRef = db.collection("users").document(userId)
            .collection("planner").document(todayDateString)
        
        plannerRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching planner: \(error.localizedDescription)")
                return
            }
            
            if let document = snapshot, document.exists {
                planner = DayPlanner.fromFirestore(document.data() ?? [:], date: todayDateString)
            } else {
                planner = DayPlanner.empty(for: todayDateString)
            }
            
            isLoading = false
        }
    }
    
    // Toggle task completion status
    private func toggleTaskCompletion(_ task: TaskItem) {
        guard let userId = firebaseManager.user?.uid,
              var updatedPlanner = planner else { return }
        
        // Update the task in the local planner
        if let index = updatedPlanner.tasks.firstIndex(where: { $0.id == task.id }) {
            updatedPlanner.tasks[index].isComplete.toggle()
            
            // Update Firestore
            let plannerRef = db.collection("users").document(userId)
                .collection("planner").document(todayDateString)
            
            plannerRef.setData(updatedPlanner.toFirestore(), merge: true) { error in
                if let error = error {
                    print("Error updating task: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    PlannerView()
        .environmentObject(FirebaseManager.shared)
} 