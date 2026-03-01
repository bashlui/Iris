//
//  Challenge.swift
//  Iris
//
//  Created by toño on 05/02/26.
//
//  Challenge model and kinds: emoji finder, prescription reading, distant typing.
//

import Foundation
import SwiftUI

// MARK: - Challenge Kind

enum ChallengeKind: Hashable {
    case findEmoji      // Find emoji in grid (myopia blur)
    case prescriptionReading  // Read prescription (astigmatism streaks)
    case distantTyping  // Type distant text (myopia blur, hardest)
}

// MARK: - Challenge

struct Challenge: Identifiable, Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Challenge, rhs: Challenge) -> Bool { lhs.id == rhs.id }
    
    let id = UUID()
    let title: String
    let description: String
    let condition: EyeCondition
    let difficultyRating: Int
    let iconName: String
    let accentColor: Color
    let instructions: String
    let goalDescription: String
    let kind: ChallengeKind
    
    var isLocked: Bool = true
    var isCompleted: Bool = false
    
    // MARK: - The Three Visual Puzzle Challenges
    
    static let allChallenges: [Challenge] = [
        Challenge(
            title: "Find the Emoji",
            description: "Find a specific emoji in a grid of similar ones through myopia blur. Can you spot 🍎 among 🍏?",
            condition: .myopia,
            difficultyRating: 1,
            iconName: "face.smiling",
            accentColor: .cyan,
            instructions: "A grid of emojis is shown through simulated myopia.\n\nFind and tap the specific emoji displayed at the top. Be careful — similar emojis are mixed in!",
            goalDescription: "Find the target emoji",
            kind: .findEmoji,
            isLocked: false
        ),
        
        Challenge(
            title: "Read the Prescription",
            description: "Read a blurry eye prescription through astigmatism distortion. Select the correct values.",
            condition: .astigmatism,
            difficultyRating: 2,
            iconName: "doc.text.magnifyingglass",
            accentColor: .purple,
            instructions: "A medical prescription is shown through astigmatism simulation.\n\nTry to read the prescription values and select the correct answer from the options below.",
            goalDescription: "Select the correct prescription values",
            kind: .prescriptionReading,
            isLocked: true
        ),
        
        Challenge(
            title: "Distant Reading",
            description: "Type text displayed far away with strong myopia blur. The hardest challenge!",
            condition: .myopia,
            difficultyRating: 3,
            iconName: "text.magnifyingglass",
            accentColor: .orange,
            instructions: "Text is displayed as if from far away, with strong myopia blur.\n\nType exactly what you see. Press 'No' to reduce the blur if you can't read it.",
            goalDescription: "Type the text you see",
            kind: .distantTyping,
            isLocked: true
        )
    ]
}
