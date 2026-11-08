import UIKit
import XCTest
@testable import StudentDirectory

/// T3: the details screen and the push from the list.
@MainActor
final class StudentDetailTests: XCTestCase {
    func testSelectingRowPushesDetailsOfThatStudent() throws {
        let (navigation, list) = makeListInNavigation(store: StudentStore())
        let grace = try seedStudent(named: "Grace Hopper")

        // Grace Hopper is row 2 of the seed; a push without a window updates
        // the stack at once (PLAN fact 21).
        list.tableView.delegate?.tableView?(list.tableView, didSelectRowAt: IndexPath(row: 2, section: 0))

        XCTAssertEqual(navigation.viewControllers.count, 2, "Rule: tapping a row pushes one screen")
        let details = try XCTUnwrap(navigation.topViewController as? StudentDetailViewController, "Rule: the pushed screen is the details screen")
        XCTAssertEqual(details.studentID, grace.id, "Rule: the details show the tapped student")
    }

    func testDetailsShowEveryStudentField() throws {
        let grace = try seedStudent(named: "Grace Hopper")
        let details = makeLoadedDetails(store: StudentStore(), studentID: grace.id)

        let shown: [(String, UIView)] = [
            ("avatar", details.avatarView), ("name", details.nameLabel), ("ID", details.idLabel),
            ("age", details.ageLabel), ("grade", details.gradeLabel), ("scholarship", details.scholarshipLabel),
            ("avatar name", details.avatarNameLabel), ("subjects title", details.subjectsTitleLabel)
        ]
        for (name, view) in shown {
            XCTAssertTrue(view.isDescendant(of: details.view), "Rule: the \(name) is shown on the details screen")
        }
        XCTAssertEqual(details.navigationItem.title, "Grace Hopper", "Rule: the details title is the student's name (R-33)")
        XCTAssertTrue(details.avatarView.image === UIImage(named: "avatar-03"), "Rule: the details show the student's avatar")
        XCTAssertEqual(details.nameLabel.text, "Grace Hopper", "Rule: the details show the name")
        XCTAssertEqual(details.idLabel.text, "ID 00000000-0000-0000-0000-000000000003", "Rule: the details show the id")
        XCTAssertEqual(details.ageLabel.text, "Age 22", "Rule: the details show the age")
        XCTAssertEqual(details.gradeLabel.text, "Grade 91.5", "Rule: the details show the average grade")
        XCTAssertEqual(details.scholarshipLabel.text, "No scholarship", "Rule: the details show the scholarship status")
        XCTAssertEqual(details.avatarNameLabel.text, "Avatar avatar-03", "Rule: the details show the avatar name")
        XCTAssertEqual(details.subjectsTitleLabel.text, "Subjects", "Rule: the subjects have a heading")
        XCTAssertEqual(
            details.subjectButtons.map { $0.title(for: .normal) },
            ["Programming", "Algorithms"],
            "Rule: the details show every subject in model order (R-32)"
        )
        for button in details.subjectButtons {
            XCTAssertTrue(button.isDescendant(of: details.view), "Rule: the subject \(button.title(for: .normal) ?? "?") is shown")
        }
    }

    func testDetailsViewHasStudentDetailsIdentifier() throws {
        let details = makeLoadedDetails(store: StudentStore(), studentID: try seedStudent(named: "Grace Hopper").id)

        XCTAssertEqual(details.view.accessibilityIdentifier, "studentDetails", "Rule: the details screen is identified as studentDetails")
    }

    func testDetailsForMissingStudentShowNoStudentData() {
        // Agent-proposed rule (R-7, R-34), not an assignment requirement.
        let store = StudentStore(students: [makeStudent(id: 1, name: "Amy", subjects: ["Math"])])
        let details = makeLoadedDetails(store: store, studentID: makeStudent(id: 9, name: "Gone", subjects: []).id)

        XCTAssertTrue(details.notFoundLabel.isDescendant(of: details.view), "Rule: a missing student shows a not-found message")
        XCTAssertEqual(details.notFoundLabel.text, "Student not found", "Rule: the not-found message text (R-34)")
        XCTAssertFalse(details.nameLabel.isDescendant(of: details.view), "Rule: a missing student shows no student fields")
        XCTAssertTrue(details.subjectButtons.isEmpty, "Rule: a missing student shows no subjects")
    }

    func testDetailsTextSupportsDynamicType() throws {
        let details = makeLoadedDetails(store: StudentStore(), studentID: try seedStudent(named: "Grace Hopper").id)

        let labels: [(String, UILabel?)] = [
            ("name label", details.nameLabel), ("ID label", details.idLabel), ("age label", details.ageLabel),
            ("grade label", details.gradeLabel), ("scholarship label", details.scholarshipLabel),
            ("avatar name label", details.avatarNameLabel), ("subjects title", details.subjectsTitleLabel)
        ]
        for (name, label) in labels {
            assertFollowsDynamicType(label, name)
        }
        XCTAssertFalse(details.subjectButtons.isEmpty, "Precondition: Grace Hopper has subjects")
        for button in details.subjectButtons {
            assertFollowsDynamicType(button.titleLabel, "subject button \(button.title(for: .normal) ?? "?")")
        }
    }
}
