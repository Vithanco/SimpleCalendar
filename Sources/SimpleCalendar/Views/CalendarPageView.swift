//
//  SwiftUIView.swift
//  
//
//  Created by Paul Peelen on 2023-09-09.
//

import SwiftUI

struct CalendarPageView: View {
    let hours: [String]
    @Binding var hourSpacing: Double
    @Binding var hourHeight: Double

    var body: some View {
        VStack(alignment: .leading, spacing: hourSpacing) {
            ForEach(hours, id: \.self) { hour in
                HStack(alignment: .top, spacing: 0) {
                    // Hour label - aligned to top with small offset
                    Text(hour)
                        .font(Font.caption)
                        .minimumScaleFactor(0.7)
                        .frame(width: 35, alignment: .trailing)
                        .foregroundColor(.secondary)
                        .dynamicTypeSize(.small ... .large)
                        .offset(y: -6) // Move up to align with hour line
                        .padding(.trailing, 4)

                    // Tick mark and divider
                    ZStack(alignment: .topLeading) {
                        // Full-width divider (very light, for reference only)
                        Divider()
                            .foregroundColor(.secondary.opacity(0.15))
                            .frame(height: hourHeight)

                        // Prominent tick mark at the top - this marks the exact hour
                        Rectangle()
                            .fill(Color.primary.opacity(0.5))
                            .frame(width: 20, height: 2)
                    }
                    .frame(height: hourHeight)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

//
//#Preview("PageView") {
//    CalendarPageView(hours: ["12 am", "1 am", "2 am", "3 am", "4 am"], hourSpacing: .constant(24), hourHeight: .constant(30))
//}
