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
                    } else {
                        Text("-")
                            .font(.body)
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
            }
        }
    }
}

struct MealsWidget: View {
    let meals: DayMeals?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Meals")
                .font(.headline)
                .foregroundColor(.white)
            
            Grid(alignment: .leading, horizontalSpacing: 15, verticalSpacing: 20) {
                GridRow {
                    MealRow(title: "Breakfast", icon: "sun.max.fill", meal: meals?.breakfast)
                }
                GridRow {
                    MealRow(title: "Lunch", icon: "fork.knife", meal: meals?.lunch)
                }
                GridRow {
                    MealRow(title: "Snacks", icon: "cup.and.saucer.fill", meal: meals?.snacks)
                }
                GridRow {
                    MealRow(title: "Dinner", icon: "moon.stars.fill", meal: meals?.dinner)
                }
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