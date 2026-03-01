//
//  ChallengesViewModel.swift
//  Iris
//
//  Created by toño on 11/02/26.
//
//  Manages challenge list, selection, completion, and unlocking.
//

import SwiftUI
import Observation

@Observable
@MainActor
class ChallengesViewModel {
    // MARK: - Properties
    var challenges: [Challenge] = Challenge.allChallenges
    var activeChallengeIndex: Int?
    
    // Drives fullScreenCover: non-nil shows challenge, nil dismisses
    var presentedChallenge: Challenge?
    
    // MARK: - Computed Properties
    
    var activeChallenge: Challenge? {
        guard let idx = activeChallengeIndex else { return nil }
        guard idx >= 0, idx < challenges.count else { return nil }
        return challenges[idx]
    }
    
    var completedCount: Int {
        challenges.filter { $0.isCompleted }.count
    }
    
    var unlockedCount: Int {
        challenges.filter { !$0.isLocked }.count
    }
    
    var allCompleted: Bool {
        challenges.allSatisfy { $0.isCompleted }
    }
    
    // MARK: - Actions
    
    func selectChallenge(_ challenge: Challenge) {
        guard !challenge.isLocked else { return }
        if let idx = challenges.firstIndex(where: { $0.id == challenge.id }) {
            activeChallengeIndex = idx
            presentedChallenge = challenges[idx]
        }
    }
    
    func completeCurrentChallenge() {
        guard let idx = activeChallengeIndex else { return }
        
        challenges[idx].isCompleted = true
        
        // Unlock the next challenge
        let nextIndex = idx + 1
        if nextIndex < challenges.count && challenges[nextIndex].isLocked {
            challenges[nextIndex].isLocked = false
        }
        
        // Clear active selection
        activeChallengeIndex = nil
        presentedChallenge = nil
    }
    
    func dismissActiveChallenge() {
        activeChallengeIndex = nil
        presentedChallenge = nil
    }
    
    func resetProgress() {
        challenges = Challenge.allChallenges
        activeChallengeIndex = nil
        presentedChallenge = nil
    }
}
