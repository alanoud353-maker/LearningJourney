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
    private let streakLimit: TimeInterval = 32 * 60 * 60
    
    
    
    
    
    
    private func hasReachedStreakLimit(since date: Date,at now: Date) -> Bool {
        now.timeIntervalSince(date) >= streakLimit
    }
    
    // MARK: - Current Goal

    func currentGoal(from goals: [LearningGoal]) -> LearningGoal? {
        goals.first
    }

    // MARK: - Current Goal Records

    func currentRecords(for goal: LearningGoal,records: [DailyRecord]) -> [DailyRecord] {

        records.filter {
            $0.date >= goal.startDate
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
        records: [DailyRecord],
        now: Date = .now) -> Bool {

        guard let goal else { return true }

        let goalRecords = currentRecords(
            for: goal,
            records: records
        )

        let todayStatus = status(
            on: now,
            records: goalRecords
        )

        // إذا اليوم Frozen نعطل زر Freeze
        if todayStatus == .frozen {
            return true
        }

        // إذا اليوم Learned أو غير مسجل، نتحقق من الرصيد
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

        if todayRecord?.status == .completed {
            return
        }

        if let todayRecord {
            // Frozen → Learned
            todayRecord.status = .completed
            todayRecord.date = .now
        } else {
            context.insert(
                DailyRecord(date: .now, status: .completed)
            )
        }

        do {
            try context.save()
            scheduleStreakReminder(goal: goal, context: context)
        } catch {
            print("Log failed: \(error)")
        }
    }
    
    
    
    
    
    // MARK: - Learned Days
    func streak(
        for goal: LearningGoal,
        records: [DailyRecord],
        now: Date = .now
    ) -> Int {

        let goalRecords = currentRecords(
            for: goal,
            records: records
        )
        .filter { $0.date <= now }
        .sorted { $0.date > $1.date }

        guard let latest = goalRecords.first else {
            return 0
        }

        // تصفير الستريك عند وصول 32 ساعة
        guard !hasReachedStreakLimit(
            since: latest.date,
            at: now
        ) else {
            return 0
        }

        var count = 0
        var previousDate = now
        var countedDays = Set<Date>()

        for record in goalRecords {

            // التوقف إذا انقطع تسلسل التسجيلات
            if hasReachedStreakLimit(
                since: record.date,
                at: previousDate
            ) {
                break
            }

            let day = calendar.startOfDay(for: record.date)

            // نحسب Learned مرة واحدة لكل يوم
            if record.status == .completed &&
               !countedDays.contains(day) {
                count += 1
            }

            countedDays.insert(day)
            previousDate = record.date
        }

        return count
    }
    
    
    // MARK: - Weekly Calendar

    func weekDates(for goal: LearningGoal?, now: Date = .now) -> [Date] {

        guard let goal else { return [] }

        let start = calendar.startOfDay(for: goal.startDate)
        let today = calendar.startOfDay(for: now)

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

        // تصفير الستريك لا ينهي الهدف؛ النتيجة تظهر عند نهاية المدة فقط.
        guard now >= end else {
            return .active
        }

        let goalRecords = currentRecords(for: goal, records: records)
            .filter { $0.date < end }

        // انتهت المدة: نتحقق من تسجيل جميع الأيام
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
        
        let todayRecord = goalRecords
            .filter { calendar.isDateInToday($0.date) }
            .max { $0.date < $1.date }
        
        // إذا اليوم Frozen، ما نكرر العملية
        if todayRecord?.status == .frozen {
            return
        }
        
        // التحقق من توفر رصيد Freeze
        guard usedFreezes(
            for: goal,
            records: records
        ) < goal.duration.freezeLimit else {
            return
        }
        
        if let todayRecord {
            // Learned → Frozen
            todayRecord.status = .frozen
            todayRecord.date = .now
        } else {
            context.insert(
                DailyRecord(date: .now, status: .frozen)
            )
        }
        
        do {
            try context.save()
            scheduleStreakReminder(goal: goal, context: context)
        } catch {
            print("Freeze failed: \(error)")
        }
    }
    
    
    private func scheduleStreakReminder(
        goal: LearningGoal,
        context: ModelContext
    ) {
        do {
            // نقرأ التسجيلات بعد الحفظ حتى يشمل التسجيل الجديد.
            let records = try context.fetch(FetchDescriptor<DailyRecord>())
            let now = Date.now

            let latest = currentRecords(for: goal, records: records)
                .filter { $0.date <= now }
                .max { $0.date < $1.date }

            guard let latest else { return }

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

            guard let end else { return }

            let activityDate = latest.date
            let count = streak(for: goal, records: records, now: now)

            Task {
                do {
                    try await NotificationManager().scheduleReminder(
                        lastActivityDate: activityDate,
                        goalEndDate: end,
                        streakCount: count
                    )
                } catch {
                    print("Scheduling reminder failed: \(error)")
                }
            }
        } catch {
            print("Reading activities failed: \(error)")
        }
    }
}

        

            
    




