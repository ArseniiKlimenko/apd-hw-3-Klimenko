import XCTest
@testable import StudentDirectory

/// T1: characterization tests for the supplied `StudentStore` (R-5).
@MainActor
final class StudentStoreTests: XCTestCase {
    func testSeedStoreKeepsSeedStudentsInOrder() {
        let expectedIDs = (1...10).map { String(format: "00000000-0000-0000-0000-%012d", $0) }

        XCTAssertEqual(
            StudentStore().students.map(\.id.uuidString),
            expectedIDs,
            "Rule: the default store contains the seed students in seed order"
        )
    }

    func testStoreUsesInjectedStudents() {
        let injected = [
            makeStudent(id: 2, name: "Mia", subjects: ["Math"]),
            makeStudent(id: 1, name: "Amy", subjects: ["Art"])
        ]

        XCTAssertEqual(
            StudentStore(students: injected).students,
            injected,
            "Rule: the store keeps exactly the injected students in the given order"
        )
    }

    func testSubjectFilterKeepsStoreOrder() {
        // R-20: ids and names are deliberately out of order, so sorting by
        // name or by id would change the result.
        let store = StudentStore(students: [
            makeStudent(id: 3, name: "Zed", subjects: ["Math"]),
            makeStudent(id: 1, name: "Amy", subjects: ["Math"]),
            makeStudent(id: 2, name: "Mia", subjects: ["Art", "Math"])
        ])

        XCTAssertEqual(
            store.students(matchingSubject: "Math").map(\.name),
            ["Zed", "Amy", "Mia"],
            "Rule: the subject filter keeps store order"
        )
    }

    func testSubjectFilterIsCaseSensitive() {
        let upper = makeStudent(id: 1, name: "Upper", subjects: ["Math"])
        let lower = makeStudent(id: 2, name: "Lower", subjects: ["math"])
        let store = StudentStore(students: [upper, lower])

        XCTAssertEqual(
            store.students(matchingSubject: "Math"),
            [upper],
            "Rule: the subject filter is case-sensitive"
        )
    }

    func testSubjectFilterRequiresExactMatch() {
        let store = StudentStore(students: [makeStudent(id: 1, name: "Ada", subjects: ["Physics"])])

        XCTAssertEqual(store.students(matchingSubject: "Physics").count, 1, "Precondition: the exact subject matches")
        XCTAssertEqual(
            store.students(matchingSubject: "Phys"),
            [],
            "Rule: exact match only, a substring of a subject does not match"
        )
        XCTAssertEqual(
            store.students(matchingSubject: "Physics "),
            [],
            "Rule: exact match only, extra whitespace does not match"
        )
    }

    func testSubjectFilterWithUnknownSubjectIsEmpty() {
        let store = StudentStore(students: [
            makeStudent(id: 1, name: "Ada", subjects: ["Math"]),
            makeStudent(id: 2, name: "Alan", subjects: ["Physics"])
        ])

        XCTAssertEqual(
            store.students(matchingSubject: "Chemistry"),
            [],
            "Rule: an unknown subject gives an empty list"
        )
    }
}
