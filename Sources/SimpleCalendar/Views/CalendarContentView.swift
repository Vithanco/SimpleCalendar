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
                        .padding(.top, 12)
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
                .padding(.top, 12)
                .padding(.leading, leadingPadding)
            }
            .dropDestination(for: DraggableEventTransfer.self) { items, location in
                handleDrop(items: items, location: location, in: geo)
            } isTargeted: { isTargeted in
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
        guard let droppedItem = items.first,
              let draggedEvent = events.first(where: { $0.id == droppedItem.eventId }),
              let onEventMoved = onEventMoved else {
            return false
        }

        // Adjust location for padding
        let adjustedY = location.y - 12

        // Calculate the new time from Y position
        guard let newTime = Date.fromYPosition(
            adjustedY,
            hourHeight: hourHeight,
            hourSpacing: hourSpacing,
            startHourOfDay: startHourOfDay,
            selectedDate: selectedDate
        ) else {
            return false
        }

        // Snap to interval
        let snappedTime = newTime.snappedToInterval(dragGranularityMinutes)

        // Validate drop time
        guard snappedTime.isValidDropTime(
            startHourOfDay: startHourOfDay,
            eventDuration: droppedItem.duration
        ) else {
            return false
        }

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
