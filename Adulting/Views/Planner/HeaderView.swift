import SwiftUI

struct HeaderView: View {
    let todayDateString: String
    
    // Format date for display in local timezone
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Today's Planner")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Convert UTC date string back to Date for local display
            let displayDate = {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.timeZone = TimeZone(identifier: "UTC")
                if let date = formatter.date(from: todayDateString) {
                    return date
                }
                return Date()
            }()
            
            Text(formatDate(displayDate))
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HeaderView(todayDateString: "2024-03-20")
    }
} 