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
                ZStack(alignment: .topLeading) {
                    // Full-width divider at the top
                    HStack(spacing: 0) {
                        Spacer()
                            .frame(width: 55) // Space for label + tick
                        Divider()
                            .foregroundColor(.secondary.opacity(0.3))
                    }

                    // Hour label and tick mark
                    HStack(alignment: .center, spacing: 4) {
                        Text(hour)
                            .font(Font.caption)
                            .minimumScaleFactor(0.7)
                            .frame(width: 35, alignment: .trailing)
                            .foregroundColor(.secondary)
                            .dynamicTypeSize(.small ... .large)

                        // Hour tick mark - visible horizontal line
                        Rectangle()
                            .fill(Color.secondary)
                            .frame(width: 10, height: 2)
                    }
                    .offset(y: -6) // Move up to align with hour line
                }
                .frame(height: hourHeight)
            }
        }
        .padding(.horizontal, 16)
    }
}

//
//#Preview("PageView") {
//    CalendarPageView(hours: ["12 am", "1 am", "2 am", "3 am", "4 am"], hourSpacing: .constant(24), hourHeight: .constant(30))
//}
