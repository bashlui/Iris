//
//  MainView.swift
//  Iris
//
//  Created by toño on 05/02/26.
//
//  Root view: tab bar (Lab, Theory, Tips) and onboarding gate.
//

import SwiftUI

// Global tab enum accessible from other views
enum AppTab: String, CaseIterable {
    case lab = "Lab"
    case theory = "Theory"
    case tips = "Tips"
}

struct MainView: View {
    // Controls onboarding state - persisted with AppStorage
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // Controls which screen is visible
    @State private var selectedTab: AppTab = .lab
    
    var body: some View {
        ZStack {
            // Onboarding: fades out and slightly scales down when leaving
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .opacity(hasCompletedOnboarding ? 0 : 1)
                .scaleEffect(hasCompletedOnboarding ? 0.98 : 1)
                .allowsHitTesting(!hasCompletedOnboarding)
            
            // Main app: fades in and slightly scales up when entering
            mainAppContent
                .opacity(hasCompletedOnboarding ? 1 : 0)
                .scaleEffect(hasCompletedOnboarding ? 1 : 0.98)
                .allowsHitTesting(hasCompletedOnboarding)
        }
        .animation(.easeInOut(duration: 0.6), value: hasCompletedOnboarding)
    }
    
    // MARK: - Main App Content
    private var mainAppContent: some View {
        ZStack(alignment: .top) {
            // 1. The Background
            Color(.systemBackground).ignoresSafeArea()
            
            // 2. The Content Switcher
            Group {
                switch selectedTab {
                case .lab:
                    HomeView(selectedTab: $selectedTab)
                case .theory:
                    OpticalEncyclopediaView()
                case .tips:
                    VisionTipsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 3. The Custom "Pill" Tab Bar (Floating on Top)
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.snappy) {
                            selectedTab = tab
                        }
                    } label: {
                        Text(tab.rawValue)
                            .font(.system(.subheadline, design: .rounded).weight(.medium))
                            .foregroundStyle(selectedTab == tab ? Color(.systemBackground) : .primary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background {
                                if selectedTab == tab {
                                    Capsule()
                                        .fill(Color.primary)
                                        .matchedGeometryEffect(id: "ActiveTab", in: animationNamespace)
                                }
                            }
                    }
                }
            }
            .padding(4)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(.top, 10)
        }
    }
    
    // For the sliding animation of the white pill
    @Namespace private var animationNamespace
}
