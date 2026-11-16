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
    
    @Query(sort: \LearningGoal.startDate, order: .reverse)
    private var goals: [LearningGoal]
    
    @Query private var records: [DailyRecord]
    
    private let viewModel = ActivityViewModel()
    
    // MARK: - UI Colors
    
    private let orange = Color("Orange2")
    private let cyan = Color("Cyan7")
    
    // MARK: - Computed Values
    
    private var goal: LearningGoal? {
        viewModel.currentGoal(from: goals)
    }
    
    private var goalRecords: [DailyRecord] {
        guard let goal else { return [] }
        return viewModel.currentRecords(for: goal, records: records)
    }
    
    private var todayStatus: DayStatus? {
        viewModel.status(on: .now, records: goalRecords)
    }
    
    private var streakCount: Int {
        guard let goal else { return 0 }
        return viewModel.streak(for: goal, records: records)
    }
    
    private var freezesUsed: Int {
        guard let goal else { return 0 }
        return viewModel.usedFreezes(for: goal, records: records)
    }
    
    
    private var isLogged: Bool {
        todayStatus == .completed
    }
    
    private var isFreezeDisabled: Bool {
        viewModel.isFreezeDisabled(
            goal: goal,
            records: goalRecords
        )
    }
    

    
    private var currentGoalState: GoalState {
        viewModel.goalState(
            for: goal,
            records: records
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            // MARK: - Header
            
            HStack(alignment: .top, spacing: 12) {
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text("Activity")
                        .font(.largeTitle.bold())
                        .padding(.leading, 16)
                    
                    Text(
                        Date.now,
                        format: .dateTime.weekday(.wide).day().month(.wide)
                    )
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 15)
                }
                
                Spacer()
                
                GlassEffectContainer(spacing: 12) {
                    
                    HStack(spacing: 12) {
                        
                        NavigationLink {
                            CalendarView()
                        } label: {
                            Label("Calendar", systemImage: "calendar")
                        }
                        
                        NavigationLink {
                            UpdateGoalView()
                        } label: {
                            Label("Goal", systemImage: "pencil.and.outline")
                        }
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .controlSize(.large)
                    .font(.system(size: 22, weight:.regular))
                    
                }
                .padding(.trailing, 16)
                
                
            }
            
            // MARK: - Weekly Calendar
            
            HStack(spacing: 14) {
                
                ForEach(
                    viewModel.weekDates(for: goal),
                    id: \.self
                ) { date in
                    
                    let status = viewModel.status(
                        on: date,
                        records: goalRecords
                    )
                    
                    let isToday = Calendar.current.isDateInToday(date)
                    
                    let isTodayUnlogged = isToday && status == nil
                    
                    let color: Color =
                    status == .completed ? orange :
                    status == .frozen ? cyan :
                    Color.primary
                    
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
                                        ? orange
                                        : status != nil
                                        ? color.opacity(0.15)
                                        : .clear
                                    )
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 15)
            .padding(.trailing, 14)
            
            // MARK: - Stat Cards
            
            GlassEffectContainer {
                
                HStack(spacing: 14) {
                    
                    ForEach(0..<2, id: \.self) { index in
                        
                        let isLearned = index == 0
                        let value = isLearned ? streakCount : freezesUsed
                        let title = isLearned ? "Learned" : "Freezed"
                        let icon = isLearned ? "flame.fill" : "snowflake"
                        let color = isLearned ? orange : cyan
                        
                        VStack(spacing: 8) {
                            
                            Image(systemName: icon)
                                .foregroundStyle(color)
                                .font(.title2)
                            
                            Text("\(value) \(value == 1 ? "day" : "days")") //هنا اذا فردي او زوجي
                                .font(.headline)
                            
                            Text(title)
                                .font(.footnote)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 102)
                        .glassEffect(
                            .regular.tint(.black.opacity(0.4)),
                            in: .rect(cornerRadius: 34)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.trailing, 14)
            
            // MARK: - Action Buttons
            
            
            if currentGoalState == .active {
                
                VStack(spacing: 48) {
                    
                    // MARK: - Log Button
                    
                    Button {
                        
                        viewModel.log(
                            goal: goal,
                            records: records,
                            context: modelContext
                        )
                        
                    } label: {
                        
                        Text(
                            isLogged
                            ? "Logged as Learned"
                            : "Log as Learned"
                        )
                        .font(.headline)
                        .foregroundStyle(isLogged ? .gray : .white)
                        .frame(width: 272, height: 272)
                        .overlay {
                            if !isLogged {
                                Circle()
                                    .strokeBorder(
                                        orange.opacity(0.7),
                                        lineWidth: 1.5
                                    )
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isLogged || goal == nil)
                    .buttonStyle(.plain)
                    .glassEffect(
                        isLogged
                        ? .regular.tint(.black.opacity(0.4))
                        : .regular.tint(.orange2).interactive(),
                        in: .circle
                    )
                    .disabled(isLogged || goal == nil)
                    
                    
                    
                    
                    
                    // MARK: - Freeze Section
                    
                    VStack(spacing: 16) {
                        
                        Button {
                            
                            viewModel.toggleFreeze(
                                goal: goal,
                                records: records,
                                context: modelContext
                            )
                            
                        } label: {
                            
                            Text(
                                todayStatus == .frozen
                                ? "Freezed for a day"
                                : "Freeze for a day"
                            )
                            .font(.body.weight(.medium))
                            .foregroundStyle(
                                todayStatus == .frozen
                                ? .gray : .white
                            )
                            .frame(width: 272, height: 46)
                        }
                        .buttonStyle(.plain)
                        .glassEffect(
                            todayStatus == .frozen
                            ? .regular.tint(.black.opacity(0.4))
                            : .regular.tint(cyan).interactive(),
                            in: .capsule
                        )
                        .disabled(isFreezeDisabled)
                        
                        Text(
                            "\(freezesUsed) out of \(goal?.duration.freezeLimit ?? 0) Freezes used"
                        )
                        
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
                .padding(.top, 48)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                
                
            }else {
                
                Setgoal(state: currentGoalState)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
            }
        }
    }
}

// MARK: - Preview

#Preview {

    let container = try! ModelContainer(
        for: LearningGoal.self, DailyRecord.self,
        configurations: ModelConfiguration(
            isStoredInMemoryOnly: true
        )
    )

    let goal = LearningGoal(
        topic: "SwiftUI",
        duration: .week
    )

    container.mainContext.insert(goal)

    return NavigationStack {
        Logday()
    }
    .modelContainer(container)
}
