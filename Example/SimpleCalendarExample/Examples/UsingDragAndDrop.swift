//
// Created by Paul Peelen
// Copyright © 2023 AppTrix AB. All rights reserved.
//

import SwiftUI
import SimpleCalendar

struct UsingDragAndDrop: View {
    @Binding var events: [any CalendarEventRepresentable]
    @Binding var selectedDate: Date

    var body: some View {
        SimpleCalendarView(
            events: $events,
            selectedDate: $selectedDate,
            selectionAction: .none,
            draggablePredicate: { event in
                // Make only specific events draggable
                // For this example, we'll make "Meditation" and "Reading" events draggable
                event.calendarActivity.title == "Meditation" || event.calendarActivity.title == "Reading"
            },
            onEventMoved: { event, newDate in
                // Find and update the event in the events array
                if let index = events.firstIndex(where: { $0.id == event.id }) {
                    var updatedEvent = event

                    // Create a new event with the updated start date
                    // Since CalendarEventRepresentable is a protocol, we need to create a new CalendarEvent
                    let newEvent = CalendarEvent(
                        id: event.id,
                        startDate: newDate,
                        activity: event.calendarActivity
                    )

                    events[index] = newEvent

                    print("Moved event '\(event.calendarActivity.title)' to \(newDate.formatted(date: .omitted, time: .shortened))")
                }
            },
            dragGranularityMinutes: 15
        )
        .navigationTitle("Drag & Drop Demo")
        .navigationBarTitleDisplayMode(.inline)
    }
}
