import Foundation

/// Texts for student fields, shared by the list cell and the details screen.
enum StudentFormatting {
    static func age(_ age: Int) -> String {
        "Age \(age)"
    }

    static func grade(_ grade: Double, locale: Locale = .current) -> String {
        "Grade \(gradeNumber(grade, locale: locale))"
    }

    static func scholarship(_ isScholarshipHolder: Bool) -> String {
        isScholarshipHolder ? "Scholarship" : "No scholarship"
    }

    /// One VoiceOver phrase for a list row (R-10).
    static func accessibilityLabel(for student: Student, locale: Locale = .current) -> String {
        let scholarship = student.isScholarshipHolder ? "scholarship holder" : "no scholarship"
        return "\(student.name), age \(student.age), grade \(gradeNumber(student.averageGrade, locale: locale)), \(scholarship)"
    }

    /// One fraction digit with the locale's decimal separator (R-9).
    private static func gradeNumber(_ grade: Double, locale: Locale) -> String {
        grade.formatted(.number.precision(.fractionLength(1)).locale(locale))
    }
}
