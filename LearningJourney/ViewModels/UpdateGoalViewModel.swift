//
//  UpdateGoalViewModel.swift
//  LearningJourney
//
//  Created by alanoud on 05/06/1448 AH.
//هنا اخذت اوبجكت من كلاس

import Foundation
import SwiftData

struct UpdateGoalViewModel {
    

    func updateGoal(goal: LearningGoal,topic: String,selected: String,context: ModelContext)
    throws {

        let cleanTopic = topic.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanTopic.isEmpty,let duration = Duration(rawValue: selected)
        else {
            return
        }

        goal.topic = cleanTopic
        goal.duration = duration
        goal.startDate = .now

        try context.save()
        
        NotificationManager().cancelReminder()
    }
}
