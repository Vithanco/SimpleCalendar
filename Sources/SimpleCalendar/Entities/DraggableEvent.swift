//
// Created by Paul Peelen
// Copyright © 2023 AppTrix AB. All rights reserved.
//

import Foundation
import UniformTypeIdentifiers
import CoreTransferable

/// Transfer type for drag and drop operations
struct DraggableEventTransfer: Codable, Transferable {
    let eventId: String
    let originalStartDate: Date
    let duration: Double

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .draggableCalendarEvent)
    }
}

extension UTType {
    static let draggableCalendarEvent = UTType(exportedAs: "com.simplecalendar.event")
}
