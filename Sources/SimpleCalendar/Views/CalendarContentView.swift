//
// Created by Paul Peelen
// Copyright © 2023 AppTrix AB. All rights reserved.
//

import SwiftUI

struct CalendarContentView: View {
    @Binding var events: [any CalendarEventRepresentable]
    let selectionAction: SelectionAction
    let selectedDate: Date
    let hourHeight: Double
    let hourSpacing: Double
    let startHourOfDay: Int
    let draggablePredicate: ((any CalendarEventRepresentable) -> Bool)?
    let onEventMoved: ((any CalendarEventRepresentable, Date) -> Void)?
    let dragGranularityMinutes: Int
    @Binding var draggedEventId: String?
    @Binding var dropTargetTime: Date?

    private let leadingPadding = 70.0
    private let boxSpacing = 5.0

    @State private var dropTargetYPosition: CGFloat?
    @State private var draggedEventDuration: Double?

    public var body: some View {
        GeometryReader { geo in
            let width = (geo.size.width - leadingPadding)

            ZStack(alignment: .topLeading) {
                // Drop target preview
                if let dropTargetYPosition = dropTargetYPosition,
                   let draggedEventDuration = draggedEventDuration {
                    let actualHourHeight = hourHeight + hourSpacing
                    let heightPerSecond = (actualHourHeight / 60) / 60
                    let previewHeight = draggedEventDuration * heightPerSecond

                    Rectangle()
                        .fill(Color.accentColor.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                                .foregroundColor(.accentColor)
                        }
                        .frame(width: width - boxSpacing, height: previewHeight)
                        .offset(x: 0, y: dropTargetYPosition)
                        .padding(.leading, leadingPadding)
                }

                // Events
                ForEach(events, id:\.id) { event in
                    let boxWidth = (width / Double(event.columnCount + 1)) - boxSpacing
                    let isDraggable = draggablePredicate?(event) ?? false
                    let isDragging = draggedEventId == event.id

                    EventView(
                        event: event,
                        selectionAction: selectionAction,
                        isDraggable: isDraggable,
                        isDragging: isDragging,
                        onDragStart: {
                            draggedEventId = event.id
                            draggedEventDuration = event.calendarActivity.duration
                        },
                        onDragEnd: {
                            draggedEventId = nil
                            dropTargetYPosition = nil
                            dropTargetTime = nil
                            draggedEventDuration = nil
                        }
                    )
                    .offset(CGSize(width: boxWidth * Double(event.column) + (boxSpacing * Double(event.column)), height: (event.coordinates?.minY ?? 0)))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                    .frame(width: boxWidth, height: event.coordinates?.height ?? 20)
                }
                .padding(.leading, leadingPadding)
            }
            .dropDestination(for: DraggableEventTransfer.self) { items, location in
                print("🔥 dropDestination closure called with \(items.count) items")
                let result = handleDrop(items: items, location: location, in: geo)
                print("🔥 dropDestination returning: \(result)")
                return result
            } isTargeted: { isTargeted in
                print("🔥 isTargeted changed to: \(isTargeted)")
                if !isTargeted {
                    dropTargetYPosition = nil
                    dropTargetTime = nil
                }
            }
            .onContinuousHover { phase in
                // This is needed for the drop destination to work properly
            }
        }
    }

    private func handleDrop(items: [DraggableEventTransfer], location: CGPoint, in geometry: GeometryProxy) -> Bool {
        print("🎯 Drop handler called with \(items.count) items at location: \(location)")

        guard let droppedItem = items.first else {
            print("❌ No dropped item")
            return false
        }
        print("✅ Dropped item: eventId=\(droppedItem.eventId)")

        guard let draggedEvent = events.first(where: { $0.id == droppedItem.eventId }) else {
            print("❌ Could not find event with id=\(droppedItem.eventId) in events array (count=\(events.count))")
            return false
        }
        print("✅ Found dragged event in array")

        guard let onEventMoved = onEventMoved else {
            print("❌ No onEventMoved callback")
            return false
        }
        print("✅ onEventMoved callback exists")

        // Calculate the new time from Y position
        guard let newTime = Date.fromYPosition(
            location.y,
            hourHeight: hourHeight,
            hourSpacing: hourSpacing,
            startHourOfDay: startHourOfDay,
            selectedDate: selectedDate
        ) else {
            print("❌ Could not calculate time from Y position: \(location.y)")
            return false
        }
        print("✅ Calculated new time: \(newTime)")

        // Snap to interval
        let snappedTime = newTime.snappedToInterval(dragGranularityMinutes)
        print("✅ Snapped time: \(snappedTime)")

        // Validate drop time
        guard snappedTime.isValidDropTime(
            startHourOfDay: startHourOfDay,
            eventDuration: droppedItem.duration
        ) else {
            print("❌ Invalid drop time")
            return false
        }
        print("✅ Valid drop time, calling callback")

        // Call the callback
        onEventMoved(draggedEvent, snappedTime)

        // Clear drag state
        draggedEventId = nil
        dropTargetYPosition = nil
        dropTargetTime = nil
        draggedEventDuration = nil

        return true
    }
}
//
//#Preview("ContentView") {
//    CalendarContentView(
//        events: .constant([]),
//        selectionAction: .none
//    )
//}
