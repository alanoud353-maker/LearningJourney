//
//  DayStatus.swift
//  LearningJourney
//
//  Created by alanoud on 01/06/1448 AH.
// ليه استخدمت enum لان عندي حالة انه اكتمل اليوم او جمده او ماكمل اليوم
//هنا احسبها على اختيار اليوزر
// يُستخدم لـ تحويل البيانات من وإلى صيغ خارجية مثل JSON Codable
enum DayStatus: String, Codable {
    case completed
    case frozen
}
