//
//  Set a goal.swift
//  LearningJourney
//
//  Created by alanoud on 01/06/1448 AH.
//




import SwiftUI

enum GoalState {
    case active
    case completed
    case notCompleted
}



struct Setgoal: View {
    
    
    @State private var showUpdateGoal = false
    @State  var state: GoalState = .completed

    private let orange = Color("Orange2")

    var body: some View {

        VStack(spacing: 16) {

            if state == .completed {

                Image(systemName: "hands.clap.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(orange)

                Text("Well done!")
                    .font(.headline)

                Text("Ready for your next goal?")
                    .foregroundStyle(.secondary)

            } else if state == .notCompleted {

                Image(systemName: "xmark.seal")
                    .font(.system(size: 48))
                    .foregroundStyle(orange)

                Text("You didn't reach your goal this time.")
                    .font(.headline)

                Text("Want to set another goal?")
                    .foregroundStyle(.secondary)
            }

            if state != .active {

                    NavigationLink{
                        UpdateGoalView()
                        
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil.and.outline") // يمكنك تغيير اسم الأيقونة هنا
                        Text("Set a Gola")
                    }
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 140, height: 50) // زدت العرض قليلاً ليتسع للأيقونة والنص
                }
                .buttonStyle(.plain)
                .glassEffect(
                    .regular.tint(orange).interactive(),
                    in: .capsule
                )
                .padding(.top, 48)
            }

        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

#Preview("Completed") {
    NavigationStack{
        Setgoal(state: .completed)
    }
        
}

#Preview("Not Completed") {
    
    NavigationStack{
        Setgoal(state: .notCompleted)
        
    }
       
}
