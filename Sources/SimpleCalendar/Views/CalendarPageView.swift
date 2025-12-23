//
//  SwiftUIView.swift
//  
//
//  Created by Paul Peelen on 2023-09-09.
//

import SwiftUI

struct CalendarPageView: View {
    let hours: [String]
    @Binding var hourHeight: Double

    var body: some View {
        let _ = print("📄 CalendarPageView - hourHeight: \(hourHeight)")
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(hours.enumerated()), id: \.offset) { index, hour in
                HStack(alignment: .top, spacing: 0) {
                    // Hour label aligned with the hour line
                    Text(hour)
                        .font(Font.caption)
                        .minimumScaleFactor(0.7)
                        .frame(width: 35, alignment: .trailing)
                        .foregroundColor(.secondary)
                        .dynamicTypeSize(.small ... .large)
                        .offset(y: -6)  // Offset to center the text with the line

                    // Thin horizontal line marking the exact hour
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 1)
                        .background(GeometryReader { geo in
                            Color.clear.preference(key: HourLinePositionKey.self, value: [index: geo.frame(in: .global).minY])
                        })
                }
                .frame(height: hourHeight, alignment: .top)
            }
        }
        .padding(.horizontal, 16)
        .onPreferenceChange(HourLinePositionKey.self) { positions in
            if let first = positions[0], let second = positions[1], let third = positions[2] {
                print("🎯 Hour line positions - [0]: \(first), [1]: \(second), [2]: \(third), diff: \(second - first)")
            }
        }
    }
}

private struct HourLinePositionKey: PreferenceKey {
    static let defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

//
//#Preview("PageView") {
//    CalendarPageView(hours: ["12 am", "1 am", "2 am", "3 am", "4 am"], hourSpacing: .constant(24), hourHeight: .constant(30))
//}
