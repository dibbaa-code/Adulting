import SwiftUI

struct TaskItemView: View {
    let task: TaskItem
    let onToggle: (TaskItem) -> Void
    
    var body: some View {
        Button(action: { onToggle(task) }) {
            HStack(spacing: 15) {
                // Square Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(0.6), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if task.isComplete {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.green)
                            .frame(width: 22, height: 22)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                
                // Task text
                Text(task.text)
                    .font(.body)
                    .foregroundColor(.white)
                    .strikethrough(task.isComplete, color: .white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 12)
        }
    }
}

struct TasksWidget: View {
    let tasks: [TaskItem]
    let onTaskToggle: (TaskItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Tasks")
                .font(.headline)
                .foregroundColor(.white)
            
            if !tasks.isEmpty {
                VStack(spacing: 0) {
                    ForEach(tasks) { task in
                        VStack(spacing: 0) {
                            TaskItemView(task: task, onToggle: onTaskToggle)
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                        }
                    }
                }
            } else {
                VStack(spacing: 15) {
                    Image(systemName: "checklist")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                    
                    Text("No tasks for today")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        TasksWidget(
            tasks: [
                TaskItem(id: "1", text: "Sample task 1", isComplete: false),
                TaskItem(id: "2", text: "Sample task 2", isComplete: true)
            ],
            onTaskToggle: { _ in }
        )
        .padding()
    }
} 