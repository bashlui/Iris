//
//  ConditionControlPanel.swift
//  Iris
//
//  Created by toño on 11/02/26.
//
//  Control panel for encyclopedia: condition picker, eye length, correction toggle.
//

import SwiftUI

struct ConditionControlPanel: View {
    let condition: EyeCondition
    @Binding var eyeLength: Float
    let isCorrected: Bool
    let onApplyCorrection: () -> Void
    
    @State private var showingDetailSheet = false
    @State private var showingQuiz = false
    @State private var quizAnswer: Int? = nil
    @State private var hasAnswered = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: condition.iconName)
                        .font(.title)
                        .foregroundStyle(condition.color)
                    
                    Text(condition.rawValue)
                        .font(.title.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(isCorrected || condition == .normal ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        
                        Text(isCorrected || condition == .normal ? "Corrected" : "Uncorrected")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(condition.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Divider()
            
            // Interactive Slider Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Eye Elongation / Distortion")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(String(format: "%.0f%%", eyeLength * 100))
                        .font(.subheadline.weight(.semibold).monospaced())
                        .foregroundStyle(.purple)
                }
                
                Slider(value: $eyeLength, in: 0.0...1.0)
                    .tint(.purple)
                    .disabled(condition == .normal)
                
                Text(sliderHint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(condition == .normal ? 0.5 : 1.0)
            
            // Quick Quiz Section
            if condition != .normal && !showingQuiz {
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        showingQuiz = true
                        hasAnswered = false
                        quizAnswer = nil
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.body)
                        Text("Test Your Understanding")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .accessibilityLabel("Test your understanding with a quick quiz")
            }
            
            // Quiz Content
            if showingQuiz {
                quizSection
            }
            
            // Action Buttons Row
            HStack(spacing: 12) {
                Button(action: onApplyCorrection) {
                    HStack(spacing: 10) {
                        Image(systemName: isCorrected ? "eyeglasses" : "plus.circle.fill")
                            .font(.body)
                        
                        Text(isCorrected ? "Remove Correction" : "Apply Correction")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(condition == .normal)
                .opacity(condition == .normal ? 0.5 : 1.0)
                .accessibilityLabel(isCorrected ? "Remove correction lens" : "Apply correction lens")
                
                Button {
                    showingDetailSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.body)
                        
                        Text("Learn More")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.primary)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityLabel("Learn more about \(condition.rawValue)")
            }
        }
        .padding(24)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        .sheet(isPresented: $showingDetailSheet) {
            ConditionDetailSheet(condition: condition)
        }
    }
    
    // MARK: - Quiz Section
    
    private var quizSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quick Quiz")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        showingQuiz = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Close quiz")
            }
            
            Text(quizQuestion)
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            VStack(spacing: 8) {
                ForEach(0..<quizOptions.count, id: \.self) { index in
                    quizOptionButton(index: index)
                }
            }
            
            if hasAnswered {
                HStack(spacing: 8) {
                    Image(systemName: quizAnswer == correctAnswerIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(quizAnswer == correctAnswerIndex ? .green : .red)
                    
                    Text(quizAnswer == correctAnswerIndex ? "Correct!" : "Not quite. \(quizExplanation)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .transition(.asymmetric(
            insertion: .push(from: .bottom).combined(with: .opacity),
            removal: .push(from: .top).combined(with: .opacity)
        ))
    }
    
    private func quizOptionButton(index: Int) -> some View {
        Button {
            if !hasAnswered {
                withAnimation(.spring(duration: 0.2)) {
                    quizAnswer = index
                    hasAnswered = true
                }
            }
        } label: {
            HStack {
                Text(quizOptions[index])
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if hasAnswered && index == correctAnswerIndex {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else if hasAnswered && quizAnswer == index && index != correctAnswerIndex {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(optionBackgroundColor(for: index))
            )
        }
        .disabled(hasAnswered)
    }
    
    private func optionBackgroundColor(for index: Int) -> Color {
        if !hasAnswered {
            return Color(uiColor: .tertiarySystemBackground)
        }
        if index == correctAnswerIndex {
            return Color.green.opacity(0.2)
        }
        if quizAnswer == index {
            return Color.red.opacity(0.2)
        }
        return Color(uiColor: .tertiarySystemBackground).opacity(0.5)
    }
    
    // MARK: - Quiz Data
    
    private var quizQuestion: String {
        switch condition {
        case .myopia:
            return "Where do light rays focus in myopia (nearsightedness)?"
        case .hyperopia:
            return "What type of lens is used to correct hyperopia?"
        case .astigmatism:
            return "What causes the blurry vision in astigmatism?"
        case .normal:
            return ""
        }
    }
    
    private var quizOptions: [String] {
        switch condition {
        case .myopia:
            return ["Behind the retina", "In front of the retina", "On the retina", "At the lens"]
        case .hyperopia:
            return ["Concave (minus) lens", "Convex (plus) lens", "Cylindrical lens", "No lens needed"]
        case .astigmatism:
            return ["Eye is too long", "Irregular cornea shape", "Cloudy lens", "Damaged retina"]
        case .normal:
            return []
        }
    }
    
    private var correctAnswerIndex: Int {
        switch condition {
        case .myopia: return 1
        case .hyperopia: return 1
        case .astigmatism: return 1
        case .normal: return 0
        }
    }
    
    private var quizExplanation: String {
        switch condition {
        case .myopia:
            return "In myopia, light focuses in front of the retina because the eye is too long."
        case .hyperopia:
            return "Hyperopia requires a convex lens to add focusing power."
        case .astigmatism:
            return "An irregular cornea causes light to focus at multiple points."
        case .normal:
            return ""
        }
    }
    
    private var sliderHint: String {
        switch condition {
        case .myopia:
            return "Move the slider to see how eye length affects where light focuses. Higher values = more severe myopia."
        case .hyperopia:
            return "Adjust to see how the eye's focusing power affects vision. Higher values = more severe hyperopia."
        case .astigmatism:
            return "See how corneal irregularity creates multiple focal points and distorted vision."
        case .normal:
            return "Normal vision focuses light directly on the retina."
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ConditionControlPanel(
            condition: .myopia,
            eyeLength: .constant(0.7),
            isCorrected: false,
            onApplyCorrection: {}
        )
        .padding(40)
    }
}
