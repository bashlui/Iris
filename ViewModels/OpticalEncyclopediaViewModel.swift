//
//  OpticalEncyclopediaViewModel.swift
//  Iris
//
//  Created by toño on 11/02/26.
//
//  State for optical encyclopedia: selected condition, eye length, correction toggle.
//

import SwiftUI
import Observation

@Observable
class OpticalEncyclopediaViewModel {
    // MARK: - State Variables
    var selectedCondition: EyeCondition = .normal
    var eyeLength: Float = 0.5
    var isCorrected: Bool = false
    
    // MARK: - Computed Properties
    
    // Ray convergence point for 3D eye (condition + eye length)
    var rayConvergenceOffset: Float {
        switch selectedCondition {
        case .normal:
            return 0.0 // Rays converge at the back (retina)
        case .myopia:
            // Rays converge before the retina (negative offset)
            return -0.3 * eyeLength
        case .hyperopia:
            // Rays converge behind the retina (positive offset)
            return 0.3 * eyeLength
        case .astigmatism:
            // Multiple focal points - use a scattered effect
            return 0.0
        }
    }
    
    // Correction lens power for 3D display
    var correctionPower: Float {
        switch selectedCondition {
        case .normal:
            return 0.0
        case .myopia:
            return -eyeLength * 2.0 // Concave lens
        case .hyperopia:
            return eyeLength * 2.0 // Convex lens
        case .astigmatism:
            return eyeLength * 1.5 // Cylindrical lens
        }
    }
    
    // MARK: - Actions
    
    func selectCondition(_ condition: EyeCondition) {
        withAnimation(.spring(duration: 0.4, bounce: 0.3)) {
            selectedCondition = condition
            // Reset correction when changing conditions
            isCorrected = false
            // Set default eye length based on condition
            switch condition {
            case .normal:
                eyeLength = 0.5
            case .myopia:
                eyeLength = 0.7
            case .hyperopia:
                eyeLength = 0.6
            case .astigmatism:
                eyeLength = 0.5
            }
        }
    }
    
    func toggleCorrection() {
        withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
            isCorrected.toggle()
        }
    }
    
    func updateEyeLength(_ value: Float) {
        withAnimation(.spring(duration: 0.2)) {
            eyeLength = value
        }
    }
}
