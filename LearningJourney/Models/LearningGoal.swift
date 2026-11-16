//
//  LearningGoal.swift
//  LearningJourney
//
//  Created by alanoud on 01/06/1448 AH.
//   duration كلاس فيه انواع بيانات بسطه و من اوبجكت

import Foundation
import SwiftData

@Model
final class LearningGoal {

    var topic: String
    var duration: Duration
    var startDate: Date

    init(
            topic: String,
            duration: Duration,
            startDate: Date = .now
        ) {
        self.topic = topic
        self.duration = duration
        self.startDate = startDate
      
    }
}
