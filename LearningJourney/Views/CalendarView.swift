import SwiftUI

struct CalendarView: View {

    // MARK: - UI Colors

    private let orange = Color("Orange2")

    private let cyan = Color(
        red: 48 / 255,
        green: 213 / 255,
        blue: 245 / 255
    )

    // MARK: - Layout

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 0),
        count: 7
    )

    private let weekdays = [
        "SUN", "MON", "TUE", "WED",
        "THU", "FRI", "SAT"
    ]

    // MARK: - Preview Data

    private let calendar = Calendar(identifier: .gregorian)

    private let today = Date.now

    // MARK: - Months

    private var months: [Date] {

        let year = calendar.component(.year, from: today)

        return (1...12).compactMap { month in
            calendar.date(
                from: DateComponents(
                    year: year,
                    month: month
                )
            )
        }
    }

    // MARK: - Body

    var body: some View {

        ScrollViewReader { proxy in

            ScrollView {

                LazyVStack(
                    alignment: .leading,
                    spacing: 0
                ) {

                    ForEach(months, id: \.self) { month in

                        monthView(month)
                            .id(month)
                    }
                }
                .padding(.horizontal, 12)
            }
            .scrollIndicators(.hidden)
            .onAppear {

                if let currentMonth = months.first(where: {
                    calendar.isDate(
                        $0,
                        equalTo: today,
                        toGranularity: .month
                    )
                }) {

                    proxy.scrollTo(
                        currentMonth,
                        anchor: .top
                    )
                }
            }
        }
        .background(.black)
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
        .navigationTitle("Activities")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Month UI

    private func monthView(_ month: Date) -> some View {

        VStack(alignment: .leading, spacing: 12) {

            Text(
                month.formatted(
                    .dateTime.month(.wide).year()
                )
            )
            .font(.headline)
            .padding(.horizontal, 8)

            LazyVGrid(
                columns: columns,
                spacing: 10
            ) {

                // Weekdays

                ForEach(weekdays, id: \.self) { day in

                    Text(day)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                // Calendar Days

                ForEach(
                    Array(days(in: month).enumerated()),
                    id: \.offset
                ) { _, date in

                    dayCell(date)
                }
            }

            Rectangle()
                .fill(.white.opacity(0.2))
                .frame(height: 0.5)
                .padding(.top, 6)
        }
        .padding(.top, 16)
    }

    // MARK: - Day UI

    @ViewBuilder
    private func dayCell(_ date: Date?) -> some View {

        if let date {

            let day = calendar.component(.day, from: date)

            // Temporary colors for UI preview
            let isLearned = [2, 5, 9, 14, 20].contains(day)
            let isFrozen = [7, 17].contains(day)

            let color = isFrozen ? cyan : orange
            let isMarked = isLearned || isFrozen

            Text("\(day)")
                .font(.title3)
                .foregroundStyle(
                    isMarked ? color : .white
                )
                .frame(width: 38, height: 38)
                .background {
                    Circle()
                        .fill(
                            isMarked
                            ? color.opacity(0.12)
                            : .clear
                        )
                }

        } else {

            Color.clear
                .frame(height: 38)
        }
    }

    // MARK: - Calendar Layout

    private func days(in month: Date) -> [Date?] {

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
}

#Preview {

 
        CalendarView()
  
}
