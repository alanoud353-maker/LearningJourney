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
    private let notificationManager = NotificationManager()
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var currentTime = Date.now
    
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
        viewModel.status(
            on: currentTime,
            records: goalRecords
        )
    }
    
    private var streakCount: Int {
        guard let goal else { return 0 }

        return viewModel.streak(
            for: goal,
            records: records,
            now: currentTime
        )
    }
    
    private var freezesUsed: Int {
        guard let goal else { return 0 }
        return viewModel.usedFreezes(for: goal, records: records)
    }
    
    
    private var isLogged: Bool {
        todayStatus == .completed
    }
    
    private var isFreezeDisabled: Bool {viewModel.isFreezeDisabled(goal: goal,records: goalRecords,now: currentTime
        )
    }
    

    private var currentGoalState: GoalState {
        viewModel.goalState(
            for: goal,
            records: records,
            now: currentTime
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
                        currentTime,
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
                            Image(systemName: "calendar")
                                .font(.system(size: 20))
                                .foregroundStyle(.primary)
                                .frame(width: 44, height: 44)
                                .glassEffect(.regular, in: .circle)
                        }
                        
                        NavigationLink {
                            UpdateGoalView()
                        } label: {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 20))
                                .foregroundStyle(.primary)
                                .frame(width: 44, height: 44)
                                .glassEffect(.regular, in: .circle)
                        }
                    }
                }.tint(.primary)
            }.padding(.trailing, 16)
            
            // MARK: - Weekly Calendar
            
            HStack(spacing: 14) {
                
                ForEach(
                    viewModel.weekDates(for: goal, now: currentTime),
                    id: \.self
                ) { date in
                    
                    let status = viewModel.status(
                        on: date,
                        records: goalRecords
                    )
                    
                    let isToday = Calendar.current.isDate(date, inSameDayAs: currentTime)
                    
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
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(
                                isTodayUnlogged ? .white : color
                            )
                            .frame(width: 44, height: 44)
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
            .padding(.horizontal, 14)
            
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
                            
                            Text("\(value) \(value == 1 ? "day" : "days")") //هنا اذا فردي او جمع
                                .font(.headline)
                            
                            Text(title)
                                .font(.footnote)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 102)
                        .glassEffect(
                            .regular.tint(.black.opacity(0.2)),
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
                        .contentShape(Circle()) //الشكل كامل يستجيب
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
                    .glassEffect(
                        isLogged
                        ? .regular.tint(.black.opacity(0.2))
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
                            .foregroundStyle(isFreezeDisabled ? .gray : .white)
                            .frame(width: 272, height: 46)
                          
                        }
                        .buttonStyle(.plain)
                        .glassEffect(
                            isFreezeDisabled
                            ? .regular.tint(.black.opacity(0.2))
                            : .regular.tint(cyan).interactive(),
                            in: .capsule
                        )
                        .disabled(isFreezeDisabled)
                        
                        Text(
                            "\(freezesUsed) out of \(goal?.duration.freezeLimit ?? 0) Freezes used"
                        )
                        
                        .font(.caption.weight(.regular))
                        .foregroundStyle(Color("Gray"))
                        
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
        .onAppear {
            currentTime = .now
        }.task {
            do {
                _ = try await NotificationManager().requestPermission()
            } catch {
                print("Notification permission failed: \(error)")
            }
        }
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }

            // Keep day status fresh across midnight and when returning to the app.
            while !Task.isCancelled {
                currentTime = .now
                do {
                    try await Task.sleep(for: .seconds(1))
                } catch {
                    return
                }
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
