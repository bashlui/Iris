//
//  EyeCondition.swift
//  Iris
//
//  Created by toño on 05/02/26.
//
//  Eye conditions: normal, myopia, hyperopia, astigmatism. Descriptions and metadata.
//

import Foundation
import SwiftUI

enum EyeCondition: String, CaseIterable, Identifiable {
    case normal = "Normal Vision"
    case myopia = "Myopia"
    case hyperopia = "Hyperopia"
    case astigmatism = "Astigmatism"
    
    var id: String { rawValue }
    
    // The asset icon name (SF Symbol)
    var iconName: String {
        switch self {
        case .normal: return "eye"
        case .myopia: return "arrow.down.right.and.arrow.up.left" // Pinching in
        case .hyperopia: return "arrow.up.left.and.arrow.down.right" // Expanding out
        case .astigmatism: return "circle.dashed"
        }
    }
    
    // Educational description for the UI
    var description: String {
        switch self {
        case .normal:
            return "Perfect focus. Light lands directly on the retina."
        case .myopia:
            return "Nearsightedness. Light focuses in front of the retina, making distant objects blurry."
        case .hyperopia:
            return "Farsightedness. Light focuses behind the retina, making close objects blurry."
        case .astigmatism:
            return "Irregular Cornea. Light scatters into multiple focal points, creating streaks and distortion."
        }
    }
    
    // The color theme for this condition
    var color: Color {
        switch self {
        case .normal: return .green
        case .myopia: return .blue
        case .hyperopia: return .orange
        case .astigmatism: return .purple
        }
    }
    
    // MARK: - Detailed Educational Content
    
    var detailedDescription: String {
        switch self {
        case .normal:
            return """
            In a healthy eye with normal vision (also called emmetropia), the optical system works perfectly. Light rays entering the eye are precisely focused onto the retina, creating a sharp, clear image.
            
            The cornea and lens work together to bend (refract) light rays so they converge exactly on the retina's surface. This precise focusing allows you to see objects clearly at various distances.
            """
        case .myopia:
            return """
            Myopia, commonly known as nearsightedness, is a refractive error where distant objects appear blurry while close objects remain clear. This occurs when the eyeball is too long or the cornea is too curved.
            
            In myopic eyes, light rays focus in front of the retina instead of directly on it. The further the focal point is from the retina, the more severe the blur for distant objects.
            
            Myopia typically develops during childhood and may progress until early adulthood. It affects approximately 30% of the global population, with rates increasing in recent decades.
            """
        case .hyperopia:
            return """
            Hyperopia, or farsightedness, is a refractive error where close objects appear blurry while distant objects may be clearer. This happens when the eyeball is too short or the cornea is too flat.
            
            In hyperopic eyes, light rays would theoretically focus behind the retina. The eye's lens can sometimes compensate by increasing its curvature (accommodation), but this causes eye strain.
            
            Many children are born with mild hyperopia that naturally corrects as they grow. However, significant hyperopia requires correction with convex (plus power) lenses.
            """
        case .astigmatism:
            return """
            Astigmatism is a refractive error caused by an irregularly shaped cornea or lens. Instead of being spherical like a basketball, the cornea is shaped more like a football, with different curvatures in different meridians.
            
            This irregular shape causes light to focus on multiple points rather than a single point on the retina, resulting in blurred or distorted vision at all distances. People with astigmatism may see streaks around lights at night.
            
            Astigmatism often occurs alongside myopia or hyperopia and is very common—most people have some degree of astigmatism. It's corrected with cylindrical lenses that compensate for the uneven curvature.
            """
        }
    }
    
    var causes: [String] {
        switch self {
        case .normal:
            return [
                "Properly shaped eyeball length",
                "Correctly curved cornea",
                "Healthy, flexible lens",
                "Good overall eye health"
            ]
        case .myopia:
            return [
                "Elongated eyeball (axial myopia)",
                "Excessively curved cornea",
                "Genetic predisposition",
                "Extended near work (reading, screens)",
                "Limited outdoor time during childhood"
            ]
        case .hyperopia:
            return [
                "Shortened eyeball",
                "Flat cornea curvature",
                "Weak lens focusing power",
                "Genetic factors",
                "Natural aging process"
            ]
        case .astigmatism:
            return [
                "Irregularly shaped cornea",
                "Irregular lens curvature",
                "Eye injury or surgery",
                "Keratoconus (corneal thinning)",
                "Hereditary factors"
            ]
        }
    }
    
    var symptoms: [String] {
        switch self {
        case .normal:
            return [
                "Clear vision at all distances",
                "No eye strain during visual tasks",
                "Comfortable reading and screen use",
                "No headaches from visual effort"
            ]
        case .myopia:
            return [
                "Blurry distance vision",
                "Squinting to see clearly",
                "Eye strain and headaches",
                "Difficulty seeing while driving",
                "Need to sit closer to screens/boards"
            ]
        case .hyperopia:
            return [
                "Blurry close-up vision",
                "Eye strain during reading",
                "Headaches after near work",
                "Difficulty focusing on close objects",
                "Fatigue during detailed tasks"
            ]
        case .astigmatism:
            return [
                "Blurred vision at all distances",
                "Distorted or stretched images",
                "Eye strain and discomfort",
                "Difficulty with night vision",
                "Halos or streaks around lights"
            ]
        }
    }
    
    var correctionMethods: [String] {
        switch self {
        case .normal:
            return [
                "No correction needed",
                "Regular eye exams recommended",
                "Maintain healthy visual habits"
            ]
        case .myopia:
            return [
                "Concave (minus) glasses lenses",
                "Soft or rigid contact lenses",
                "LASIK or PRK surgery",
                "Orthokeratology (overnight lenses)",
                "Atropine drops (for progression control)"
            ]
        case .hyperopia:
            return [
                "Convex (plus) glasses lenses",
                "Contact lenses",
                "LASIK or PRK surgery",
                "Refractive lens exchange",
                "Reading glasses (for presbyopia)"
            ]
        case .astigmatism:
            return [
                "Cylindrical (toric) glasses lenses",
                "Toric contact lenses",
                "Rigid gas permeable contacts",
                "LASIK or PRK surgery",
                "Limbal relaxing incisions"
            ]
        }
    }
    
    var prevalence: String {
        switch self {
        case .normal:
            return "Varies by population and age group"
        case .myopia:
            return "Affects ~30% globally, up to 90% in some East Asian countries"
        case .hyperopia:
            return "Affects ~10% of the population, increases with age"
        case .astigmatism:
            return "Affects ~30-40% of the population to some degree"
        }
    }
}
