import Foundation

final class StudentStore {
    private(set) var students: [Student]

    init(students: [Student] = StudentSeedData.students) {
        self.students = students
    }

    // R-17/R-19: keep this explicit deinit. With Xcode 26 default MainActor
    // isolation the implicit deinit is isolated, and releasing a store inside
    // XCTest crashes (SIGABRT in swift_task_deinitOnExecutorImpl). An explicit
    // deinit is not isolated.
    deinit {}

    func students(matchingSubject subject: String) -> [Student] {
        students.filter { $0.subjects.contains(subject) }
    }

    func addStudent(name: String, age: Int) throws {
        try validate(name: name, age: age)
        students.append(Student(id: UUID(), name: name, age: age, averageGrade: 0, isScholarshipHolder: false, subjects: [], avatarName: "avatar-default"))
    }

    func updateStudent(id: UUID, name: String, age: Int) throws {
        try validate(name: name, age: age)
        guard let index = students.firstIndex(where: { $0.id == id }) else {
            throw StudentStoreError.unknownID(id)
        }
        students[index].name = name
        students[index].age = age
    }

    func deleteStudent(id: UUID) throws {
        guard let index = students.firstIndex(where: { $0.id == id }) else {
            throw StudentStoreError.unknownID(id)
        }
        students.remove(at: index)
    }

    private func validate(name: String, age: Int) throws {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw StudentStoreError.blankName
        }
        if age <= 0 {
            throw StudentStoreError.nonPositiveAge
        }
    }
}
