//
//  TimeUtility.swift
//  Adulting
//
//  Created by Divya Saini on 5/25/25.
//

import Foundation

struct TimeUtility {
    // Convert time between timezones
    static func convertTime(timeString: String, fromTimezone: String, toTimezone: String) -> String {
        guard !timeString.isEmpty else { return "" }
        
        // Create date formatter for parsing the input time
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "h:mm a"
        inputFormatter.timeZone = TimeZone(identifier: fromTimezone)
        
        // Create date formatter for outputting the time in target timezone
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        outputFormatter.timeZone = TimeZone(identifier: toTimezone)
        
        // Use today's date to ensure proper Daylight Saving Time handling
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
        // Parse the time and combine with today's date
        if let time = inputFormatter.date(from: timeString),
           let timeToday = calendar.date(bySettingHour: calendar.component(.hour, from: time),
                                         minute: calendar.component(.minute, from: time),
                                         second: 0,
                                         of: today) {
            return outputFormatter.string(from: timeToday)
        }
        
        return timeString // Return original if conversion fails
    }
    
    // Helper methods for common conversions
    static func convertToUTC(timeString: String, fromTimezone: String) -> String {
        return convertTime(timeString: timeString, fromTimezone: fromTimezone, toTimezone: "UTC")
    }
    
    static func convertFromUTC(timeString: String, toTimezone: String) -> String {
        return convertTime(timeString: timeString, fromTimezone: "UTC", toTimezone: toTimezone)
    }
}
