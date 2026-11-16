//
//  OnboardingViewModel.swift
//  LearningJourney
//
//  Created by alanoud on 02/06/1448 AH.
//

import SwiftUI
import SwiftData

struct OnboardingViewModel {
  
    
    //هذه الداله لانشاءهدف جديد
    //
    
        func createGoal(topic: String,selected: String,context: ModelContext)
            
        throws {
            
            let cleanTopic = topic.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            
            guard !cleanTopic.isEmpty,
                  let duration = Duration(rawValue: selected)
                    else {
                return
            }
            
            let goal = LearningGoal(
                topic: cleanTopic,
                duration: duration
            )
            
            context.insert(goal)
            try context.save()
        }
    }

