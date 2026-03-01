//
//  AboutView.swift
//  Iris
//
//  Created by toño on 05/02/26.
//
//  About screen: app info, author, Swift Student Challenge.
//

import SwiftUI

struct AboutView: View {
    @ScaledMetric(relativeTo: .body) private var memojiSize: CGFloat = 250
    @ScaledMetric(relativeTo: .body) private var iconBoxSize: CGFloat = 50
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("About")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.primary)
                    .padding(.top, 60)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .accessibilityAddTraits(.isHeader)
                
                HStack(alignment: .top, spacing: 40) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 300, height: 300)
                            .accessibilityHidden(true)
                        
                        Image("memoji")
                            .resizable()
                            .scaledToFit()
                            .frame(width: memojiSize, height: memojiSize)
                            .accessibilityLabel("Luis Antonio's memoji avatar")
                    }
                    .frame(width: 350, height: 350)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("**Hi!** I'm Luis Antonio (Tony).")
                                .font(.title)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("I'm a Computer Science student at **Tecnológico de Monterrey** in Mexico.")
                                .font(.body)
                                .foregroundStyle(.primary.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Text("I have viewed the world in prescription lenses since I was a child. I know firsthand that clear vision is a privilege, yet the struggle of \"bad eyesight\" is often invisible to others.")
                            .font(.body)
                            .foregroundStyle(.primary.opacity(0.9))
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("I created **Iris** to bridge the gap. By combining optical physics with code, I want to turn empathy into a tangible experience, helping users understand what it truly feels like to navigate the world with visual impairments.")
                            .font(.body)
                            .foregroundStyle(.primary.opacity(0.9))
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Key Technologies")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(.primary)
                                .padding(.top, 12)
                                .accessibilityAddTraits(.isHeader)
                            
                            technologyRow(
                                icon: "camera.filters",
                                iconColor: .blue,
                                title: "Core Image:",
                                description: "Real-time blur and distortion filters simulate myopia, astigmatism, and cataracts on the live camera feed."
                            )
                            
                            technologyRow(
                                icon: "square.grid.3x3.fill",
                                iconColor: .purple,
                                title: "Visual Puzzles:",
                                description: "Empathy challenges use SF Symbol grids, letter recognition, and color identification — all under an active impairment overlay."
                            )
                            
                            technologyRow(
                                icon: "eye.trianglebadge.exclamationmark",
                                iconColor: .indigo,
                                title: "Interactive Education:",
                                description: "Split-screen simulation and visual puzzle challenges turn empathy into a tangible, hands-on experience."
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemBackground))
    }
    
    private func technologyRow(icon: String, iconColor: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: iconBoxSize, height: iconBoxSize)
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(iconColor)
            }
            .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.primary.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    AboutView()
        .preferredColorScheme(.dark)
}
