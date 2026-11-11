//
//  Duration.swift
//  LearningJourney
//
//  Created by alanoud on 01/06/1448 AH.
//  LearningGoal هذا اوبجكت رح استخدمه في كلاس 

enum Duration: String, Codable, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: Self { self }

    var freezeLimit: Int {
        switch self {
        case .week: return 2
        case .month: return 8
        case .year: return 96
        }
    }
}
