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

struct Logday: View {
    @State private var selectedDay = 4
    let letters = ["S", "M", "T", "W", "T", "F", "S"]
    @State private var freezesUsed = 0
    let maxFreezes = 2
    @State private var isLogged = false

    // خاصية تحسب متى يتعطل الزر (إذا سجل اليوم أو استهلك كل محاولات التجميد)
    var isFreezeDisabled: Bool {
        isLogged || freezesUsed >= maxFreezes
    }
    
    
    
    var body: some View {
        
        NavigationStack {
            
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: - Header
                HStack(alignment: .top, spacing: 12) {
                    
                    // Title and Date
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text("Activity")
                            .font(.largeTitle.bold())
                            .padding(.leading, 16)
                        Text(
                            Date.now,
                            format: .dateTime
                                .weekday(.wide)
                                .day()
                                .month(.wide)
                        )
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 15)
                    }
                    
                    Spacer()
                    
                    // Buttons
                    GlassEffectContainer(spacing: 12) {
                        HStack(spacing: 12) {
                            Button("Calendar", systemImage: "calendar") {
                                // Calendar action
                            }
                            Button("Goal", systemImage: "pencil.and.outline") {
                                // Goal action
                            }
                        }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.glass)
                        .buttonBorderShape(.circle) // يحوّل الشكل إلى دائرة كاملة
                        .controlSize(.large)
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    .controlSize(.large)
                    .padding(.trailing, 16)
                }
                
                // MARK: - Weekly Calendar
                
                HStack(spacing: 10) {                              // المسافة بين الأيام 10
                    ForEach(0..<7, id: \.self) { day in
                        
                        Button {
                            withAnimation(.smooth) { selectedDay = day }
                        } label: {
                            VStack(spacing: 4) {                   // المسافة بين الحرف والدائرة 4
                                
                                Text(letters[day])
                                    .font(.caption.weight(.semibold))
                                    .frame(width: 28)              // صندوق الحرف، فتصير المسافة بين الأحرف 22
                                
                                Text("\(20 + day)")
                                    .font(.body)
                                    .foregroundStyle(day == selectedDay || day > selectedDay ? .white : .orange)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle().fill(
                                            day == selectedDay
                                            ? Color.orange                // المحدد: برتقالي كامل
                                            : (day < selectedDay ? Color.orange.opacity(0.2) : Color.clear)
                                        )
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 30)
                .padding(.trailing ,14 )//الهوامش؟؟؟

                
                
                
                
                
                // MARK: - Streak & Freeze Cards
                
                GlassEffectContainer {
                    HStack(spacing: 12) {
                        
                        // Streak Card
                        VStack(spacing: 8) {
                            
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange)
                                .font(.title2)
                            
                            Text("4 days")
                                .font(.headline)
                            
                            Text("Learned")
                                .font(.footnote)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .glassEffect(.regular.tint(.black.opacity(0.4)), in: .rect(cornerRadius: 34))
                        
                        // Freeze Card
                        VStack(spacing: 8) {
                            
                            Image(systemName: "snowflake")
                                .foregroundStyle(.cyan)
                                .font(.title2)
                            
                            Text("0 days")
                                .font(.headline)
                            
                            Text("Freezed")
                                .font(.footnote)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .glassEffect(.regular.tint(.black.opacity(0.4)), in: .rect(cornerRadius: 34))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.trailing ,14 )//الهوامش؟؟؟
                
                // MARK: - Action Buttons
                
                VStack(spacing: 0) {
                    
                    // Log as Learned
                    Button {
                        isLogged = true
                    } label: {
                        Text(isLogged ? "Logged as Learned" : "Log as Learned")
                            .font(.headline)
                            .foregroundStyle(isLogged ? .gray : .white)
                            .frame(width: 272, height: 272)
                            .background {
                                Circle()
                                    .fill(
                                        isLogged
                                        ? Color(uiColor: .secondarySystemBackground)
                                        : Color("Orange2")
                                    )
                            }
                            .overlay {
                                if !isLogged {
                                    Circle()
                                        .strokeBorder(
                                            Color.orange.opacity(0.7),
                                            lineWidth: 1.5
                                        )
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .disabled(isLogged)
                    .padding(.top,48)
                    
                    // 48pt between buttons
                    Spacer()
                        .frame(height: 48)
                    
                    // Freeze Section
                    VStack(spacing: 16) {
                        
                        Button {
                            freezesUsed += 1
                        } label: {
                            Text("Freeze for a day")
                                .font(.body.weight(.medium))
                                .foregroundStyle(isFreezeDisabled ? .gray : .white) // يتحول النص للرمادي عند التعطيل
                                .frame(width: 272, height: 46)
                        }
                        .buttonStyle(.plain)
                        .glassEffect(
                            isFreezeDisabled
                            ? .regular // زجاج شفاف بدون لون سماوي عند التعطيل
                            : .regular.tint(.cyan).interactive(), // زجاج سماوي تفاعلي عند التفعيل
                            in: .capsule
                        )
                        .disabled(isFreezeDisabled) // يمنع الضغط على الزر تماماً

                        Text("\(freezesUsed) out of \(maxFreezes) Freezes used")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    .frame(maxWidth: .infinity)
                    Spacer()
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}

#Preview {
    Logday()
}
