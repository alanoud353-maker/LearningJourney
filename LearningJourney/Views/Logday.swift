//
//  Logday.swift 
//  LearningJourney
//
//  Created by alanoud on 01/06/1448 AH.
//VStack رئيسية للصفحة كاملة.
//HStack تجمع العنوان والأزرار جنب بعض.
//VStack داخلها تعرض Activity والتاريخ تحت بعض.
// HStack ثانية تجمع الزرين، مع استخدام .buttonStyle(.glass) لمظهر iOS القياسي.



import SwiftUI
import SwiftData

struct Logday: View {

    // MARK: - Data

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LearningGoal.startDate, order: .reverse) private var goals: [LearningGoal]
    @Query private var records: [DailyRecord]
    

    private let viewModel = ActivityViewModel()

    // MARK: - Computed Values

    private var goal: LearningGoal? {
        viewModel.currentGoal(from: goals)
    }

    private var goalRecords: [DailyRecord] {
        guard let goal else { return [] }
        return viewModel.currentRecords(for: goal, records: records)
    }

    private var streakCount: Int {
        guard let goal else { return 0 }
        return viewModel.streak(for: goal, records: records)
    }

    private var freezesUsed: Int {
        guard let goal else { return 0 }
        return viewModel.usedFreezes(for: goal, records: records)
    }

    private var maxFreezes: Int {
        viewModel.maxFreezes(for: goal)
    }

    private var isLogged: Bool {
        viewModel.isLogged(records: goalRecords)
    }

    private var isFreezeDisabled: Bool {
        viewModel.isFreezeDisabled(goal: goal, records: goalRecords)
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            weekCalendar
            statCards
            actionButtons
        }
    }


    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Activity")
                    .font(.largeTitle.bold())
                    .padding(.leading, 16)

                Text(Date.now, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 15)
            }

            Spacer()

            GlassEffectContainer(spacing: 12) {
                HStack(spacing: 12) {
                    NavigationLink { CalendarView() } label: {
                        Label("Calendar", systemImage: "calendar")
                    }
                    NavigationLink { UpdateGoalView() } label: {
                        Label("Goal", systemImage: "pencil.and.outline")
                    }
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .controlSize(.large)
            }
            .padding(.trailing, 16)
        }
    }


    
    // MARK: - Weekly Calendar (عرض فقط)

    
    // MARK: - Weekly Calendar

   private var weekCalendar: some View {

       HStack(spacing: 10) {

           ForEach(viewModel.weekDates(for: goal), id: \.self) { date in

               let status = viewModel.status(
                   on: date,
                   records: goalRecords
               )

               let isToday = Calendar.current.isDateInToday(date)

               let isTodayUnlogged = isToday && status == nil

               let color = viewModel.dayColor(status)

               VStack(spacing: 4) {

                   Text(date, format: .dateTime.weekday(.narrow))
                       .font(.caption.weight(.semibold))
                       .frame(width: 28)

                   Text(date, format: .dateTime.day())
                       .font(.body)
                       .foregroundStyle(
                           isTodayUnlogged ? .white : color
                       )
                       .frame(width: 40, height: 40)
                       .background {

                           Circle()
                               .fill(
                                   isTodayUnlogged
                                   ? Color("Orange2")
                                   : status != nil
                                       ? color.opacity(0.15)
                                       : .clear
                               )
                       }
               }
           }
       }
       .frame(maxWidth: .infinity)
       .padding(.top, 30)
       .padding(.trailing, 14)
   }




    // MARK: - Stat Cards

    private var statCards: some View {
        GlassEffectContainer {
            HStack(spacing: 12) {
                statCard(icon: "flame.fill", color: .orange,
                         value: streakCount, title: "Learned")
                statCard(icon: "snowflake", color: .cyan,
                         value: freezesUsed, title: "Freezed")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .padding(.trailing, 14)
    }

    // كرت واحد يُستخدم للاثنين
    private func statCard(icon: String, color: Color, value: Int, title: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title2)

            Text("\(value) days")
                .font(.headline)

            Text(title)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .glassEffect(.regular.tint(.black.opacity(0.4)), in: .rect(cornerRadius: 34))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 48) {
            logButton
            freezeSection
            Spacer()
        }
        .padding(.top, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var logButton: some View {
        //زر التعلّم
        Button {
            viewModel.log(.completed, goal: goal, records: records, context: modelContext)
        } label: {
            Text(isLogged ? "Logged as Learned" : "Log as Learned")
                .font(.headline)
                .foregroundStyle(isLogged ? .gray : .white)
                .frame(width: 272, height: 272)
                .background {
                    Circle().fill(
                        isLogged
                        ? Color(uiColor: .secondarySystemBackground)
                        : Color("Orange2")
                    )
                }
                .overlay {
                    if !isLogged {
                        Circle().strokeBorder(Color.orange.opacity(0.7), lineWidth: 1.5)
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(isLogged || goal == nil)
    }

    private var freezeSection: some View {
        VStack(spacing: 16) {
            // زر التجميد
            Button {
                viewModel.log(.frozen, goal: goal, records: records, context: modelContext)
            } label: {
                Text("Freeze for a day")
                    .font(.body.weight(.medium))
                    .foregroundStyle(isFreezeDisabled ? .gray : .white)
                    .frame(width: 272, height: 46)
            }
            .buttonStyle(.plain)
            .glassEffect(
                isFreezeDisabled ? .regular : .regular.tint(.cyan).interactive(),
                in: .capsule
            )
            .disabled(isFreezeDisabled)

            Text("\(freezesUsed) out of \(maxFreezes) Freezes used")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
 
        Logday()
 
        
}
