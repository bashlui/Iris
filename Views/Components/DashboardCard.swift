//
//  DashboardCard.swift
//  Iris
//
//  Created by toño on 05/02/26.
//
//  Reusable card for home dashboard: title, description, icon, action button.
//

import SwiftUI

struct DashboardCard: View {
    let title: String
    let description: String
    let iconName: String
    let buttonTitle: String
    let colorOne: Color
    let colorTwo: Color
    var isHorizontal: Bool = false
    let action: () -> Void
    
    @ScaledMetric(relativeTo: .title2) private var iconSize: CGFloat = 60
    @ScaledMetric(relativeTo: .title2) private var horizontalIconSize: CGFloat = 50
    
    var body: some View {
        ZStack {
            colorOne
            
            VStack(spacing: 15) {
                if !isHorizontal {
                    Spacer()
                }
                
                Image(systemName: iconName)
                    .font(.system(size: isHorizontal ? horizontalIconSize : iconSize))
                    .foregroundStyle(.white)
                    .symbolEffect(.bounce, value: true)
                    .accessibilityHidden(true)
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    
                    Text(description)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.95))
                        .padding(.horizontal, 10)
                }
                
                if !isHorizontal {
                    Spacer()
                }
                
                Button(action: action) {
                    Text(buttonTitle)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
                .accessibilityLabel("\(buttonTitle) for \(title)")
                .padding(.bottom, isHorizontal ? 0 : 20)
            }
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: colorOne.opacity(0.3), radius: 20, x: 0, y: 10)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title): \(description)")
    }
}

// Optional: Preview for just this component
#Preview {
    DashboardCard(
        title: "Test Card",
        description: "This is a test description.",
        iconName: "eye",
        buttonTitle: "Start",
        colorOne: .blue,
        colorTwo: .cyan,
        action: {}
    )
    .padding()
    .background(Color.black)
}
