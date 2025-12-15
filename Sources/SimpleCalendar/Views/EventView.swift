//
//  SwiftUIView.swift
//  
//
//  Created by Paul Peelen on 2023-09-09.
//

import SwiftUI

struct EventView: View {
    let event: any CalendarEventRepresentable
    let selectionAction: SelectionAction
    let isDraggable: Bool
    let isDragging: Bool
    let onDragStart: () -> Void
    let onDragEnd: () -> Void

    // For opening Event details
    @State private var showEventSheet = false
    @State private var isHovering = false
    
    var body: some View {
        VStack {
            if case .destination(let customView) = selectionAction {
                NavigationLink {
                    AnyView(customView(event))
                } label: {
                    content
                }
            } else {
                content
                    .onTapGesture {
                        switch selectionAction {
                        case .sheet, .customSheet:
                            showEventSheet = true
                        case .inform(let closure):
                            closure(event)
                        default:
                            break
                        }
                    }
                    .sheet(isPresented: $showEventSheet) {
                        ZStack {
                            if case .customSheet(let customView) = selectionAction {
                                AnyView(customView(event))
                            } else {
                                EventDetailsView(event: event)
                            }
                        }
                        .presentationDetents([.medium])
                    }
            }
        }
        .opacity(isDragging ? 0.3 : 1.0)
        .if(isDraggable) { view in
            view
                .onContinuousHover { phase in
                    switch phase {
                    case .active:
                        isHovering = true
                    case .ended:
                        isHovering = false
                    }
                }
                .draggable(makeDraggableTransfer()) {
                    content
                        .opacity(0.8)
                }
        }
    }

    private func makeDraggableTransfer() -> DraggableEventTransfer {
        onDragStart()
        return DraggableEventTransfer(
            eventId: event.id,
            originalStartDate: event.startDate,
            duration: event.calendarActivity.duration
        )
    }

