//
//  TipCard.swift
//  Iris
//
//  Created by toño on 16/02/26.
//
//  Card for a single vision tip. VisionTip model and TipCard view.
//

import SwiftUI

struct VisionTip: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
    let colorOne: Color
    let colorTwo: Color
    let details: [String]
    let callToAction: String
}

struct TipCard: View {
    let tip: VisionTip
    let onTap: () -> Void
    
    @ScaledMetric(relativeTo: .body) private var cardHeight: CGFloat = 280
    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 180
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Layer 1: Background gradient
                backgroundLayer
                
                // Layer 2: Content overlay
                contentLayer
            }
            .frame(minHeight: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: tip.colorOne.opacity(0.3), radius: 15, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(tip.title), \(tip.subtitle)")
        .accessibilityHint("Double tap to learn more about \(tip.title.lowercased())")
        .accessibilityAddTraits(.isButton)
    }
    
    // MARK: - Background Layer
    
    private var backgroundLayer: some View {
        ZStack {
            tip.colorOne
            
            Image(systemName: tip.iconName)
                .font(.system(size: iconSize, weight: .bold))
                .foregroundStyle(.white.opacity(0.12))
                .rotationEffect(.degrees(-15))
                .offset(x: 60, y: 40)
                .accessibilityHidden(true)
        }
    }
    
    // MARK: - Content Layer
    
    private var contentLayer: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text(tip.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                
                Text(tip.subtitle)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.95))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            HStack {
                Text(tip.details.first ?? "")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 6) {
                    Text("Learn More")
                        .font(.subheadline.weight(.semibold))
                    Image(systemName: "arrow.right")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(tip.colorOne)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.white)
                .clipShape(Capsule())
            }
        }
        .padding(20)
    }
}

// MARK: - Tip Detail Sheet

struct TipDetailSheet: View {
    let tip: VisionTip
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .body) private var heroHeight: CGFloat = 220
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    heroHeader
                    
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(tip.details.enumerated()), id: \.offset) { index, detail in
                            detailRow(index: index + 1, text: detail)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    callToActionCard
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }
    
    // MARK: - Hero Header
    
    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            tip.colorOne
            
            Image(systemName: tip.iconName)
                .font(.system(size: 200, weight: .bold))
                .foregroundStyle(.white.opacity(0.1))
                .rotationEffect(.degrees(-15))
                .offset(x: 100, y: 20)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: tip.iconName)
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .accessibilityHidden(true)
                
                Text(tip.title)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                    .accessibilityAddTraits(.isHeader)
                
                Text(tip.subtitle)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white.opacity(0.95))
            }
            .padding(28)
        }
        .frame(minHeight: heroHeight)
        .clipShape(
            UnevenRoundedRectangle(
                bottomLeadingRadius: 28,
                bottomTrailingRadius: 28
            )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(tip.title), \(tip.subtitle)")
    }
    
    // MARK: - Detail Row
    
    private func detailRow(index: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(index)")
                .font(.callout.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(tip.colorOne)
                )
                .accessibilityHidden(true)
            
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Tip \(index): \(text)")
    }
    
    // MARK: - Call to Action Card
    
    private var callToActionCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "stethoscope")
                .font(.title2)
                .foregroundStyle(tip.colorOne)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Professional Advice")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(tip.callToAction)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal, 24)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Professional Advice: \(tip.callToAction)")
    }
}

// MARK: - Preview

#Preview {
    TipCard(
        tip: VisionTip(
            title: "Know the Signs",
            subtitle: "Warning Signs",
            iconName: "eye.trianglebadge.exclamationmark",
            colorOne: .orange,
            colorTwo: .red,
            details: [
                "You squint frequently to read signs or screens.",
                "Headaches appear after reading or screen time.",
                "Night vision has worsened with halos or glare."
            ],
            callToAction: "If you experience any of these, schedule an eye exam with a professional."
        ),
        onTap: {}
    )
    .padding(24)
    .background(Color(.systemBackground))
}
