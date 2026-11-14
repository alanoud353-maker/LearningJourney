//
//  DailyRecord.swift
//  LearningJourney
//
//  Created by alanoud on 01/06/1448 AH.
//،  LearningGoal هذه بعد ماخده كلاس  بكبره وخله على شكل object
//تكون فيها البيانات بشكل يومي 

import Foundation
import SwiftData

@Model
final class DailyRecord {

    var date: Date
    var status: DayStatus
    var goal: LearningGoal?

    init(
        date: Date,
        status: DayStatus,
        goal: LearningGoal
    ) {
        self.date = Calendar.current.startOfDay(for: date)
        self.status = status
        self.goal = goal
        
    }
}
