import Foundation
@testable import StudentDirectory

/// Builds a test student; only the fields a test cares about are parameters.
func makeStudent(id: UInt8, name: String, subjects: [String]) -> Student {
    Student(
        id: makeID(id),
        name: name,
        age: 20,
        averageGrade: 90,
        isScholarshipHolder: false,
        subjects: subjects,
        avatarName: "avatar-default"
    )
}

/// UUID whose last byte is `last`; built from bytes, so no optional and no `!`.
private func makeID(_ last: UInt8) -> UUID {
    UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, last))
}
