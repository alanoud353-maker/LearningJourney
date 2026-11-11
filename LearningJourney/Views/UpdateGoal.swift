//
//  UpdateGoal.swift
//  LearningJourney
//
//  Created by alanoud on 01/06/1448 AH.
//

import SwiftUI

struct UpdateGoalView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var topic = "Swift"
    @State private var selected = "Week"
    @State private var showAlert = false

    let durations = ["Week", "Month", "Year"]

    private let orange = Color("Orange2")

    var body: some View {

        NavigationStack {

            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Goal
                VStack(alignment: .leading, spacing: 19) {

                    Text("I want to learn")
                        .font(.body)

                    TextField(
                        "",
                        text: $topic,
                        prompt: Text("Swift")
                            .foregroundStyle(Color(uiColor: .tertiaryLabel))
                    )
                    .font(.body)
                    .submitLabel(.done)

                    Rectangle()
                        .fill(Color(uiColor: .separator))
                        .frame(height: 0.5)
                }
                .padding(.top, 58)
                .padding(.horizontal, 17)

                // MARK: - Duration
                VStack(alignment: .leading, spacing: 13) {

                    Text("I want to learn it in a")
                        .font(.body)
                        .padding(.horizontal, 17)

                    GlassEffectContainer(spacing: 12) {

                        HStack(spacing: 12) {

                            ForEach(durations, id: \.self) { duration in

                                let isSelected = duration == selected

                                Button {
                                    withAnimation(.smooth) {
                                        selected = duration
                                    }
                                } label: {

                                    Text(duration)
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(
                                            isSelected
                                            ? .white
                                            : Color(uiColor: .tertiaryLabel)
                                        )
                                        .padding(.horizontal, 24)
                                        .frame(height: 46)
                                }
                                .buttonStyle(.plain)
                                .glassEffect(
                                    isSelected
                                    ? .regular.tint(orange).interactive()
                                    : .regular.interactive(),
                                    in: .capsule
                                )
                            }
                        }
                        .padding(.horizontal, 18)
                    }
                }
                .padding(.top, 30)

                Spacer()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .foregroundStyle(.white)
            .background(.black)

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
                    .buttonStyle(.plain)
                    .glassEffect(
                        .regular.tint(orange).interactive(),
                        in: .circle
                    )
                }
            }

            // MARK: - Update Alert
            .alert("Update goal", isPresented: $showAlert) {

                Button("Dismiss", role: .cancel) {}

                Button("Update") {
                    // Update logic later
                }

            } message: {
                Text("If you update now, your streak will start over.")
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    UpdateGoalView()
}
