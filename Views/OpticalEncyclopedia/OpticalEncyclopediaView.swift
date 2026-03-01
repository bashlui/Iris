//
//  OpticalEncyclopediaView.swift
//  Iris
//
//  Created by toño on 11/02/26.
//
//  Theory tab: split view with condition list and 3D eye + control panel.
//

import SwiftUI

struct OpticalEncyclopediaView: View {
    @State private var viewModel = OpticalEncyclopediaViewModel()
    @State private var isControlPanelVisible = true
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            sidebarContent
                .navigationSplitViewColumnWidth(min: 280, ideal: 300, max: 320)
        } detail: {
            detailContent
        }
        .navigationSplitViewStyle(.prominentDetail)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Sidebar Content
    
    private var sidebarContent: some View {
        ZStack {
            Color(.systemBackground).opacity(0.8)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Conditions")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    .accessibilityAddTraits(.isHeader)
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(EyeCondition.allCases) { condition in
                            ConditionRow(
                                condition: condition,
                                isSelected: viewModel.selectedCondition == condition,
                                onSelect: {
                                    viewModel.selectCondition(condition)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Detail Content
    
    private var detailContent: some View {
        ZStack {
            Color(uiColor: .systemGray6)
            
            HStack(spacing: 0) {
                // Left side: 3D Eye Model
                ZStack {
                    Color.black
                    
                    Eye3DSceneView(
                        selectedCondition: viewModel.selectedCondition,
                        eyeLength: viewModel.eyeLength,
                        isCorrected: viewModel.isCorrected
                    )
                    .accessibilityLabel("3D eye model showing \(viewModel.selectedCondition.rawValue)")
                    
                    // Legend overlay on the 3D view
                    VStack {
                        HStack {
                            Spacer()
                            legendCard
                        }
                        .padding(16)
                        
                        Spacer()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.leading, 20)
                .padding(.vertical, 20)
                
                // Right side: Control Panel
                ScrollView {
                    VStack {
                        if isControlPanelVisible {
                            ZStack(alignment: .topTrailing) {
                                ConditionControlPanel(
                                    condition: viewModel.selectedCondition,
                                    eyeLength: $viewModel.eyeLength,
                                    isCorrected: viewModel.isCorrected,
                                    onApplyCorrection: {
                                        viewModel.toggleCorrection()
                                    }
                                )
                                
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        isControlPanelVisible = false
                                    }
                                } label: {
                                    Image(systemName: "chevron.up.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white.opacity(0.8))
                                        .symbolRenderingMode(.hierarchical)
                                }
                                .accessibilityLabel("Hide controls")
                                .padding(12)
                            }
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        } else {
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    isControlPanelVisible = true
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.down.circle.fill")
                                        .font(.body)
                                    Text("Show Controls")
                                        .font(.subheadline.weight(.medium))
                                }
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .clipShape(Capsule())
                            }
                            .accessibilityLabel("Show controls panel")
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .padding(20)
                }
                .frame(width: 380)
            }
        }
    }
    
    private var legendCard: some View {
        VStack(alignment: .trailing, spacing: 8) {
            legendItem(color: .green, text: "Focus on Retina")
            legendItem(color: .red, text: "Focus Off Retina")
            
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.yellow)
                    .frame(width: 20, height: 4)
                    .accessibilityHidden(true)
                Text("Light Rays")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Legend: Green indicates focus on retina, red indicates focus off retina, yellow lines represent light rays")
    }
    
    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .accessibilityHidden(true)
            Text(text)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}

// MARK: - Condition Row Component

struct ConditionRow: View {
    let condition: EyeCondition
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                Image(systemName: condition.iconName)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : condition.color)
                    .frame(width: 32, height: 32)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(condition.rawValue)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(isSelected ? .white : .primary.opacity(0.9))
                    
                    Text(shortDescription(for: condition))
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(.white)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.indigo : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(condition.rawValue), \(shortDescription(for: condition))")
        .accessibilityValue(isSelected ? "Selected" : "")
        .accessibilityHint("Double tap to select this condition")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .animation(.spring(duration: 0.3), value: isSelected)
    }
    
    private func shortDescription(for condition: EyeCondition) -> String {
        switch condition {
        case .normal: return "Perfect vision"
        case .myopia: return "Nearsighted"
        case .hyperopia: return "Farsighted"
        case .astigmatism: return "Distorted"
        }
    }
}

// MARK: - Preview

#Preview {
    OpticalEncyclopediaView()
        .preferredColorScheme(.dark)
}
