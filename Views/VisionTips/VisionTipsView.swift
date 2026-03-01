//
//  VisionTipsView.swift
//  Iris
//
//  Created by toño on 16/02/26.
//
//  Tips tab: grid of vision care tips and habits.
//

import SwiftUI

// MARK: - Main View

struct VisionTipsView: View {
    @State private var selectedTip: VisionTip?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var cardSpacing: CGFloat = 24
    
    private let columns = [
        GridItem(.adaptive(minimum: 300), spacing: 24)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: cardSpacing) {
                // Header
                headerSection
                
                // Tips Grid
                tipsGrid
                
                // Disclaimer
                disclaimerFooter
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .sheet(item: $selectedTip) { tip in
            TipDetailSheet(tip: tip)
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vision Tips")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.primary)
                .padding(.top, 60)
                .accessibilityAddTraits(.isHeader)
            
            Text("Learn about your vision, recognize warning signs early, and discover habits that protect your eyes. Knowledge is the first step toward better sight.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    // MARK: - Tips Grid
    
    private var tipsGrid: some View {
        LazyVGrid(columns: columns, spacing: cardSpacing) {
            ForEach(VisionTipsData.allTips) { tip in
                TipCard(tip: tip) {
                    selectedTip = tip
                }
            }
        }
    }
    
    // MARK: - Disclaimer
    
    private var disclaimerFooter: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.body)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            
            Text("Iris is for **educational purposes only** and does not replace professional medical advice. If you have concerns about your vision, please consult a qualified eye care professional.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Disclaimer: Iris is for educational purposes only and does not replace professional medical advice. If you have concerns about your vision, please consult a qualified eye care professional.")
    }
}

// MARK: - Tips Data

enum VisionTipsData {
    static let allTips: [VisionTip] = [
        VisionTip(
            title: "Know the Signs",
            subtitle: "Warning Signs",
            iconName: "eye.trianglebadge.exclamationmark",
            colorOne: .orange,
            colorTwo: .red,
            details: [
                "You squint frequently to read signs, boards, or screens — this is your eye muscles trying to compensate for blurry focus.",
                "Persistent headaches appear after reading or extended screen time, often behind the eyes or around the temples.",
                "Night vision has worsened — you notice halos, glare, or streaks around lights while driving or walking.",
                "You hold your phone closer or push books further away to make text readable.",
                "Covering one eye reveals noticeably different clarity between your left and right eye."
            ],
            callToAction: "If you experience two or more of these signs, schedule a comprehensive eye exam. Early detection makes treatment simpler and more effective."
        ),
        
        VisionTip(
            title: "When to See a Doctor",
            subtitle: "Urgent Attention",
            iconName: "stethoscope",
            colorOne: .red,
            colorTwo: Color(red: 0.7, green: 0.1, blue: 0.2),
            details: [
                "Sudden loss of vision in one or both eyes — even temporarily — needs immediate emergency care.",
                "Flashes of light or a sudden increase in floaters can signal retinal detachment, a sight-threatening condition.",
                "Persistent eye pain or redness that doesn't improve in 24 hours may indicate infection or inflammation.",
                "Double vision that appears suddenly can be a sign of neurological issues beyond the eye itself.",
                "Any eye injury — even if it seems minor — should be evaluated to prevent long-term damage.",
                "Children who tilt their head, sit too close to screens, or lose focus frequently should have their vision tested."
            ],
            callToAction: "Don't wait for pain. Many serious eye conditions are painless in early stages. Annual eye exams are the best defense."
        ),
        
        VisionTip(
            title: "The 20-20-20 Rule",
            subtitle: "Digital Eye Care",
            iconName: "desktopcomputer",
            colorOne: .blue,
            colorTwo: .cyan,
            details: [
                "Every 20 minutes, look at something 20 feet (6 meters) away for at least 20 seconds.",
                "This relaxes the ciliary muscle inside your eye, which tenses up during close-focus work like reading or coding.",
                "Blink frequently — we blink 66% less when staring at screens, leading to dry, irritated eyes.",
                "Position your screen at arm's length and slightly below eye level to reduce strain on your eye muscles.",
                "Lower screen brightness in dark rooms and enable Night Shift or True Tone to reduce blue light exposure.",
                "Consider blue-light filtering glasses if you work more than 6 hours a day on screens."
            ],
            callToAction: "Digital eye strain is reversible with good habits. If symptoms persist after adjusting your routine, consult an optometrist."
        ),
        
        VisionTip(
            title: "Protect Your Vision",
            subtitle: "Daily Habits",
            iconName: "shield.checkered",
            colorOne: .green,
            colorTwo: .mint,
            details: [
                "Spend at least 1-2 hours outdoors daily — natural light has been shown to slow myopia progression, especially in children.",
                "Wear UV-protective sunglasses outdoors, even on cloudy days. UV exposure increases risk of cataracts and macular degeneration.",
                "Eat foods rich in omega-3, lutein, and vitamin A — fish, leafy greens, carrots, and eggs support retinal health.",
                "Stay hydrated — dehydration directly affects tear production, leading to dry eyes and blurred vision.",
                "Get 7-8 hours of quality sleep — your eyes repair and replenish moisture overnight.",
                "Never rub your eyes aggressively — this can damage the cornea and worsen conditions like keratoconus."
            ],
            callToAction: "Good vision habits formed today can prevent serious conditions decades later. Prevention is always easier than treatment."
        ),
        
        VisionTip(
            title: "Your Device Can Help",
            subtitle: "iOS Accessibility",
            iconName: "accessibility",
            colorOne: .indigo,
            colorTwo: .purple,
            details: [
                "Dynamic Type lets you increase text size system-wide — go to Settings > Accessibility > Display & Text Size.",
                "Zoom magnifies your entire screen or a window up to 15x — triple-tap with three fingers to activate.",
                "Bold Text makes all interface text thicker and easier to read at a glance.",
                "Increase Contrast enhances the visual separation between text and backgrounds across all apps.",
                "Reduce Transparency makes backgrounds solid instead of translucent, improving readability.",
                "Larger Accessibility Sizes unlocks even bigger text options beyond the standard Dynamic Type range."
            ],
            callToAction: "Apple builds powerful vision accessibility into every device. Explore Settings > Accessibility to customize your experience."
        ),
        
        VisionTip(
            title: "Vision in Children",
            subtitle: "Early Detection",
            iconName: "figure.and.child.holdinghands",
            colorOne: .pink,
            colorTwo: .orange,
            details: [
                "80% of what children learn is through their eyes — undetected vision problems directly affect academic performance.",
                "Children rarely complain about blurry vision because they don't know what \"normal\" looks like.",
                "Watch for signs: sitting too close to the TV, losing place while reading, frequent eye rubbing, or tilting the head.",
                "The American Academy of Ophthalmology recommends a first eye exam at 6 months, then at age 3, and before first grade.",
                "Myopia in children is increasing globally — the WHO links it to more screen time and less outdoor play.",
                "Early correction with glasses not only improves vision but can slow the progression of conditions like myopia."
            ],
            callToAction: "If you notice any signs in a child, schedule a pediatric eye exam. Early intervention can change a child's life."
        )
    ]
}

// MARK: - Preview

#Preview {
    VisionTipsView()
        .preferredColorScheme(.dark)
}
