import XCTest
@testable import StudentDirectory

/// T6.1: the bonus mutations of the shared store (characterization, R-5).
/// Every rejected call must leave the store unchanged.
@MainActor
final class StoreMutationTests: XCTestCase {
    private let zed = makeStudent(id: 1, name: "Zed", subjects: ["Physics"])
    private let amy = makeStudent(id: 2, name: "Amy", subjects: ["Design"])
    private let mia = makeStudent(id: 3, name: "Mia", subjects: [])
    /// Not in the store.
    private let ghostID = makeStudent(id: 9, name: "Ghost", subjects: []).id

    private func makeStore() -> StudentStore {
        StudentStore(students: [zed, amy, mia])
    }

    func testAddAppendsStudentWithBonusDefaults() throws {
        let store = makeStore()

        try store.addStudent(name: "Noa", age: 19)

        XCTAssertEqual(Array(store.students.prefix(3)), [zed, amy, mia], "Rule: adding keeps the existing students and their order")
        let added = try XCTUnwrap(store.students.dropFirst(3).first, "Rule: adding appends one student at the end")
        XCTAssertEqual(store.students.count, 4, "Rule: adding appends exactly one student")
        XCTAssertEqual(added.name, "Noa", "Rule: the new student has the given name")
        XCTAssertEqual(added.age, 19, "Rule: the new student has the given age")
        XCTAssertEqual(added.averageGrade, 0, "Rule: a new student has grade 0")
        XCTAssertFalse(added.isScholarshipHolder, "Rule: a new student has no scholarship")
        XCTAssertEqual(added.subjects, [], "Rule: a new student has no subjects")
        XCTAssertEqual(added.avatarName, "avatar-default", "Rule: a new student has the bundled default avatar")
    }

    func testAddGivesNewStudentANewID() throws {
        let store = makeStore()

        try store.addStudent(name: "Noa", age: 19)

        let added = try XCTUnwrap(store.students.last)
        // R-50: UUID() is version 4, the fixed test ids are not (PLAN fact 41),
        // so this does not depend on the random value.
        XCTAssertFalse([zed.id, amy.id, mia.id].contains(added.id), "Rule: a new student gets a new UUID, not an existing one")
    }

    func testAddRejectsBlankNameWithoutChange() {
        let store = makeStore()

        for name in ["", "   ", "\n\t"] {
            assertThrows({ try store.addStudent(name: name, age: 19) }, error: .blankName, rule: "adding with the blank name \(name.debugDescription) throws blankName")
        }

        XCTAssertEqual(store.students, [zed, amy, mia], "Rule: a rejected add does not change the store")
    }

    func testAddRejectsNonPositiveAgeWithoutChange() {
        let store = makeStore()

        for age in [0, -1] {
            assertThrows({ try store.addStudent(name: "Noa", age: age) }, error: .nonPositiveAge, rule: "adding with age \(age) throws nonPositiveAge")
        }

        XCTAssertEqual(store.students, [zed, amy, mia], "Rule: a rejected add does not change the store")
    }

    func testAddAcceptsSmallestPositiveAge() {
        let store = makeStore()

        XCTAssertNoThrow(try store.addStudent(name: "Noa", age: 1), "Rule: age 1 is a valid age")
        XCTAssertEqual(store.students.last?.age, 1, "Rule: a student with age 1 is added")
    }

    func testUpdateChangesOnlyNameAndAge() throws {
        let store = makeStore()

        try store.updateStudent(id: amy.id, name: "Ann", age: 33)

        var expectedAmy = amy
        expectedAmy.name = "Ann"
        expectedAmy.age = 33
        XCTAssertEqual(store.students, [zed, expectedAmy, mia], "Rule: an update changes only that student's name and age, in place")
    }

    func testUpdateRejectsInvalidInputWithoutChange() {
        let store = makeStore()

        assertThrows({ try store.updateStudent(id: amy.id, name: "  ", age: 33) }, error: .blankName, rule: "updating with a blank name throws blankName")
        assertThrows({ try store.updateStudent(id: amy.id, name: "Ann", age: 0) }, error: .nonPositiveAge, rule: "updating with age 0 throws nonPositiveAge")

        XCTAssertEqual(store.students, [zed, amy, mia], "Rule: a rejected update does not change the store")
    }

    func testUpdateUnknownIDThrowsWithoutChange() {
        let store = makeStore()

        assertThrows({ try store.updateStudent(id: ghostID, name: "Ann", age: 33) }, error: .unknownID(ghostID), rule: "updating an unknown id throws unknownID with that id")

        XCTAssertEqual(store.students, [zed, amy, mia], "Rule: an update of an unknown id does not change the store")
    }

    func testDeleteRemovesOnlyThatStudent() throws {
        let store = makeStore()

        try store.deleteStudent(id: amy.id)

        XCTAssertEqual(store.students, [zed, mia], "Rule: deleting removes only that student and keeps the order of the rest")
    }

    func testDeleteUnknownIDThrowsWithoutChange() {
        let store = makeStore()

        assertThrows({ try store.deleteStudent(id: ghostID) }, error: .unknownID(ghostID), rule: "deleting an unknown id throws unknownID with that id")

        XCTAssertEqual(store.students, [zed, amy, mia], "Rule: a delete of an unknown id does not change the store")
    }
}
