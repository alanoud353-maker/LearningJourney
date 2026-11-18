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

    var onUpdate: () -> Void = {}

    var body: some View {

        ZStack {

            Color.black.opacity(0.6)

            VStack(alignment: .leading, spacing: 16) {

                // MARK: - Title
                Text("Update goal")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)

                // MARK: - Message
                Text("If you update now, your streak will start over.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.gray)
                    .fixedSize(horizontal: false, vertical: true)

                // MARK: - Buttons
                GlassEffectContainer(spacing: 8) {

                    HStack(spacing: 8) {

                        // Dismiss Button
                        Button {
                            showAlert = false
                        } label: {
                            Text("Dismiss")
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .background(Color(red: 51/255, green: 51/255, blue: 53/255), in: Capsule())
                        

                        // Update Button
                        Button {
                            showAlert = false
                            onUpdate()
                        } label: {
                            Text("Update")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .glassEffect(
                            .regular.tint(orange).interactive(),
                            in: .capsule
                        )
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 3)
                
            }
            .padding(20)
            .frame(width: 320)
            .glassEffect(
                .regular.tint(.black.opacity(0.2)),
                in: .rect(cornerRadius: 34))
        }
    }
}

#Preview {
    @Previewable @State var showAlert = true

    CustomAlert(showAlert: $showAlert)
        .preferredColorScheme(.dark)
}
