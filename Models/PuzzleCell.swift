//
//  PuzzleCell.swift
//  Iris
//
//  Created by toño on 05/02/26.
//
//  Single cell in a visual puzzle grid (emoji, character, or color).
//

import SwiftUI

struct PuzzleCell: Identifiable {
    let id: Int
    let isTarget: Bool
    
    var emoji: String = "😀"       // For findEmoji challenge
    var character: Character = " "  // Legacy
    var color: Color = .gray         // Legacy
}
