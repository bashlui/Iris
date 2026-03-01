//
//  PuzzleChallengeView.swift
//  Iris
//
//  Created by toño on 11/02/26.
//
//  Unified view for emoji, prescription, and typing challenges with impairment overlay.
//

import SwiftUI

struct PuzzleChallengeView: View {
    let challenge: Challenge
    let onComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PuzzleChallengeViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    init(challenge: Challenge, onComplete: @escaping () -> Void) {
        self.challenge = challenge
        self.onComplete = onComplete
        _viewModel = State(initialValue: PuzzleChallengeViewModel(kind: challenge.kind))
    }
    
    private var columns: [GridItem] {
        switch challenge.kind {
        case .findEmoji:
            return Array(repeating: GridItem(.flexible(), spacing: 8), count: 8)
        case .prescriptionReading, .distantTyping:
            return []
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let insets = geometry.safeAreaInsets
            
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    topBar
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    
                    impairmentBadge
                        .padding(.top, 8)
                    
                    instructionBanner
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    
                    Spacer(minLength: 12)
                    
                    puzzleArea
                        .padding(.horizontal, 16)
                    
                    Spacer(minLength: 12)
                    
                    statusBar
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
                .padding(insets)
                
                // "Can you see it?" prompt — bottom right corner
                if viewModel.isAskingVisibility {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            visibilityPromptContent
                                .padding(.bottom, insets.bottom + 12)
                                .padding(.trailing, insets.trailing + 12)
                        }
                    }
                    .allowsHitTesting(true)
                }
                
                if viewModel.isSolved {
                    successOverlay
                }
                
                if viewModel.isOutOfTries {
                    failOverlay
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.impairmentIntensity)
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Close")
            
            Spacer()
            
