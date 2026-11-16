//
//  CalendarViewModel.swift
//  LearningJourney
//
//  Created by alanoud on 03/06/1448 AH.
// (Computed Properties)

import Foundation

class CalendarViewModel {

    let today = Date.now

    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        return calendar
    }()

    // MARK: - Months

    var months: [Date] {

        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: .now)

        guard let start = calendar.date(
            from: DateComponents(year: currentYear, month: 1, day: 1)
        ) else {
            return []
        }

        // 24 شهر = السنة الحالية + السنة القادمة
        
        return (0..<24).compactMap {
            calendar.date(byAdding: .month, value: $0, to: start)
        }
    }

    // MARK: - Days

    func days(in month: Date) -> [Date?] {

        let count = calendar.range(
            of: .day,
            in: .month,
            for: month
        )?.count ?? 0

        let blanks = calendar.component(
            .weekday,
            from: month
        ) - 1

        let leading = Array<Date?>(
            repeating: nil,
            count: blanks
        )

        let dates = (0..<count).map { day in
            calendar.date(
                byAdding: .day,
                value: day,
                to: month
            )
        }

        return leading + dates
    }

    // MARK: - Current Month

    var currentMonth: Date? {

        months.first {
            calendar.isDate(
                $0,
                equalTo: today,
                toGranularity: .month
            )
        }
    }
}
