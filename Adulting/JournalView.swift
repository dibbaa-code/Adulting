import SwiftUI
import Firebase
import FirebaseFirestore

// Model for todo items
struct TodoItem: Identifiable {
    let id: String
    let text: String
    var isComplete: Bool
}

struct JournalView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @State private var todoItems: [TodoItem] = []
    @State private var isLoading = true
    
    // Firestore reference
    private let db = Firestore.firestore()
    
    // Get today's date in YYYY-MM-DD format
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Today's Tasks")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(formatDate(Date()))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                if isLoading {
                    // Loading indicator
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .frame(maxHeight: .infinity)
                } else if todoItems.isEmpty {
                    // Empty state
                    VStack(spacing: 15) {
                        Image(systemName: "checklist")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No tasks for today")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    // Todo list
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(todoItems) { item in
                                VStack(spacing: 0) {
                                    TodoItemView(item: item) { updatedItem in
                                        toggleItemCompletion(updatedItem)
                                    }
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            setupTodoListener()
        }
    }
    
    // Format date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
    
    // Setup Firestore listener for real-time updates
    private func setupTodoListener() {
        guard let userId = firebaseManager.user?.uid else { return }
        
        let todoRef = db.collection("users").document(userId)
            .collection("to_do_list").document(todayDateString)
        
        todoRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching todos: \(error.localizedDescription)")
                return
            }
            
            guard let document = snapshot, document.exists,
                  let data = document.data(),
                  let items = data["items"] as? [[String: Any]] else {
                isLoading = false
                todoItems = []
                return
            }
            
            // Convert Firestore data to TodoItems
            todoItems = items.enumerated().map { index, item in
                TodoItem(
                    id: String(index),  // Using index as id since Firestore stores as array
                    text: item["text"] as? String ?? "",
                    isComplete: item["isComplete"] as? Bool ?? false
                )
            }
            
            isLoading = false
        }
    }
    
    // Toggle item completion status
    private func toggleItemCompletion(_ item: TodoItem) {
        guard let userId = firebaseManager.user?.uid else { return }
        
        // Find and update the item in the local array
        if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
            // Create new items array with updated completion status
            var updatedItems = todoItems.map { todoItem -> [String: Any] in
                if todoItem.id == item.id {
                    return ["text": todoItem.text, "isComplete": !todoItem.isComplete]
                }
                return ["text": todoItem.text, "isComplete": todoItem.isComplete]
            }
            
            // Update Firestore
            let todoRef = db.collection("users").document(userId)
                .collection("to_do_list").document(todayDateString)
            
            todoRef.updateData([
                "items": updatedItems,
                "updated_at": FieldValue.serverTimestamp()
            ]) { error in
                if let error = error {
                    print("Error updating todo: \(error.localizedDescription)")
                }
            }
        }
    }
}

// TodoItemView component
struct TodoItemView: View {
    let item: TodoItem
    let onToggle: (TodoItem) -> Void
    
    var body: some View {
        Button(action: { onToggle(item) }) {
            HStack(spacing: 15) {
                // Square Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(0.6), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if item.isComplete {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.green)
                            .frame(width: 22, height: 22)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                
                // Task text
                Text(item.text)
                    .font(.body)
                    .foregroundColor(.white)
                    .strikethrough(item.isComplete, color: .white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    JournalView()
        .environmentObject(FirebaseManager.shared)
}