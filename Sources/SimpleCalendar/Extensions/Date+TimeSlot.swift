//
// Created by Paul Peelen
// Copyright © 2023 AppTrix AB. All rights reserved.
//

import Foundation

extension Date {
    /// Calculate a date/time from a Y position in the calendar view
    /// - Parameters:
    ///   - yPosition: The Y position in the calendar view
    ///   - hourHeight: The height of each hour block
    ///   - hourSpacing: The spacing between hour blocks
    ///   - startHourOfDay: The first hour shown in the calendar
    ///   - selectedDate: The currently selected date
    /// - Returns: The calculated date at the given Y position, or nil if invalid
    static func fromYPosition(
        _ yPosition: Double,
        hourHeight: Double,
        hourSpacing: Double,
        startHourOfDay: Int,
        selectedDate: Date
    ) -> Date? {
        let actualHourHeight = hourHeight + hourSpacing
        let heightPerSecond = (actualHourHeight / 60) / 60

        // Calculate seconds from start of calendar view
        let secondsFromStart = yPosition / heightPerSecond

        // Get the start time of the calendar view
        guard let calendarStartTime = selectedDate.atHour(startHourOfDay) else {
            return nil
        }

        // Add seconds to get the target time
        return calendarStartTime.addingTimeInterval(secondsFromStart)
    }

    /// Snap a date to the nearest time interval
    /// - Parameters:
    ///   - intervalMinutes: The interval in minutes (e.g., 15, 30)
    /// - Returns: The date snapped to the nearest interval
    func snappedToInterval(_ intervalMinutes: Int) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)

        guard let hour = components.hour, let minute = components.minute else {
            return self
        }

        // Round to nearest interval
        let totalMinutes = hour * 60 + minute
        let snappedMinutes = (totalMinutes + intervalMinutes / 2) / intervalMinutes * intervalMinutes
        let snappedHour = snappedMinutes / 60
        let snappedMinute = snappedMinutes % 60

        var newComponents = components
        newComponents.hour = snappedHour
        newComponents.minute = snappedMinute
        newComponents.second = 0

        return calendar.date(from: newComponents) ?? self
    }

    /// Check if a time is valid for dropping (within calendar bounds)
    /// - Parameters:
    ///   - startHourOfDay: The first hour shown in the calendar
    ///   - eventDuration: The duration of the event in seconds
    /// - Returns: True if the drop time is valid
    func isValidDropTime(startHourOfDay: Int, eventDuration: Double) -> Bool {
        let calendar = Calendar.current

        guard let hour = calendar.component(.hour, from: self) as Int?,
              let endTime = self.addingTimeInterval(eventDuration) as Date? else {
            return false
        }

        // Check if start time is after the calendar's start hour
        guard hour >= startHourOfDay else {
            return false
        }

        // Check if event ends before or at midnight (or is a full day event ending at midnight the next day)
        let isSameDay = calendar.isDate(self, inSameDayAs: endTime)
        if !isSameDay {
            // Allow events that end exactly at midnight
            let endComponents = calendar.dateComponents([.hour, .minute, .second], from: endTime)
            if endComponents.hour == 0 && endComponents.minute == 0 && endComponents.second == 0 {
                return true
            }
            return false
        }

        return true
    }
}
