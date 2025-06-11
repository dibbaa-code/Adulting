import SwiftUI

struct MealRow: View {
    let title: String
    let icon: String
    let meal: String?
    
    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 15) {
            GridRow {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .gridColumnAlignment(.center)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let meal = meal, !meal.isEmpty {
                        Text(meal)
                            .font(.body)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct MealsWidget: View {
    let meals: DayMeals?
    
    // Check if any meals are planned
    private var hasMeals: Bool {
        guard let meals = meals else { return false }
        
        return (meals.breakfast != nil && !meals.breakfast!.isEmpty) ||
               (meals.lunch != nil && !meals.lunch!.isEmpty) ||
               (meals.snacks != nil && !meals.snacks!.isEmpty) ||
               (meals.dinner != nil && !meals.dinner!.isEmpty)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Meals")
                .font(.headline)
                .foregroundColor(.white)
            
            if hasMeals {
                // Only show meals that are planned
                Grid(alignment: .leading, horizontalSpacing: 15, verticalSpacing: 20) {
                    if let breakfast = meals?.breakfast, !breakfast.isEmpty {
                        GridRow {
                            MealRow(title: "Breakfast", icon: "sun.max.fill", meal: breakfast)
                        }
                    }
                    
                    if let lunch = meals?.lunch, !lunch.isEmpty {
                        GridRow {
                            MealRow(title: "Lunch", icon: "fork.knife", meal: lunch)
                        }
                    }
                    
                    if let snacks = meals?.snacks, !snacks.isEmpty {
                        GridRow {
                            MealRow(title: "Snacks", icon: "cup.and.saucer.fill", meal: snacks)
                        }
                    }
                    
                    if let dinner = meals?.dinner, !dinner.isEmpty {
                        GridRow {
                            MealRow(title: "Dinner", icon: "moon.stars.fill", meal: dinner)
                        }
                    }
                }
            } else {
                // Show message when no meals are planned
                VStack(spacing: 15) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    Text("No meals for today")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        MealsWidget(meals: DayMeals.empty())
            .padding()
    }
} 