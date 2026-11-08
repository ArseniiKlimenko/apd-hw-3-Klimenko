import UIKit
import XCTest
@testable import StudentDirectory

/// T4: subject buttons on the details screen and the filtered list.
@MainActor
final class SubjectFilterTests: XCTestCase {
    func testDetailsHaveButtonForEachSubject() throws {
        let details = makeLoadedDetails(store: StudentStore(), studentID: try seedStudent(named: "Ada Lovelace").id)

        XCTAssertEqual(
            details.subjectButtons.map(\.accessibilityIdentifier),
            ["subjectButton.Algorithms", "subjectButton.Math", "subjectButton.Design"],
            "Rule: every subject is a button identified as subjectButton.<subject>, in model order"
        )
    }

    func testTappingSubjectPushesListTitledWithSubject() throws {
        let details = StudentDetailViewController(store: StudentStore(), studentID: try seedStudent(named: "Ada Lovelace").id)
        let navigation = UINavigationController(rootViewController: details)
        details.loadViewIfNeeded()
        let design = try XCTUnwrap(details.subjectButtons.first { $0.title(for: .normal) == "Design" }, "Precondition: Ada has Design")

        // sendActions runs the button's UIAction without a window (PLAN fact 35).
        design.sendActions(for: .touchUpInside)

        XCTAssertEqual(navigation.viewControllers.count, 2, "Rule: tapping a subject pushes one screen")
        let filtered = try XCTUnwrap(navigation.topViewController as? StudentListViewController, "Rule: the pushed screen is a student list")
        filtered.loadViewIfNeeded()
        XCTAssertEqual(filtered.navigationItem.title, "Design", "Rule: the filtered list is titled with the subject")
    }

    func testFilteredListShowsExactMatchesInStoreOrder() {
        // R-36: ids and names are deliberately out of order, so sorting by
        // name or by id would change the rows.
        let zed = makeStudent(id: 3, name: "Zed", subjects: ["Math"])
        let amy = makeStudent(id: 1, name: "Amy", subjects: ["Art"])
        let mia = makeStudent(id: 2, name: "Mia", subjects: ["Art", "Math"])
        let bob = makeStudent(id: 4, name: "Bob", subjects: ["Math"])
        let list = makeLoadedFilteredList(store: StudentStore(students: [zed, amy, mia, bob]), subject: "Math")

        let identifiers = (0..<list.displayedRowCount).map {
            list.displayedCell(at: $0)?.accessibilityIdentifier ?? "<missing>"
        }
        XCTAssertEqual(
            identifiers,
            [zed, mia, bob].map { "studentCell.\($0.id.uuidString)" },
            "Rule: the filtered list shows only students with the subject, in store order"
        )
    }

    func testFilteredListIsCaseSensitive() {
        let upper = makeStudent(id: 1, name: "Upper", subjects: ["Math"])
        let lower = makeStudent(id: 2, name: "Lower", subjects: ["math"])
        let list = makeLoadedFilteredList(store: StudentStore(students: [upper, lower]), subject: "Math")

        let identifiers = (0..<list.displayedRowCount).map {
            list.displayedCell(at: $0)?.accessibilityIdentifier ?? "<missing>"
        }
        XCTAssertEqual(identifiers, ["studentCell.\(upper.id.uuidString)"], "Rule: the filtered list matches the subject case-sensitively")
    }

    func testFilteredRowOpensDetailsOfFilteredStudent() throws {
        let (navigation, filtered) = makeListInNavigation(store: StudentStore(), subject: "Design")

        // Row 1 of Design is Mary Jackson; row 1 of the full list is Alan Turing.
        filtered.tableView.delegate?.tableView?(filtered.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))

        let details = try XCTUnwrap(navigation.topViewController as? StudentDetailViewController, "Rule: a filtered row opens the details screen")
        XCTAssertEqual(details.studentID, try seedStudent(named: "Mary Jackson").id, "Rule: a filtered row opens the student shown in that row")
    }
}