            Text(challenge.title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(challenge.accentColor.opacity(0.15))
                .clipShape(Capsule())
            
            Spacer()
            
            livesIndicator
        }
    }
    
    // MARK: - Impairment Badge
    
    private var impairmentBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "eye.slash")
                .font(.system(size: 12, weight: .semibold))
            Text("Impairment: \(viewModel.impairmentPercentLabel)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(viewModel.impairmentIntensity > 0.5 ? .red : (viewModel.impairmentIntensity > 0 ? .orange : .green))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
    
    // MARK: - Lives
    
    private var livesIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<viewModel.maxWrongTaps, id: \.self) { i in
                Image(systemName: i < (viewModel.maxWrongTaps - viewModel.wrongTaps) ? "heart.fill" : "heart")
                    .font(.system(size: 16))
                    .foregroundStyle(i < (viewModel.maxWrongTaps - viewModel.wrongTaps) ? .red : .gray.opacity(0.4))
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityLabel("\(viewModel.maxWrongTaps - viewModel.wrongTaps) lives remaining")
    }
    
    // MARK: - Instruction
    
    private var instructionBanner: some View {
        VStack(spacing: 8) {
            Text(viewModel.hasStartedSearching ? challenge.goalDescription : "Look through the impairment...")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            // Show target emoji for emoji challenge
            if challenge.kind == .findEmoji && viewModel.hasStartedSearching {
                HStack(spacing: 8) {
                    Text("Find:")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text(viewModel.targetEmoji)
                        .font(.system(size: 32))
                    Text("(\(viewModel.remainingTargets) left)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(challenge.accentColor.opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Puzzle Grid + Impairment Overlay
    
    private var puzzleBlurRadius: CGFloat {
        let intensity = viewModel.impairmentIntensity
        switch challenge.kind {
        case .findEmoji:
            return intensity * 8    // Myopia blur for emoji grid
        case .prescriptionReading:
            return intensity * 6    // Astigmatism blur
        case .distantTyping:
            return intensity * 12   // Strong myopia blur for distant text
        }
    }
    
    private var puzzleArea: some View {
        ZStack {
            puzzleGrid
                .blur(radius: puzzleBlurRadius)
                .allowsHitTesting(viewModel.hasStartedSearching)
            impairmentOverlay
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .scaleEffect(viewModel.showWrongFeedback ? 0.98 : 1.0)
        .animation(.spring(duration: 0.2), value: viewModel.showWrongFeedback)
    }
    
    @ViewBuilder
    private var puzzleGrid: some View {
        switch challenge.kind {
        case .findEmoji:
            emojiGrid
        case .prescriptionReading:
            prescriptionView
        case .distantTyping:
            distantTypingView
        }
    }
    
    // MARK: - Emoji Grid
    
    private var emojiGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(viewModel.cells) { cell in
                Button {
                    viewModel.didTap(cell.id)
                } label: {
                    Text(cell.emoji)
                        .font(.system(size: 28))
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(cell.isTarget ? Color.clear : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(cell.isTarget ? Color.clear : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(EmojiButtonStyle())
                .accessibilityLabel(cell.isTarget ? "Target emoji" : "Emoji")
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
    }
    
    // MARK: - Prescription View
    
    private var prescriptionView: some View {
        VStack(spacing: 24) {
            // Prescription card
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.red)
                    Text("Eye Prescription")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Spacer()
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("OD (Right Eye)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    
                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SPH")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.tertiary)
                            Text(viewModel.prescriptionSphere)
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CYL")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.tertiary)
                            Text(viewModel.prescriptionCylinder)
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("AXIS")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.tertiary)
                            Text("\(viewModel.prescriptionAxis)°")
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                        }
                    }
                }
            }
            .padding(20)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Answer options (only shown when playing)
            if viewModel.hasStartedSearching {
                VStack(spacing: 12) {
                    Text("Select the correct values:")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    ForEach(0..<viewModel.prescriptionOptions.count, id: \.self) { index in
                        let option = viewModel.prescriptionOptions[index]
                        Button {
                            viewModel.selectPrescription(index)
                        } label: {
                            HStack(spacing: 16) {
                                Text("\(option.sphere)")
                                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                Text("\(option.cylinder)")
                                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                Text("\(option.axis)°")
                                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.selectedPrescriptionIndex == index ? challenge.accentColor.opacity(0.2) : Color(.tertiarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(viewModel.selectedPrescriptionIndex == index ? challenge.accentColor : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(12)
    }
    
    // MARK: - Distant Typing View
    
    private var distantTypingView: some View {
        VStack(spacing: 32) {
            // Distant text display
            VStack(spacing: 16) {
                Text("Read the text below:")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Text(viewModel.distantText)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .tracking(8)
                    .foregroundStyle(.primary)
                    .padding(.vertical, 40)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            // Typing input (only shown when playing)
            if viewModel.hasStartedSearching {
                VStack(spacing: 16) {
                    Text("Type what you see:")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    TextField("", text: Binding(
                        get: { viewModel.typedText },
                        set: { viewModel.typedText = $0 }
                    ))
                    .font(.system(size: 24, weight: .semibold, design: .monospaced))
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(challenge.accentColor.opacity(0.5), lineWidth: 2)
                    )
                    .focused($isTextFieldFocused)
                    
                    Button {
                        viewModel.submitTyping()
                    } label: {
                        Text("Submit")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(challenge.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(viewModel.typedText.isEmpty)
                    .opacity(viewModel.typedText.isEmpty ? 0.5 : 1.0)
                }
            }
        }
        .padding(12)
    }
    
    // MARK: - Impairment Overlays (intensity-driven, on top of puzzle)
    
    @ViewBuilder
    private var impairmentOverlay: some View {
        let intensity = viewModel.impairmentIntensity
        
        switch challenge.kind {
        case .findEmoji:
            // Myopia: frosted blur layer
            Rectangle()
                .fill(.thickMaterial)
                .opacity(Double(intensity) * 0.85)
            
        case .prescriptionReading:
            // Astigmatism: thick material + directional distortion
            ZStack {
                Rectangle()
                    .fill(.thickMaterial)
                    .opacity(Double(intensity) * 0.75)
                
                // Streaky overlay effect
                LinearGradient(
                    colors: [
                        Color.white.opacity(Double(intensity) * 0.3),
                        Color.clear,
                        Color.white.opacity(Double(intensity) * 0.2),
                        Color.clear,
                        Color.white.opacity(Double(intensity) * 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .scaleEffect(x: 1.0 + intensity * 0.03, y: 1.0 + intensity * 0.08)
            
        case .distantTyping:
            // Strong myopia: heavy frosted blur for distant objects
            Rectangle()
                .fill(.ultraThickMaterial)
                .opacity(Double(intensity) * 0.9)
        }
    }
    
    // MARK: - "Can you see it?" Prompt (corner overlay)
    
    private var visibilityPromptContent: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "eye.trianglebadge.exclamationmark")
                    .font(.system(size: 18))
                    .foregroundStyle(challenge.accentColor)
                Text("Can you see the \(kindLabel)?")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.trailing)
            }
            
            // Show target emoji explicitly for emoji challenge
            if challenge.kind == .findEmoji {
                HStack(spacing: 8) {
                    Text("Find:")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text(viewModel.targetEmoji)
                        .font(.system(size: 36))
                }
            }
            
            HStack(spacing: 6) {
                Image(systemName: "eye.slash")
                    .font(.system(size: 11, weight: .semibold))
                Text("Impairment: \(viewModel.impairmentPercentLabel)")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
            }
            .foregroundStyle(viewModel.impairmentIntensity > 0.5 ? .red : .orange)
            
            HStack(spacing: 6) {
                Button {
                    withAnimation { viewModel.reduceImpairment() }
                } label: {
                    Text("No")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(Capsule())
                }
                .disabled(viewModel.impairmentIntensity <= 0)
                .opacity(viewModel.impairmentIntensity <= 0 ? 0.5 : 1.0)
                
                Button {
                    withAnimation { viewModel.confirmCanSee() }
                } label: {
                    Text("Yes")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(challenge.accentColor)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
        )
        .frame(maxWidth: 160)
    }
    
    private var kindLabel: String {
        switch challenge.kind {
        case .findEmoji: return "emoji"
        case .prescriptionReading: return "prescription"
        case .distantTyping: return "text"
        }
    }
    
    // MARK: - Status Bar
    
    private var statusBar: some View {
        HStack {
            Label(challenge.condition.rawValue, systemImage: challenge.condition.iconName)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            
            Spacer()
            
            if viewModel.hasStartedSearching {
                Text("Wrong: \(viewModel.wrongTaps)/\(viewModel.maxWrongTaps)")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Success Overlay
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: viewModel.isSolved)
                
                Text("Well done!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("You found it at \(viewModel.finalIntensityLabel) impairment.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                if viewModel.impairmentIntensity < 1.0 {
                    Text("You needed the impairment reduced — imagine living with this every day.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                HStack(spacing: 12) {
                    Button {
                        viewModel.generateGrid()
                    } label: {
                        Label("Play Again", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    
                    Button {
                        onComplete()
                        dismiss()
                    } label: {
                        Text("Complete")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(challenge.accentColor)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(32)
        }
        .transition(.opacity)
    }
    
    // MARK: - Fail Overlay
    
    private var failOverlay: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.red)
                
                Text("Out of tries")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("This is how hard it is with \(challenge.condition.rawValue.lowercased()). Try again!")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button {
                    viewModel.generateGrid()
                } label: {
                    Label("Try Again", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(challenge.accentColor)
                        .clipShape(Capsule())
                }
            }
            .padding(32)
        }
        .transition(.opacity)
    }
}

// MARK: - Emoji Button Style

struct EmojiButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Emoji Challenge") {
    PuzzleChallengeView(
        challenge: Challenge.allChallenges[0],
        onComplete: {}
    )
}

#Preview("Prescription Challenge") {
    PuzzleChallengeView(
        challenge: Challenge.allChallenges[1],
        onComplete: {}
    )
}

#Preview("Distant Typing Challenge") {
    PuzzleChallengeView(
        challenge: Challenge.allChallenges[2],
        onComplete: {}
    )
}
