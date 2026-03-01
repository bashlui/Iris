//
//  HomeView.swift
//  Iris
//
//  Created by toño on 05/02/26.
//
//  Lab tab: dashboard cards for Simulator, Challenges, Encyclopedia.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: AppTab
    @State private var showChallenges = false
    @State private var showSimulator = false
    
    @ScaledMetric(relativeTo: .largeTitle) private var cardSpacing: CGFloat = 20
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: cardSpacing) {
                    
                    Text("Welcome to Iris")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.primary)
                        .padding(.top, 60)
                        .padding(.horizontal)
                        .accessibilityAddTraits(.isHeader)
                    
                    HStack(spacing: cardSpacing) {
                        DashboardCard(
                            title: "Vision Simulator",
                            description: "Split-screen camera: compare clear vision with simulated blur and conditions.",
                            iconName: "eye",
                            buttonTitle: "Start Simulation",
                            colorOne: Color.blue,
                            colorTwo: Color.cyan
                        ) {
                            showSimulator = true
                        }
                        
                        DashboardCard(
                            title: "Optical Encyclopedia",
                            description: "Master the physics of refraction. Explore interactive 3D models of the human eye.",
                            iconName: "book.closed",
                            buttonTitle: "Open Library",
                            colorOne: Color.indigo,
                            colorTwo: Color.purple
                        ) {
                            withAnimation(.snappy) {
                                selectedTab = .theory
                            }
                        }
                    }
                    .frame(maxHeight: 350)
                    .padding(.horizontal)
                    
                    DashboardCard(
                        title: "Empathy Challenges",
                        description: "Don't just see it, live it. Attempt daily tasks like 'Reading the Board' or 'Night Driving'.",
                        iconName: "figure.walk",
                        buttonTitle: "Start Challenge",
                        colorOne: Color.green,
                        colorTwo: Color.mint,
                        isHorizontal: true
                    ) {
                        showChallenges = true
                    }
                    .frame(maxHeight: 250)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
            }
            .background(Color(.systemBackground))
            .fullScreenCover(isPresented: $showChallenges) {
                ChallengesListView()
            }
            .fullScreenCover(isPresented: $showSimulator) {
                SimulatorView()
            }
        }
    }
}

