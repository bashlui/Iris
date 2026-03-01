//
//  ChallengeCard.swift
//  Iris
//
//  Created by toño on 11/02/26.
//
//  Card for a single challenge: title, condition, description, play button.
//

import SwiftUI

struct ChallengeCard: View {
    let challenge: Challenge
    let onPlay: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isShaking = false
    @ScaledMetric(relativeTo: .body) private var cardHeight: CGFloat = 320
    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 180
    
    var body: some View {
        Button {
            if challenge.isLocked {
                triggerShake()
            } else {
                onPlay()
            }
        } label: {
            ZStack {
                backgroundLayer
                contentLayer
            }
            .frame(minHeight: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(
                color: challenge.isLocked ? .clear : challenge.accentColor.opacity(0.3),
                radius: 15,
                x: 0,
                y: 8
            )
            .offset(x: isShaking ? -5 : 0)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint(challenge.isLocked ? "This challenge is locked. Complete previous challenges to unlock." : "Double tap to play this challenge")
        .accessibilityAddTraits(challenge.isLocked ? .isButton : [.isButton])
    }
    
    private var accessibilityDescription: String {
        let status = challenge.isCompleted ? "Completed" : (challenge.isLocked ? "Locked" : "Available")
        let difficultyStars = String(repeating: "star ", count: challenge.difficultyRating).trimmingCharacters(in: .whitespaces)
        return "\(challenge.title), \(challenge.condition.rawValue) challenge, \(status), Difficulty: \(difficultyStars), \(challenge.difficultyRating) out of 3"
    }
    
    // MARK: - Condition Tag Styling
    
    private var conditionLabelColor: Color {
        guard !challenge.isLocked else { return .gray }
        if colorScheme == .dark {
            return challenge.condition.color.opacity(1.0)
        }
        return challenge.condition.color
    }
    
    private var conditionTagBackground: some ShapeStyle {
        if challenge.isLocked {
            return AnyShapeStyle(.ultraThinMaterial)
        }
        if colorScheme == .dark {
            return AnyShapeStyle(Color.white.opacity(0.25))
        }
        return AnyShapeStyle(.ultraThinMaterial)
    }
    
    // MARK: - Background Layer
    
    private var backgroundLayer: some View {
        ZStack {
            if challenge.isLocked {
                Color(uiColor: .systemGray5)
            } else {
                challenge.accentColor
            }
            
            Image(systemName: challenge.iconName)
                .font(.system(size: iconSize, weight: .bold))
                .foregroundStyle(challenge.isLocked ? .gray.opacity(0.1) : .white.opacity(0.15))
                .rotationEffect(.degrees(-15))
                .offset(x: 60, y: 40)
                .accessibilityHidden(true)
        }
    }
    
    // MARK: - Content Layer
    
    private var contentLayer: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text(challenge.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(challenge.isLocked ? .gray : .white)
                
                Text(challenge.condition.rawValue)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(challenge.isLocked ? .gray : conditionLabelColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(conditionTagBackground)
                    .clipShape(Capsule())
                
                Text(challenge.description)
                    .font(.caption)
                    .foregroundStyle(challenge.isLocked ? .gray.opacity(0.8) : .white.opacity(0.9))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 4) {
                    Text("Difficulty")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(challenge.isLocked ? .gray.opacity(0.6) : .white.opacity(0.9))
                    
                    Spacer()
                    
                    difficultyStars
                }
            }
            
            Spacer()
            
            HStack {
                if challenge.isLocked {
                    lockedIndicator
                } else {
                    playIndicator
                }
                
                Spacer()
            }
        }
        .padding(20)
    }
    
    // MARK: - Difficulty Stars
    
    private var difficultyStars: some View {
        HStack(spacing: 4) {
            ForEach(1...3, id: \.self) { star in
                Image(systemName: "star.fill")
                    .font(.callout)
                    .foregroundStyle(
                        star <= challenge.difficultyRating
                            ? (challenge.isLocked ? .gray : .yellow)
                            : (challenge.isLocked ? .gray.opacity(0.3) : .white.opacity(0.3))
                    )
            }
        }
        .accessibilityHidden(true)
    }
    
    // MARK: - Play Indicator
    
    private var playIndicator: some View {
        HStack(spacing: 6) {
            Image(systemName: "play.fill")
                .font(.caption)
            
            Text("Play")
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(challenge.accentColor)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.white)
        .clipShape(Capsule())
    }
    
    // MARK: - Locked Indicator
    
    private var lockedIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.subheadline)
            
            Text("Locked")
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(.gray.opacity(0.7))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.gray.opacity(0.2))
        .clipShape(Capsule())
    }
    
    // MARK: - Shake Animation
    
    private func triggerShake() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(duration: 0.1)) {
            isShaking = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(duration: 0.1)) {
                isShaking = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(duration: 0.1)) {
                    isShaking = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(duration: 0.1)) {
                        isShaking = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 24)], spacing: 24) {
            ChallengeCard(
                challenge: Challenge.allChallenges[0],
                onPlay: {}
            )
            
            ChallengeCard(
                challenge: Challenge.allChallenges[1],
                onPlay: {}
            )
            
            ChallengeCard(
                challenge: Challenge.allChallenges[2],
                onPlay: {}
            )
        }
        .padding(24)
    }
    .background(Color.black)
}
