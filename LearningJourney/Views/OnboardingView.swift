//
//  OnboardingView.swift
//  LearningJourney
//
//  Created by alanoud on 30/05/1448 AH.
//
import SwiftUI
import SwiftData

struct OnboardingView: View {
    
    
    @Environment(\.modelContext) private var modelContext

    private let viewModel = OnboardingViewModel()
    @State private var topic = ""
    @State private var selected = "Week"

    let durations = ["Week", "Month", "Year"]
    private let orange = Color("Orange2")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // الشعار
            Image(systemName: "flame.fill")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.orange)
                .frame(maxWidth: .infinity)
                .padding(.top, 57)

            // الترحيب
            VStack(alignment: .leading, spacing: 4) {
                (Text("Hello ") + Text("Learner").bold())
                    .font(.largeTitle)

                Text("This app will help you learn everyday!")
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 80)
            .padding(.horizontal, 17)

            // MARK: - Shared Goal Form

            GoalForm(
                topic: $topic,
                selected: $selected
            )
            .padding(.top, 37)

            Spacer()

            // الزر السفلي
            VStack(spacing: 12) {
                Button {
                    do {
                           try viewModel.createGoal(
                               topic: topic,
                               selected: selected,
                               context: modelContext
                           )
                       } catch {
                           print("Failed to save goal: \(error)")
                       }
                } label: {
                    Text("Start Learning")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white)
                        .frame(width: 151, height: 46)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.tint(orange).interactive(), in: .capsule)

                Text("You can edit your desire later")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 54)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
    }
}


#Preview {
    OnboardingView()
}
