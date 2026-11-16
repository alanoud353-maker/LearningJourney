//
//  GoalForm.swift
//  LearningJourney
//
//  Created by alanoud on 05/06/1448 AH.
//


import SwiftUI

struct GoalForm: View {

    @Binding var topic: String
    @Binding var selected: String

    private let durations = ["Week", "Month", "Year"]
    private let orange = Color("Orange2")

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Goal

            VStack(alignment: .leading, spacing: 19) {

                Text("I want to learn")
                    .font(.body)

                TextField(
                    "",
                    text: $topic,
                    prompt: Text("Swift")
                        .foregroundStyle(
                            Color(uiColor: .tertiaryLabel)
                        )
                )
                .font(.body)
                .submitLabel(.done)

                Rectangle()
                    .fill(Color(uiColor: .separator))
                    .frame(height: 0.5)
            }
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
        }
    }
}


#Preview {
    
    @Previewable @State var topic = "reading"
    @Previewable @State var selected = "Week"

    GoalForm(topic: $topic, selected: $selected )
}
