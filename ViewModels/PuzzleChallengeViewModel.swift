//
//  PuzzleChallengeViewModel.swift
//  Iris
//
//  Created by toño on 11/02/26.
//
//  Grid generation and tap logic for emoji, prescription, and typing challenges.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class PuzzleChallengeViewModel {
    
    // MARK: - State
    
    private(set) var cells: [PuzzleCell] = []
    private(set) var isSolved = false
    private(set) var wrongTaps = 0
    let maxWrongTaps = 3
    private(set) var showWrongFeedback = false
    
    let kind: ChallengeKind
    
    // Impairment 1.0 = full blur. Drops 0.2 per "No" tap
    private(set) var impairmentIntensity: CGFloat = 1.0
    private let intensityStep: CGFloat = 0.2
    private(set) var startingIntensity: CGFloat = 1.0
    
    // Visibility prompt: "Can you see it?" before grid is tappable
    private(set) var isAskingVisibility = true
    private(set) var hasStartedSearching = false
    
    // MARK: - Emoji Challenge State
    
    private(set) var targetEmoji: String = "😀"
    
    // MARK: - Prescription Challenge State
    
    private(set) var prescriptionSphere: String = "-2.50"
    private(set) var prescriptionCylinder: String = "-1.25"
    private(set) var prescriptionAxis: String = "180"
    private(set) var prescriptionOptions: [(sphere: String, cylinder: String, axis: String)] = []
    private(set) var correctPrescriptionIndex: Int = 0
    var selectedPrescriptionIndex: Int = -1
    
    // MARK: - Distant Typing Challenge State
    
    private(set) var distantText: String = "HELLO"
    var typedText: String = ""
    private(set) var hasSubmittedTyping = false
    
    // MARK: - Init
    
    init(kind: ChallengeKind) {
        self.kind = kind
        generateGrid()
    }
    
    // MARK: - Visibility prompt actions
    
    func confirmCanSee() {
        isAskingVisibility = false
        hasStartedSearching = true
    }
    
    func reduceImpairment() {
        impairmentIntensity = max(0, impairmentIntensity - intensityStep)
        if impairmentIntensity <= 0 {
            isAskingVisibility = false
            hasStartedSearching = true
        }
    }
    
    // MARK: - Grid Generation
    
    func generateGrid() {
        isSolved = false
        wrongTaps = 0
        showWrongFeedback = false
        impairmentIntensity = 1.0
        startingIntensity = 1.0
        isAskingVisibility = true
        hasStartedSearching = false
        selectedPrescriptionIndex = -1
        typedText = ""
        hasSubmittedTyping = false
        
        switch kind {
        case .findEmoji:
            generateEmojiGrid()
        case .prescriptionReading:
            generatePrescription()
        case .distantTyping:
            generateDistantText()
        }
    }
    
    // MARK: - Emoji Grid Generation
    
    private func generateEmojiGrid() {
        let total = 64 // 8x8 grid
        let targetCount = Int.random(in: 3...6) // Multiple targets to find
        var targetIndices = Set<Int>()
        while targetIndices.count < targetCount {
            targetIndices.insert(Int.random(in: 0..<total))
        }
        
        // Emoji sets with very similar emojis (target, distractors)
        let emojiSets: [(target: String, distractors: [String])] = [
            ("🍎", ["🍏", "🍒", "🍑"]),           // Red apple vs green apple, cherries, peach
            ("😀", ["😃", "😄", "😁"]),           // Grinning face variations
            ("🌸", ["🌺", "🌷", "💮"]),           // Cherry blossom vs hibiscus, tulip
            ("🔵", ["🟦", "💙", "🫐"]),           // Blue circle vs blue square, heart, blueberry
            ("⭐", ["🌟", "✨", "💫"]),           // Star variations
            ("🐱", ["🐈", "😺", "😸"]),           // Cat face variations
            ("🏠", ["🏡", "🏘️", "🏚️"]),          // House variations
            ("❤️", ["💗", "💖", "💕"]),           // Heart variations
            ("🌙", ["🌛", "🌜", "🌝"]),           // Moon variations
            ("🎵", ["🎶", "🎼", "♪"]),            // Music note variations
        ]
        
        let set = emojiSets.randomElement() ?? emojiSets[0]
        targetEmoji = set.target
        
        cells = (0..<total).map { i in
            var cell = PuzzleCell(id: i, isTarget: targetIndices.contains(i))
            if targetIndices.contains(i) {
                cell.emoji = set.target
            } else {
                cell.emoji = set.distractors.randomElement() ?? set.distractors[0]
            }
            return cell
        }
    }
    
    // MARK: - Prescription Generation
    
    private func generatePrescription() {
        // Generate realistic prescription values
        let sphereValues = ["-0.50", "-1.00", "-1.50", "-2.00", "-2.50", "-3.00", "-3.50", "-4.00"]
        let cylinderValues = ["-0.25", "-0.50", "-0.75", "-1.00", "-1.25", "-1.50", "-1.75"]
        let axisValues = ["15", "45", "75", "90", "105", "135", "165", "180"]
        
        prescriptionSphere = sphereValues.randomElement() ?? "-2.00"
        prescriptionCylinder = cylinderValues.randomElement() ?? "-1.00"
        prescriptionAxis = axisValues.randomElement() ?? "90"
        
        // Generate 4 options, one correct
        correctPrescriptionIndex = Int.random(in: 0..<4)
        prescriptionOptions = (0..<4).map { i in
            if i == correctPrescriptionIndex {
                return (prescriptionSphere, prescriptionCylinder, prescriptionAxis)
            } else {
                // Generate similar but wrong values
                var wrongSphere = sphereValues.randomElement() ?? "-2.00"
                var wrongCylinder = cylinderValues.randomElement() ?? "-1.00"
                var wrongAxis = axisValues.randomElement() ?? "90"
                
                // Make sure at least one value is different
                while wrongSphere == prescriptionSphere && wrongCylinder == prescriptionCylinder && wrongAxis == prescriptionAxis {
                    wrongSphere = sphereValues.randomElement() ?? "-2.00"
                    wrongCylinder = cylinderValues.randomElement() ?? "-1.00"
                    wrongAxis = axisValues.randomElement() ?? "90"
                }
                
                return (wrongSphere, wrongCylinder, wrongAxis)
            }
        }
        
        cells = []
    }
    
    // MARK: - Distant Text Generation
    
    private func generateDistantText() {
        // Words/phrases that get progressively harder
        let textOptions = [
            "HELLO",
            "WORLD",
            "VISION",
            "CLARITY",
            "FOCUS",
            "MYOPIA",
            "GLASSES",
            "READING",
            "DISTANT",
            "BLURRY",
            "OPTOMETRY",
            "PRESCRIPTION",
        ]
        
        distantText = textOptions.randomElement() ?? "HELLO"
        cells = []
    }
    
    // MARK: - Tap Handling
    
    func didTap(_ index: Int) {
        guard hasStartedSearching, !isSolved, !isOutOfTries else { return }
        guard index >= 0, index < cells.count else { return }
        
        if cells[index].isTarget {
            // Mark this cell as found
            cells[index] = PuzzleCell(id: cells[index].id, isTarget: false, emoji: cells[index].emoji)
            
            // Check if all targets are found
            let remainingTargets = cells.filter { $0.isTarget }.count
            if remainingTargets == 0 {
                isSolved = true
            }
        } else {
            wrongTaps += 1
            showWrongFeedback = true
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 400_000_000)
                showWrongFeedback = false
            }
        }
    }
    
    // MARK: - Prescription Selection
    
    func selectPrescription(_ index: Int) {
        guard hasStartedSearching, !isSolved, !isOutOfTries else { return }
        selectedPrescriptionIndex = index
        
        if index == correctPrescriptionIndex {
            isSolved = true
        } else {
            wrongTaps += 1
            showWrongFeedback = true
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 400_000_000)
                showWrongFeedback = false
                selectedPrescriptionIndex = -1
            }
        }
    }
    
    // MARK: - Typing Submission
    
    func submitTyping() {
        guard hasStartedSearching, !isSolved, !isOutOfTries else { return }
        hasSubmittedTyping = true
        
        let normalizedInput = typedText.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedTarget = distantText.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if normalizedInput == normalizedTarget {
            isSolved = true
        } else {
            wrongTaps += 1
            showWrongFeedback = true
            hasSubmittedTyping = false
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 400_000_000)
                showWrongFeedback = false
            }
        }
    }
    
    var isOutOfTries: Bool {
        wrongTaps >= maxWrongTaps && !isSolved
    }
    
    var impairmentPercentLabel: String {
        "\(Int(impairmentIntensity * 100))%"
    }
    
    var finalIntensityLabel: String {
        "\(Int(impairmentIntensity * 100))%"
    }
    
    var remainingTargets: Int {
        cells.filter { $0.isTarget }.count
    }
}
