//
//  OnboardingView.swift
//  Iris
//
//  Created by toño on 16/02/26.
//
//  Intro flow explaining vision conditions and app purpose.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    private let totalPages = 4
    
    var body: some View {
        ZStack {
            Group {
                if currentPage == 0 {
                    Color(.systemBackground).ignoresSafeArea()
                } else {
                    Color.black.ignoresSafeArea()
                }
            }
            
            TabView(selection: $currentPage) {
                OnboardingAboutPage()
                    .tag(0)
                
                OnboardingPage1()
                    .tag(1)
                
                OnboardingPage2()
                    .tag(2)
                
                OnboardingPage3(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .accessibilityElement(children: .contain)
            
            if currentPage < 3 {
                VStack {
                    Spacer()
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    } label: {
                        Text("Continue")
                            .font(.body.weight(.medium))
                            .foregroundStyle(currentPage == 0 ? .primary : Color.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(currentPage == 0 ? Color.primary.opacity(0.1) : Color.white.opacity(0.2))
                            )
                    }
                    .accessibilityLabel("Continue to next page")
                    .accessibilityHint("Page \(currentPage + 1) of \(totalPages)")
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

// MARK: - Page 0: About Me (for Swift Student Challenge)
struct OnboardingAboutPage: View {
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
                .padding(.bottom, 100)
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

// MARK: - Page 1: Blurry Circle with Statistic
struct OnboardingPage1: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color(red: 0.65, green: 0.8, blue: 0.95))
                        .frame(width: 350, height: 350)
                        .blur(radius: 35)
                        .accessibilityHidden(true)
                    
                    VStack(spacing: 6) {
                        HStack(spacing: 0) {
                            Text("To ")
                            Text("2.2 billion")
                                .fontWeight(.bold)
                                .italic()
                            Text(" people,")
                        }
                        Text("the world looks like")
                        Text("this.")
                    }
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 2)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("To 2.2 billion people, the world looks blurry like this. A blurred circle demonstrates how vision impairment affects daily life.")
                
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

// MARK: - Page 2: Blurry Classroom (No Text)
struct OnboardingPage2: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image("classroom")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 600)
                .blur(radius: 8)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 40)
                .accessibilityLabel("A blurred image of a classroom, demonstrating how students with vision impairment see their learning environment")
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Page 3: Blurry Classroom with Statistics
struct OnboardingPage3: View {
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 24) {
                Image("classroom")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 600)
                    .blur(radius: 8)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .accessibilityHidden(true)
                
                VStack(spacing: 4) {
                    HStack(spacing: 0) {
                        Text("In Mexico, ")
                        Text("1 in 3 children")
                            .fontWeight(.bold)
                            .italic()
                        Text(" struggle with uncorrected vision,")
                    }
                    HStack(spacing: 0) {
                        Text("losing an estimated ")
                        Text("6.3 million years")
                            .fontWeight(.bold)
                            .italic()
                        Text(" of schooling globally.")
                    }
                }
                .font(.body)
                .foregroundStyle(.white.opacity(0.95))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("In Mexico, 1 in 3 children struggle with uncorrected vision, losing an estimated 6.3 million years of schooling globally.")
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button {
                withAnimation(.easeInOut(duration: 0.4)) {
                    hasCompletedOnboarding = true
                }
            } label: {
                Text("Welcome to Iris")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.4, green: 0.5, blue: 0.7))
                    )
            }
            .accessibilityLabel("Welcome to Iris")
            .accessibilityHint("Double tap to enter the app")
            .padding(.bottom, 50)
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
