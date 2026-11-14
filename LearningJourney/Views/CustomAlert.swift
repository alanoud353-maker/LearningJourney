//
//  CustomAlert.swift
//  LearningJourney
//
//  Created by alanoud on 02/06/1448 AH.
//
import SwiftUI

struct CustomAlert: View {

    @Binding var showAlert: Bool

    private let orange = Color("Orange2")

    var body: some View {

        ZStack {

            Color.black.opacity(0.6)

            VStack(spacing: 16) {

                Text("Update goal")
                    .font(.headline)

                Text("If you update now, your streak will start over.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {

                    Button("Dismiss") {
                        showAlert = false
                    }
                    .buttonStyle(.glass)

                    Button("Update") {
                        showAlert = false
                        // Update logic later
                    }
                    .buttonStyle(.glassProminent)
                    .tint(orange)
                }
                .controlSize(.large)
            }
            .padding(24)
            .frame(maxWidth: 320)
            .background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: 28)
            )
        }
    }
}

#Preview {
    @Previewable @State var showAlert = true

    CustomAlert(showAlert: $showAlert)
}

