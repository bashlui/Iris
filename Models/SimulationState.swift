//
//  SimulationState.swift
//  Iris
//
//  Created by toño on 05/02/26.
//
//  Simulator state: condition, severity, split position, astigmatism axis.
//

import Foundation

struct SimulationState {
    // Currently selected eye condition (normal, myopia, hyperopia, astigmatism)
    var activeCondition: EyeCondition = .myopia
    
    // Severity 0–10. Drives Core Image blur radius for the simulated side
    var severity: Float = 3.0
    
    // When true, split screen shows clear vs blurred. When false, full blurred
    var isSplitViewActive: Bool = true
    
    // Split divider position: 0 = all clear, 1 = all blurred, 0.5 = half and half
    var splitPosition: Float = 0.5
    
    // Astigmatism axis in degrees (0–180). Direction of blur streaks
    var astigmatismAxis: Float = 45.0
    
    // Display string for severity (e.g. "3.0 D")
    var formattedSeverity: String {
        if activeCondition == .normal { return "0.0 D" }
        return String(format: "%.1f D", severity)
    }
}
