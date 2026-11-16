//
//  ActivityViewModel.swift
//  LearningJourney
//
//  Created by alanoud on 02/06/1448 AH.
//


import Foundation
import SwiftData

struct ActivityViewModel {

    private let calendar = Calendar.current

    // MARK: - Current Goal

    func currentGoal(from goals: [LearningGoal]) -> LearningGoal? {
        goals.first
    }

    // MARK: - Current Goal Records

    func currentRecords(
        for goal: LearningGoal,
        records: [DailyRecord]
    ) -> [DailyRecord] {

        records.filter {
            $0.date >= goal.startDate
        }
    }

    // MARK: - Today

    func isLogged(
        records: [DailyRecord],
        now: Date = .now
    ) -> Bool {
        records.contains {
            calendar.isDate($0.date, inSameDayAs: now)
        }
    }

    // MARK: - Freeze

    func usedFreezes(
        for goal: LearningGoal,
        records: [DailyRecord]
    ) -> Int {

        currentRecords(for: goal, records: records)
            .filter { $0.status == .frozen }
            .count
    }
    
    
    
    func isFreezeDisabled(
        goal: LearningGoal?,
        records: [DailyRecord]
    ) -> Bool {

        guard let goal else { return true }

        let goalRecords = currentRecords(
            for: goal,
            records: records
        )

        // إذا اليوم مسجل Learned أو Frozen
        if isLogged(records: goalRecords) {
            return true
        }

        // إذا انتهى رصيد Freeze
        return usedFreezes(
            for: goal,
            records: records
        ) >= goal.duration.freezeLimit
    }
    

    // MARK: - Log as Learned

    func log(
        goal: LearningGoal?,
        records: [DailyRecord],
        context: ModelContext
    ) {
        guard let goal else { return }

        let goalRecords = currentRecords(
            for: goal,
            records: records
        )

        let todayRecord = goalRecords
            .filter { calendar.isDateInToday($0.date) }
            .max { $0.date < $1.date }

        // منع تسجيل Learned مرتين
        if todayRecord?.status == .completed {
            return
        }

        if let todayRecord {
            // تحويل Frozen إلى Learned
            todayRecord.status = .completed
            todayRecord.date = .now
        } else {
            // تسجيل اليوم لأول مرة
            context.insert(
                DailyRecord(date: .now, status: .completed)
            )
        }

        do {
            try context.save()
        } catch {
            print("Log failed: \(error)")
        }
    }
    
    
    
    
    
    // MARK: - Streak (32 Hours)

    func streak(
        for goal: LearningGoal,
        records: [DailyRecord],
        now: Date = .now
    ) -> Int {

        let goalRecords = currentRecords(
            for: goal,
            records: records
        )
        .sorted { $0.date > $1.date }

        guard let latest = goalRecords.first else {
            return 0
        }

        let limit: TimeInterval = 32 * 60 * 60

        // إذا تجاوز آخر تسجيل 32 ساعة ينقطع الستريك
        guard now.timeIntervalSince(latest.date) <= limit else {
            return 0
        }

        var count = goalRecords[0].status == .completed ? 1 : 0

        for index in 1..<goalRecords.count {

            let newer = goalRecords[index - 1]
            let older = goalRecords[index]

            let gap = newer.date.timeIntervalSince(older.date)

            if gap > limit {
                break
            }

            if older.status == .completed {
                count += 1
            }
        }

        return count
    }

    // MARK: - Weekly Calendar

    func weekDates(for goal: LearningGoal?) -> [Date] {

        guard let goal else { return [] }

        let start = calendar.startOfDay(for: goal.startDate)
        let today = calendar.startOfDay(for: .now)

        let daysPassed = calendar.dateComponents(
            [.day],
            from: start,
            to: today
        ).day ?? 0

        let offset = max(0, daysPassed / 7) * 7

        return (0..<7).compactMap {
            calendar.date(
                byAdding: .day,
                value: offset + $0,
                to: start
            )
        }
    }


    // MARK: - Latest Day Status

    func status(on date: Date, records: [DailyRecord]) -> DayStatus? {

        records
            .filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }
            .max { $0.date < $1.date }?
            .status
    }
    
    
    
    
    // MARK: - Goal State

    func goalState(
        for goal: LearningGoal?,
        records: [DailyRecord],
        now: Date = .now
    ) -> GoalState {

        guard let goal else { return .active }

        let start = calendar.startOfDay(for: goal.startDate)

        let end: Date?

        switch goal.duration {
        case .week:
            end = calendar.date(byAdding: .day, value: 7, to: start)
        case .month:
            end = calendar.date(byAdding: .month, value: 1, to: start)
        case .year:
            end = calendar.date(byAdding: .year, value: 1, to: start)
        }

        guard let end else { return .active }

        // المدة لم تنتهِ بعد
        guard now >= end else {
            return .active
        }

        let goalRecords = currentRecords(
            for: goal,
            records: records
        )
        .filter { $0.date < end }
        .sorted { $0.date < $1.date }

        // هل تم تسجيل كل يوم في مدة الهدف؟
        var day = start

        while day < end {

            let isRecorded = goalRecords.contains {
                calendar.isDate($0.date, inSameDayAs: day)
            }

            if !isRecorded {
                return .notCompleted
            }

            guard let next = calendar.date(
                byAdding: .day,
                value: 1,
                to: day
            ) else {
                return .notCompleted
            }

            day = next
        }

        // التأكد من عدم تجاوز 32 ساعة بين التسجيلات
        let limit: TimeInterval = 32 * 60 * 60

        for index in 1..<goalRecords.count {

            let gap = goalRecords[index].date
                .timeIntervalSince(goalRecords[index - 1].date)

            if gap > limit {
                return .notCompleted
            }
        }

        return .completed
    }
    
    
    
    

    // MARK: - Freeze

    func toggleFreeze(
        goal: LearningGoal?,
        records: [DailyRecord],
        context: ModelContext
    ) {
        guard let goal else { return }

        let goalRecords = currentRecords(
            for: goal,
            records: records
        )

        // منع التكرار وانتهاء رصيد Freeze
        guard !isLogged(records: goalRecords),
              usedFreezes(for: goal, records: records) < goal.duration.freezeLimit
        else {
            return
        }

        context.insert(
            DailyRecord(date: .now, status: .frozen)
        )

        do {
            try context.save()
        } catch {
            print("Freeze failed: \(error)")
        }
    }
}

        

            
    



