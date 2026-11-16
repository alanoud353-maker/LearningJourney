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
    

    init(date: Date = .now, status: DayStatus) {
        self.date = date
        self.status = status
    }
}
