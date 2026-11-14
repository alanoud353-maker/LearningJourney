//
//  ActivityViewModel.swift
//  LearningJourney
//
//  Created by alanoud on 02/06/1448 AH.
//

import Foundation
import SwiftData
import SwiftUI


struct ActivityViewModel {

    private let calendar = Calendar.current

    // الهدف الحالي = أول هدف نشط
    func currentGoal(from goals: [LearningGoal]) -> LearningGoal? {
        goals.first { $0.isActive }
    }

    // سجلات هذا الهدف فقط
    func currentRecords(for goal: LearningGoal, records: [DailyRecord]) -> [DailyRecord] {
        records.filter { $0.goal == goal }
    }

    // هل سجّلت اليوم؟
    func isLogged(records: [DailyRecord]) -> Bool {
        records.contains { calendar.isDateInToday($0.date) }
    }

    // كم يوم تجميد استخدمت؟
    func usedFreezes(for goal: LearningGoal, records: [DailyRecord]) -> Int {
        currentRecords(for: goal, records: records)
            .filter { $0.status == .frozen }
            .count
    }

    func maxFreezes(for goal: LearningGoal?) -> Int {
        goal?.duration.freezeLimit ?? 0
    }

    // زر التجميد معطّل إذا: ما فيه هدف، أو سجّلت اليوم، أو خلصت التجميدات
    func isFreezeDisabled(goal: LearningGoal?, records: [DailyRecord]) -> Bool {
        guard let goal, goal.isActive else { return true }
        return isLogged(records: records)
            || usedFreezes(for: goal, records: records) >= maxFreezes(for: goal)
    }

    // تسجيل اليوم
    func recordToday(status: DayStatus, goal: LearningGoal,
                     records: [DailyRecord], context: ModelContext) throws {

        let goalRecords = currentRecords(for: goal, records: records)

        guard goal.isActive,
              !isLogged(records: goalRecords) else { return }

        if status == .frozen,
           usedFreezes(for: goal, records: records) >= maxFreezes(for: goal) {
            return
        }

        context.insert(DailyRecord(date: .now, status: status, goal: goal))
        try context.save()
    }

    // السلسلة المتتالية
    func streak(for goal: LearningGoal, records: [DailyRecord]) -> Int {
        let days = Set(currentRecords(for: goal, records: records).map(\.date))

        var day = calendar.startOfDay(for: .now)

        // إذا ما سجّلت اليوم، نبدأ العدّ من أمس
        if !days.contains(day) {
            day = calendar.date(byAdding: .day, value: -1, to: day) ?? day
        }

        var count = 0
        while days.contains(day) {
            count += 1
            day = calendar.date(byAdding: .day, value: -1, to: day) ?? .distantPast
        }
        return count
    }

    // أيام الأسبوع السبعة
    // MARK: - Weekly Calendar

    // 7 أيام تبدأ من أول يوم في الهدف
    func weekDates(for goal: LearningGoal?) -> [Date] {
        guard let goal else { return [] }

        let start = calendar.startOfDay(for: goal.startDate)
        let today = calendar.startOfDay(for: .now)

        // كم يوم مرّ من بداية الهدف؟ ومنه نعرف أي أسبوع نحن فيه
        let daysPassed = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        let offset = max(0, daysPassed / 7) * 7

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: offset + $0, to: start)
        }
    }

    // حالة اليوم (تعلّم / تجميد / ما فيه سجل)
    func status(on date: Date, records: [DailyRecord]) -> DayStatus? {
        records.first { calendar.isDate($0.date, inSameDayAs: date) }?.status
    }

    
    
    
    
    // MARK: - Log (تعلّمت / تجميد)

    func log(
        _ status: DayStatus,
        goal: LearningGoal?,
        records: [DailyRecord],
        context: ModelContext
    ) {
        guard let goal, goal.isActive else { return }

        let goalRecords = currentRecords(for: goal, records: records)

        // منع تسجيل اليوم مرتين
        guard !isLogged(records: goalRecords) else { return }

        // التأكد من وجود تجميدات متبقية
        if status == .frozen,
           usedFreezes(for: goal, records: records) >= maxFreezes(for: goal) {
            return
        }

        context.insert(DailyRecord(date: .now, status: status, goal: goal))

        do {
            try context.save()
        } catch {
            print("Log failed: \(error)")
        }
    }
    
    
    
     func dayColor(_ status: DayStatus?) -> Color {
        switch status {
        case .completed: .orange
        case .frozen: .cyan
        case nil: .white
        }
    }
}
