//
//  OnboardingView.swift
//  LearningJourney
//
//  Created by alanoud on 30/05/1448 AH.
//
import SwiftUI

struct OnboardingView: View {

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

            // حقل الهدف
            VStack(alignment: .leading, spacing: 19) {
                Text("I want to learn")

                TextField(
                    "",
                    text: $topic,
                    prompt: Text("Swift").foregroundStyle(Color(uiColor: .tertiaryLabel))
                )

                Rectangle()
                    .fill(Color(uiColor: .separator))
                    .frame(height: 0.5)
            }
            .padding(.top, 37)
            .padding(.horizontal, 17)

            // اختيار المدة
            VStack(alignment: .leading, spacing: 13) {
                Text("I want to learn it in a")
                    .padding(.horizontal, 17)

                GlassEffectContainer(spacing: 12) {
                    HStack(spacing: 12) {
                        ForEach(durations, id: \.self) { duration in
                            let isSelected = duration == selected

                            Button {
                                withAnimation(.smooth) { selected = duration }
                            } label: {
                                Text(duration)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(isSelected ? .white : Color(uiColor: .tertiaryLabel))
                                    .padding(.horizontal, 24)
                                    .frame(height: 46)
                            }
                            .buttonStyle(.plain)
                            .glassEffect(
                                isSelected ? .regular.tint(orange).interactive() : .regular.interactive(),
                                in: .capsule
                            )
                        }
                    }
                    .padding(.horizontal, 18)
                }
            }
            .padding(.top, 30)

            Spacer()

            // الزر السفلي
            VStack(spacing: 12) {
                Button {
                    // Logic later
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
