

import SwiftUI
import SwiftData

struct CalendarView: View {
    
    
    @Query private var records: [DailyRecord]

    // MARK: - ViewModel

    private let viewModel = CalendarViewModel()

    // MARK: - UI Colors
 

    private let orange = Color("Orange2")

    private let cyan = Color("Cyan7")
    
    

    // MARK: - Layout

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 0),
        count: 7
    )

    private let weekdays = [
        "SUN", "MON", "TUE", "WED",
        "THU", "FRI", "SAT"
    ]

    // MARK: - Body

    var body: some View {

        ScrollViewReader { proxy in

            ScrollView {

                LazyVStack(alignment: .leading, spacing: 0) {

                    ForEach(viewModel.months, id: \.self) { month in
                        monthView(month)
                            .id(month)
                    }
                }
                .padding(.horizontal, 12)
            }
            .scrollIndicators(.hidden)
            .scrollEdgeEffectHidden(true, for: .top)//هنا لإخفاء تأثير حافة التمرير
             
            .onAppear {

                if let currentMonth = viewModel.currentMonth {

                    proxy.scrollTo(
                        currentMonth,
                        anchor: .top
                    )
                }
            }
        }
        .foregroundStyle(.primary)
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

            LazyVGrid(columns: columns, spacing: 10) {

                ForEach(weekdays, id: \.self) { day in

                    Text(day)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                ForEach(
                    Array(viewModel.days(in: month).enumerated()),
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

            let day = viewModel.calendar.component(
                .day,
                from: date
            )

            let status = records
                .filter {
                    viewModel.calendar.isDate(
                        $0.date,
                        inSameDayAs: date
                    )
                }
                .max { $0.date < $1.date }?
                .status

            // هل هذا اليوم الحالي؟
            let isToday = viewModel.calendar.isDateInToday(date)

            // اليوم الحالي ولم يُسجل فيه نشاط
            let isTodayUnlogged = isToday && status == nil

            // تحديد اللون
            let color: Color =
                status == .completed ? orange :
                status == .frozen ? cyan : .primary

            let isMarked = status != nil

            Text("\(day)")
                .font(.title3)
                .foregroundStyle(
                    isTodayUnlogged ? Color.white : color
                )
                .frame(width: 38, height: 38)
                .background {
                    Circle()
                        .fill(
                            isTodayUnlogged
                            ? orange
                            : isMarked
                                ? color.opacity(0.12)
                                : .clear
                        )
                }

        } else {

            Color.clear
                .frame(height: 38)
        }
    }
}

#Preview {
    NavigationStack {
        CalendarView()
    }
    .modelContainer(
        for: [LearningGoal.self, DailyRecord.self],
        inMemory: true
    )
}