    private var content: some View {
        let mainColor = event.calendarActivity.activityType.color
        let endDate = event.endDate
        
        return VStack {
            VStack(alignment: .leading) {
                if (event.visibleDuration / 60) <= 15 {
                    if event.columnCount > 0 {
                        HStack(alignment: .center) {
                            Text(event.calendarActivity.title)
                                .foregroundColor(mainColor)
                                .font(.caption)
                                .padding(.top, 4)
                                .fontWeight(.semibold)
                                .dynamicTypeSize(.small ... .large)
                            Spacer()
                            Text("\(event.startDate.formatted(date: .omitted, time: .shortened)), \(Int(event.calendarActivity.duration / 60)) min")
                                .foregroundColor(mainColor)
                                .font(.caption2)
                                .dynamicTypeSize(.small ... .large)
                        }
                    } else {
                        HStack(alignment: .center) {
                            Text(event.calendarActivity.title)
                                .foregroundColor(mainColor)
                                .font(.caption)
                                .padding(.top, 4)
                                .fontWeight(.semibold)
                                .dynamicTypeSize(.small ... .large)
                            Spacer()
                            Text("\(event.startDate.formatted(date: .omitted, time: .shortened)) - \(endDate.formatted(date: .omitted, time: .shortened)), \(Int(event.calendarActivity.duration / 60)) min")
                                .foregroundColor(mainColor)
                                .font(.caption2)
                                .dynamicTypeSize(.small ... .large)
                        }
                    }
                } else if (event.visibleDuration / 60) <= 30 {
                    Text(event.calendarActivity.title)
                        .foregroundColor(mainColor)
                        .font(.caption)
                        .padding(.top, 4)
                        .fontWeight(.semibold)
                        .dynamicTypeSize(.small ... .large)
                    if event.columnCount > 0 {
                        Text("\(event.startDate.formatted(date: .omitted, time: .shortened)), \(Int(event.calendarActivity.duration / 60)) min")
                            .foregroundColor(mainColor)
                            .font(.caption2)
                            .dynamicTypeSize(.small ... .large)
                    } else {
                        Text("\(event.startDate.formatted(date: .omitted, time: .shortened)) - \(endDate.formatted(date: .omitted, time: .shortened)), \(Int(event.calendarActivity.duration / 60)) min")
                            .foregroundColor(mainColor)
                            .font(.caption2)
                            .dynamicTypeSize(.small ... .large)
                    }
                } else {
                    Text(event.calendarActivity.title)
                        .foregroundColor(mainColor)
                        .font(.caption)
                        .padding(.top, 4)
                        .fontWeight(.semibold)
                        .dynamicTypeSize(.small ... .large)
                    Text("\(event.startDate.formatted(date: .omitted, time: .shortened)) - \(endDate.formatted(date: .omitted, time: .shortened))")
                        .foregroundColor(mainColor)
                        .font(.caption2)
                        .dynamicTypeSize(.small ... .large)
                    Text("Duration: \(Int(event.calendarActivity.duration / 60)) min")
                        .foregroundColor(mainColor)
                        .font(.caption2)
                        .dynamicTypeSize(.small ... .large)
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .background(mainColor.opacity(0.30), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                HStack {
                    Rectangle()
                        .fill(mainColor)
                        .frame(maxHeight: .infinity, alignment: .leading)
                        .frame(width: 4)
                    Spacer()
                }
            }
        }
        .foregroundColor(.primary)
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(mainColor, lineWidth: isDraggable && isHovering ? 2 : 1)
                .frame(maxHeight: .infinity)
        }
        .mask(
            RoundedRectangle(cornerRadius: 6)
                .frame(maxHeight: .infinity)
        )
    }
}

// Helper extension for conditional view modifiers
extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
//
//#Preview("Normal 15min") {
//    let activity15min = CalendarActivity.forPreview(duration: 60 * 15)
//    let event15 = CalendarEvent.forPreview(activity: activity15min)
//    EventView(event: event15, selectionAction: .none)
//}
//
//#Preview("XXXL 15min") {
//    let activity15min = CalendarActivity.forPreview(duration: 60 * 15)
//    let event15 = CalendarEvent.forPreview(activity: activity15min)
//    EventView(event: event15, selectionAction: .none)
//        .environment(\.sizeCategory, .extraExtraExtraLarge)
//}
//
//#Preview("XS 15min") {
//    let activity15min = CalendarActivity.forPreview(duration: 60 * 15)
//    let event15 = CalendarEvent.forPreview(activity: activity15min)
//    EventView(event: event15, selectionAction: .none)
//        .environment(\.sizeCategory, .extraSmall)
//}
//
//#Preview("Normal 30min") {
//    let activity30min = CalendarActivity.forPreview(duration: 60 * 30)
//    let event30 = CalendarEvent.forPreview(activity: activity30min)
//    EventView(event: event30, selectionAction: .none)
//}
//
//#Preview("XXXL 30min") {
//    let activity30min = CalendarActivity.forPreview(duration: 60 * 30)
//    let event30 = CalendarEvent.forPreview(activity: activity30min)
//    EventView(event: event30, selectionAction: .none)
//        .environment(\.sizeCategory, .extraExtraExtraLarge)
//}
//
//#Preview("XS 30min") {
//    let activity30min = CalendarActivity.forPreview(duration: 60 * 30)
//    let event30 = CalendarEvent.forPreview(activity: activity30min)
//    EventView(event: event30, selectionAction: .none)
//        .environment(\.sizeCategory, .extraSmall)
//}
//
//#Preview("Normal 60min") {
//    let activity60min = CalendarActivity.forPreview(duration: 60 * 60)
//    let event60 = CalendarEvent.forPreview(activity: activity60min)
//    EventView(event: event60, selectionAction: .none)
//}
//
//#Preview("XXXL 60min") {
//    let activity60min = CalendarActivity.forPreview(duration: 60 * 60)
//    let event60 = CalendarEvent.forPreview(activity: activity60min)
//    EventView(event: event60, selectionAction: .none)
//        .environment(\.sizeCategory, .extraExtraExtraLarge)
//}
//
//#Preview("XS 60min") {
//    let activity60min = CalendarActivity.forPreview(duration: 60 * 60)
//    let event60 = CalendarEvent.forPreview(activity: activity60min)
//    EventView(event: event60, selectionAction: .none)
//        .environment(\.sizeCategory, .extraSmall)
//}
