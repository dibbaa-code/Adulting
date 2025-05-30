import Foundation
import FirebaseFirestore

// Represents a task in the planner
struct TaskItem: Identifiable {
    let id: String
    let text: String
    var isComplete: Bool
}

// Represents all meals for the day
struct DayMeals {
    var breakfast: String?
    var lunch: String?
    var snacks: String?
    var dinner: String?
    
    static func empty() -> DayMeals {
        DayMeals(
            breakfast: nil,
            lunch: nil,
            snacks: nil,
            dinner: nil
        )
    }
}

// Main planner data structure
struct DayPlanner {
    var meals: DayMeals
    var tasks: [TaskItem]
    let date: String
    
    static func empty(for date: String) -> DayPlanner {
        DayPlanner(
            meals: DayMeals.empty(),
            tasks: [],
            date: date
        )
    }
    
    // Convert Firestore data to DayPlanner
    static func fromFirestore(_ data: [String: Any], date: String) -> DayPlanner {
        let mealsData = data["meals"] as? [String: Any] ?? [:]
        let tasksData = data["tasks"] as? [[String: Any]] ?? []
        
        let meals = DayMeals(
            breakfast: mealsData["breakfast"] as? String,
            lunch: mealsData["lunch"] as? String,
            snacks: mealsData["snacks"] as? String,
            dinner: mealsData["dinner"] as? String
        )
        
        let tasks = tasksData.enumerated().map { index, item in
            TaskItem(
                id: String(index),
                text: item["text"] as? String ?? "",
                isComplete: item["isComplete"] as? Bool ?? false
            )
        }
        
        return DayPlanner(meals: meals, tasks: tasks, date: date)
    }
    
    // Convert DayPlanner to Firestore data
    func toFirestore() -> [String: Any] {
        let mealsData: [String: Any] = [
            "breakfast": meals.breakfast ?? "",
            "lunch": meals.lunch ?? "",
            "snacks": meals.snacks ?? "",
            "dinner": meals.dinner ?? ""
        ]
        
        let tasksData: [[String: Any]] = tasks.map { task in
            ["text": task.text, "isComplete": task.isComplete]
        }
        
        return [
            "meals": mealsData,
            "tasks": tasksData,
            "updated_at": FieldValue.serverTimestamp()
        ]
    }
} 