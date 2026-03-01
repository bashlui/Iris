//
//  SimulatorView.swift
//  Iris
//
//  Created by toño on 11/02/26.
//
//  Full-screen split-screen vision simulator. Core Image blur on live camera.
//

import SwiftUI

struct SimulatorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var simulationState = SimulationState()
    @State private var cameraManager = CameraManager()
    @State private var isCameraReady = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            CameraSimulatorView(
                simulationState: $simulationState,
                cameraManager: cameraManager
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                
                Spacer()
                
                controlPanel
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
            
            if !cameraManager.isCameraAvailable {
                VStack {
                    HStack {
                        Spacer()
                        Label("Test Pattern Mode", systemImage: "camera.fill")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 70)
                    Spacer()
                }
            }
        }
        .statusBarHidden()
        .task {
            let granted = await cameraManager.checkPermissions()
            if granted {
                cameraManager.startSession()
                isCameraReady = true
            }
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack(spacing: 16) {
            // Close button
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.8))
                    .symbolRenderingMode(.hierarchical)
            }
            
            Spacer()
            
            // Condition Picker (pill-style)
            conditionPicker
            
            Spacer()
            
            // Split-screen toggle
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    simulationState.isSplitViewActive.toggle()
                }
            } label: {
                Image(systemName: simulationState.isSplitViewActive
                      ? "rectangle.split.2x1.fill"
                      : "rectangle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Condition Picker
    
    private var conditionPicker: some View {
        HStack(spacing: 0) {
            ForEach(EyeCondition.allCases) { condition in
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        simulationState.activeCondition = condition
                        if condition == .normal {
                            simulationState.severity = 0
                        } else if simulationState.severity <= 0 {
                            simulationState.severity = 3.0
                        }
                    }
                } label: {
                    Text(shortLabel(for: condition))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(
                            simulationState.activeCondition == condition ? .black : .white
                        )
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background {
                            if simulationState.activeCondition == condition {
                                Capsule().fill(.white)
                            }
                        }
                }
            }
        }
        .padding(4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
    
    // MARK: - Control Panel
    
    private var controlPanel: some View {
        VStack(spacing: 16) {
            Text("See through different vision conditions in real time.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Severity", systemImage: "eye")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text(simulationState.formattedSeverity)
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.purple)
                }
                
                Text("Blur intensity (0 = clear, 10 = severe)")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                
                Slider(value: $simulationState.severity, in: 0...10, step: 0.5)
                    .tint(.purple)
                    .disabled(simulationState.activeCondition == .normal)
            }
            .opacity(simulationState.activeCondition == .normal ? 0.4 : 1.0)
            
            // Astigmatism Axis (visible only for astigmatism)
            if simulationState.activeCondition == .astigmatism {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Axis Angle", systemImage: "angle")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text(String(format: "%.0f°", simulationState.astigmatismAxis))
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.indigo)
                    }
                    
                    Text("Direction of blur streaks (like prescription axis)")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                    
                    Slider(value: $simulationState.astigmatismAxis, in: 0...180, step: 5)
                        .tint(.indigo)
                }
                .transition(.asymmetric(
                    insertion: .push(from: .bottom).combined(with: .opacity),
                    removal: .push(from: .top).combined(with: .opacity)
                ))
            }
            
            // Split Position (visible when split is active)
            if simulationState.isSplitViewActive {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Split Position", systemImage: "slider.horizontal.below.rectangle")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("Original")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(.green)
                            Text("|")
                                .foregroundStyle(.white.opacity(0.3))
                            Text("Simulated")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(.orange)
                        }
                    }
                    
                    Text("Slide to compare clear vs impaired view side by side")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                    
                    Slider(value: $simulationState.splitPosition, in: 0.05...0.95)
                        .tint(.white)
                }
                .transition(.asymmetric(
                    insertion: .push(from: .bottom).combined(with: .opacity),
                    removal: .push(from: .top).combined(with: .opacity)
                ))
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .frame(maxWidth: 500)
    }
    
    // MARK: - Helpers
    
    private func shortLabel(for condition: EyeCondition) -> String {
        switch condition {
        case .normal:      return "Normal"
        case .myopia:      return "Myopia"
        case .hyperopia:   return "Hyperopia"
        case .astigmatism: return "Astigmatism"
        }
    }
}

// MARK: - Preview

#Preview {
    SimulatorView()
}
