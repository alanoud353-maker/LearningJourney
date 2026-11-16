//
//  UpdateGoal.swift
//  LearningJourney
//
//  Created by alanoud on 01/06/1448 AH.
//


import SwiftUI
import SwiftData

struct UpdateGoalView: View {
    
    @Query(sort: \LearningGoal.startDate, order: .reverse)
    private var goals: [LearningGoal]

    @Environment(\.modelContext) private var context

    @Environment(\.dismiss) private var dismiss
    
    private let viewModel = UpdateGoalViewModel()
    @State private var topic = "Swift"
    @State private var selected = "Week"
    @State private var showAlert = false

    private let orange = Color("Orange2")

    var body: some View {

        ZStack {

            VStack(alignment: .leading, spacing: 0) {
                

                // MARK: - Shared Goal Form

                GoalForm(
                    topic: $topic,
                    selected: $selected
                )
                .padding(.top, 58)

                Spacer()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )


            // MARK: - Navigation Bar

            .navigationTitle("Learning Goal")
            .navigationBarTitleDisplayMode(.inline)

            // MARK: - Save Button

            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {

                    Button {
                        showAlert = true
                    } label: {

                        Image(systemName: "checkmark")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                    }
                    .disabled(topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.plain)
                    .glassEffect(
                        .regular.tint(orange).interactive(),
                        in: .circle
                    )
                }
                .sharedBackgroundVisibility(.hidden)

            }

            // MARK: - Custom Alert

            .overlay {

                if showAlert {
                    CustomAlert(showAlert: $showAlert) {

                        guard let goal = goals.first else { return }

                        do {
                            try viewModel.updateGoal(
                                goal: goal,
                                topic: topic,
                                selected: selected,
                                context: context
                            )

                            print("Updated Topic:", goal.topic)
                            print("Updated Duration:", goal.duration.rawValue)
                            print("Updated Start Date:", goal.startDate)

                            showAlert = false
                            dismiss()

                        } catch {
                            print("Update failed:", error)
                        }
                    }
                }
            }
        }.onAppear {
            if let goal = goals.first {
                topic = goal.topic
                selected = goal.duration.rawValue
            }
        }
    }
}

#Preview {
    NavigationStack {
        UpdateGoalView()
    }
}
