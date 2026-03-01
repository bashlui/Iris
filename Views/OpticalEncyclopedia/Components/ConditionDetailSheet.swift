//
//  ConditionDetailSheet.swift
//  Iris
//
//  Created by toño on 11/02/26.
//
//  Sheet with condition details: causes, symptoms, correction methods.
//

import SwiftUI

struct ConditionDetailSheet: View {
    let condition: EyeCondition
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    headerSection
                    
                    // Overview
                    overviewSection
                    
                    // Causes
                    infoSection(
                        title: "Causes",
                        icon: "questionmark.circle.fill",
                        items: condition.causes,
                        color: .orange
                    )
                    
                    // Symptoms
                    infoSection(
                        title: "Symptoms",
                        icon: "eye.trianglebadge.exclamationmark",
                        items: condition.symptoms,
                        color: .red
                    )
                    
                    // Correction Methods
                    infoSection(
                        title: "Correction Methods",
                        icon: "eyeglasses",
                        items: condition.correctionMethods,
                        color: .green
                    )
                    
                    // Prevalence
                    prevalenceSection
                }
                .padding(32)
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .presentationBackground(Color(.systemBackground))
        .presentationCornerRadius(32)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(condition.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: condition.iconName)
                    .font(.system(size: 36))
                    .foregroundStyle(condition.color)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(condition.rawValue)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(condition.description)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(condition.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(condition.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Overview Section
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Overview", systemImage: "doc.text.fill")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text(condition.detailedDescription)
                .font(.system(size: 16))
                .foregroundStyle(.primary.opacity(0.85))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Info Section
    
    private func infoSection(title: String, icon: String, items: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: icon)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)
                        
                        Text(item)
                            .font(.system(size: 15))
                            .foregroundStyle(.primary.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Prevalence Section
    
    private var prevalenceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Prevalence", systemImage: "chart.bar.fill")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(.purple)
            
            Text(condition.prevalence)
                .font(.system(size: 16))
                .foregroundStyle(.primary.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.purple.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.purple.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

#Preview {
    ConditionDetailSheet(condition: .myopia)
        .preferredColorScheme(.dark)
}
