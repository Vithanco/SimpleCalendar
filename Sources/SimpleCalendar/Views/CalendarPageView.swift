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
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(hour)
                        .font(Font.caption)
                        .minimumScaleFactor(0.7)
                        .frame(width: 35, alignment: .trailing)
                        .foregroundColor(.secondary)
                        .dynamicTypeSize(.small ... .large)
                        .padding(.trailing, 4)

                    ZStack(alignment: .topLeading) {
                        // Full-width divider (very light, for reference only)
                        Divider()
                            .foregroundColor(.secondary.opacity(0.15))

                        // Prominent tick mark at the top - this marks the exact hour
                        Rectangle()
                            .fill(Color.primary.opacity(0.5))
                            .frame(width: 20, height: 2)
                            .alignmentGuide(.firstTextBaseline) { d in d[.top] }
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
