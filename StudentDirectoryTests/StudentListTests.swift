import UIKit
import XCTest
@testable import StudentDirectory

/// T2: the student list screen and its reusable cell.
@MainActor
final class StudentListTests: XCTestCase {
    private let posix = Locale(identifier: "en_US_POSIX")

    func testListTitleIsStudents() {
        let list = makeLoadedList(store: StudentStore())

        XCTAssertEqual(list.navigationItem.title, "Students", "Rule: the list title is Students")
    }

    func testListHasOneRowPerStoreStudent() {
        let store = StudentStore(students: [
            makeStudent(id: 1, name: "Amy", subjects: []),
            makeStudent(id: 2, name: "Mia", subjects: []),
            makeStudent(id: 3, name: "Zed", subjects: [])
        ])
        let list = makeLoadedList(store: store)

        XCTAssertEqual(list.displayedRowCount, 3, "Rule: the list has one row per store student")
    }

    func testListRowsFollowStoreOrder() {
        let students = [
            makeStudent(id: 3, name: "Zed", subjects: []),
            makeStudent(id: 1, name: "Amy", subjects: []),
            makeStudent(id: 2, name: "Mia", subjects: [])
        ]
        let list = makeLoadedList(store: StudentStore(students: students))

        let identifiers = (0..<list.displayedRowCount).map {
            list.displayedCell(at: $0)?.accessibilityIdentifier ?? "<missing>"
        }
        XCTAssertEqual(
            identifiers,
            students.map { "studentCell.\($0.id.uuidString)" },
            "Rule: row i shows store student i, identified as studentCell.<id>"
        )
    }

    func testListTableHasStudentListIdentifier() {
        let list = makeLoadedList(store: StudentStore())

        XCTAssertTrue(list.tableView.isDescendant(of: list.view), "Precondition: the table is on the screen")
        XCTAssertEqual(list.tableView.accessibilityIdentifier, "studentList", "Rule: the table is identified as studentList")
    }

    func testCellShowsNameAgeGradeAndScholarship() throws {
        let cell = StudentCell(style: .default, reuseIdentifier: nil)
        cell.configure(with: try seedStudent(named: "Ada Lovelace"), locale: posix)

        let shown: [(String, UIView)] = [
            ("avatar", cell.avatarView), ("name", cell.nameLabel), ("age", cell.ageLabel),
            ("grade", cell.gradeLabel), ("scholarship", cell.scholarshipLabel)
        ]
        for (name, view) in shown {
            XCTAssertTrue(view.isDescendant(of: cell.contentView), "Rule: the \(name) is shown in the cell")
        }
        XCTAssertTrue(cell.avatarView.image === UIImage(named: "avatar-01"), "Rule: the cell shows the student's avatar")
        XCTAssertEqual(cell.nameLabel.text, "Ada Lovelace", "Rule: the cell shows the name")
        XCTAssertEqual(cell.ageLabel.text, "Age 20", "Rule: the cell shows the age")
        XCTAssertEqual(cell.gradeLabel.text, "Grade 97.5", "Rule: the cell shows the average grade")
        XCTAssertEqual(cell.scholarshipLabel.text, "Scholarship", "Rule: the cell shows the scholarship status")
    }

    func testReusedCellResetsScholarshipState() throws {
        let cell = StudentCell(style: .default, reuseIdentifier: nil)
        cell.configure(with: try seedStudent(named: "Ada Lovelace"), locale: posix)
        cell.configure(with: try seedStudent(named: "Grace Hopper"), locale: posix)

        XCTAssertEqual(
            cell.scholarshipLabel.text,
            "No scholarship",
            "Rule: a reused cell shows the new student's scholarship status"
        )
    }

    func testCellAccessibilityLabelSummarizesStudent() throws {
        let cell = StudentCell(style: .default, reuseIdentifier: nil)
        cell.configure(with: try seedStudent(named: "Ada Lovelace"), locale: posix)

        XCTAssertTrue(cell.isAccessibilityElement, "Rule: the cell is one accessibility element (R-10)")
        XCTAssertEqual(
            cell.accessibilityLabel,
            "Ada Lovelace, age 20, grade 97.5, scholarship holder",
            "Rule: the cell label summarizes a scholarship holder"
        )

        cell.configure(with: try seedStudent(named: "Grace Hopper"), locale: posix)
        XCTAssertEqual(
            cell.accessibilityLabel,
            "Grace Hopper, age 22, grade 91.5, no scholarship",
            "Rule: the cell label summarizes a student without a scholarship"
        )
    }

    func testCellTextSupportsDynamicType() {
        let cell = StudentCell(style: .default, reuseIdentifier: nil)
        let textStyles: [UIFont.TextStyle] = [
            .largeTitle, .title1, .title2, .title3, .headline, .subheadline, .body, .callout, .footnote, .caption1, .caption2
        ]
        let textStyleNames = Set(textStyles.map(\.rawValue))
        let labels = [
            ("name", cell.nameLabel), ("age", cell.ageLabel),
            ("grade", cell.gradeLabel), ("scholarship", cell.scholarshipLabel)
        ]

        for (name, label) in labels {
            // A fixed system font also carries a textStyle attribute, so only
            // a real text style name counts (PLAN fact 19).
            let style = label.font.fontDescriptor.object(forKey: .textStyle) as? String ?? "<none>"
            XCTAssertTrue(textStyleNames.contains(style), "Rule: the \(name) label uses a text style font, got \(style)")
            XCTAssertTrue(label.adjustsFontForContentSizeCategory, "Rule: the \(name) label follows Dynamic Type changes")
            XCTAssertEqual(label.numberOfLines, 0, "Rule: the \(name) label wraps instead of truncating")
        }
    }

    func testGradeFormattingFollowsLocale() {
        XCTAssertEqual(StudentFormatting.grade(97.5, locale: posix), "Grade 97.5", "Rule: the grade uses the locale's decimal separator")
        XCTAssertEqual(
            StudentFormatting.grade(97.5, locale: Locale(identifier: "uk_UA")),
            "Grade 97,5",
            "Rule: the grade uses the locale's decimal separator"
        )
        XCTAssertEqual(StudentFormatting.grade(94, locale: posix), "Grade 94.0", "Rule: the grade always shows one fraction digit")
    }

    func testListReflectsStoreChangesAfterReload() throws {
        let store = StudentStore()
        let list = makeLoadedList(store: store)
        XCTAssertEqual(list.displayedRowCount, 10, "Precondition: all seed students are listed")

        try store.deleteStudent(id: try seedStudent(named: "Ada Lovelace").id)
        list.tableView.reloadData()

        XCTAssertEqual(list.displayedRowCount, 9, "Rule: the list reads the shared store, not a copy (R-7)")
    }

    func testCellStacksVerticallyForAccessibilityTextSizes() {
        let cell = StudentCell(style: .default, reuseIdentifier: nil)

        // A cell without a window applies trait overrides only after
        // updateTraitsIfNeeded() (PLAN fact 20).
        cell.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
        cell.updateTraitsIfNeeded()
        XCTAssertEqual(cell.contentStack.axis, .vertical, "Rule: accessibility text sizes put the avatar above the text (R-23)")

        cell.traitOverrides.preferredContentSizeCategory = .large
        cell.updateTraitsIfNeeded()
        XCTAssertEqual(cell.contentStack.axis, .horizontal, "Rule: regular text sizes keep the avatar beside the text (R-23)")
    }
}
