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
                HStack(alignment: .top, spacing: 4) {
                    Text(hour)
                        .font(Font.caption)
                        .minimumScaleFactor(0.7)
                        .frame(width: 35, alignment: .trailing)
                        .foregroundColor(.secondary)
                        .dynamicTypeSize(.small ... .large)
                        .offset(y: -6) // Align label with the tick mark

                    VStack(spacing: 0) {
                        // Hour tick mark
                        Rectangle()
                            .fill(Color.secondary.opacity(0.9))
                            .frame(width: 8, height: 1)

                        // Full-width divider
                        Divider()
                            .foregroundColor(.secondary.opacity(0.9))
                            .padding(.leading, -8)
                    }
                    .frame(height: hourHeight, alignment: .top)
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
