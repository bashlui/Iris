//
//  ChallengesListView.swift
//  Iris
//
//  Created by toño on 11/02/26.
//
//  Grid of empathy challenges with progress indicator.
//

import SwiftUI

struct ChallengesListView: View {
    @State private var viewModel = ChallengesViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @ScaledMetric(relativeTo: .body) private var gridSpacing: CGFloat = 24
    
    private let columns = [
        GridItem(.adaptive(minimum: 300), spacing: 24)
    ]
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        return NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: gridSpacing) {
                        headerSection
                        challengesGrid
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.callout.weight(.semibold))
                            
                            Text("Back")
                                .font(.callout.weight(.medium))
                        }
                        .foregroundStyle(.primary)
                    }
                    .accessibilityLabel("Go back")
                }
            }
            .fullScreenCover(item: $viewModel.presentedChallenge) { challenge in
                PuzzleChallengeView(
                    challenge: challenge,
                    onComplete: { viewModel.completeCurrentChallenge() }
                )
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Empathy Challenges")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.primary)
                .padding(.top, 20)
                .accessibilityAddTraits(.isHeader)
            
            Text("Experience the real impact of visual conditions. Solve visual puzzles while looking through simulated impairments — blurring, streaks, and haze — to feel firsthand how these conditions affect everyday tasks.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            progressIndicator
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .accessibilityHidden(true)
                
                Text("\(viewModel.completedCount) / \(viewModel.challenges.count) Completed")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(viewModel.completedCount) of \(viewModel.challenges.count) challenges completed")
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: "lock.open.fill")
                    .foregroundStyle(.cyan)
                    .accessibilityHidden(true)
                
                Text("\(viewModel.unlockedCount) Unlocked")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(viewModel.unlockedCount) challenges unlocked")
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Challenges Grid
    
    private var challengesGrid: some View {
        LazyVGrid(columns: columns, spacing: gridSpacing) {
            ForEach(viewModel.challenges) { challenge in
                ChallengeCard(challenge: challenge) {
                    viewModel.selectChallenge(challenge)
                }
                .overlay {
                    if challenge.isCompleted {
                        completedBadge
                    }
                }
            }
        }
    }
    
    // MARK: - Completed Badge
    
    private var completedBadge: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .shadow(color: .green.opacity(0.5), radius: 6)
                    .padding(12)
                    .accessibilityHidden(true)
            }
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    ChallengesListView()
}
