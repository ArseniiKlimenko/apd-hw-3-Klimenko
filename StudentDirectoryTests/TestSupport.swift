import UIKit
import XCTest
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

/// A seed student looked up by name, so tests read like the data they use.
func seedStudent(named name: String) throws -> Student {
    try XCTUnwrap(StudentSeedData.students.first { $0.name == name }, "Seed student \(name) exists")
}

/// A list controller with its view loaded, as UIKit does before showing it.
@MainActor
func makeLoadedList(store: StudentStore) -> StudentListViewController {
    let list = StudentListViewController(store: store)
    list.loadViewIfNeeded()
    return list
}

/// A list inside a navigation controller, as `SceneDelegate` builds it.
@MainActor
func makeListInNavigation(store: StudentStore) -> (navigation: UINavigationController, list: StudentListViewController) {
    let list = StudentListViewController(store: store)
    let navigation = UINavigationController(rootViewController: list)
    list.loadViewIfNeeded()
    return (navigation, list)
}

/// A details controller with its view loaded; grades use `en_US_POSIX` (R-9).
@MainActor
func makeLoadedDetails(store: StudentStore, studentID: UUID) -> StudentDetailViewController {
    let details = StudentDetailViewController(store: store, studentID: studentID, locale: Locale(identifier: "en_US_POSIX"))
    details.loadViewIfNeeded()
    return details
}

/// Dynamic Type check for one label. A fixed system font also carries a
/// textStyle attribute, so only a real text style name counts (PLAN fact 19).
@MainActor
func assertFollowsDynamicType(_ label: UILabel?, _ name: String, file: StaticString = #filePath, line: UInt = #line) {
    guard let label else {
        XCTFail("Rule: the \(name) has a label", file: file, line: line)
        return
    }
    let textStyles: [UIFont.TextStyle] = [
        .largeTitle, .title1, .title2, .title3, .headline, .subheadline, .body, .callout, .footnote, .caption1, .caption2
    ]
    let style = label.font.fontDescriptor.object(forKey: .textStyle) as? String ?? "<none>"
    XCTAssertTrue(textStyles.map(\.rawValue).contains(style), "Rule: the \(name) uses a text style font, got \(style)", file: file, line: line)
    XCTAssertTrue(label.adjustsFontForContentSizeCategory, "Rule: the \(name) follows Dynamic Type changes", file: file, line: line)
    XCTAssertEqual(label.numberOfLines, 0, "Rule: the \(name) wraps instead of truncating", file: file, line: line)
}

@MainActor
extension StudentListViewController {
    /// Row count as UIKit asks the table's data source for it.
    var displayedRowCount: Int {
        tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0) ?? 0
    }

    /// The cell the data source returns for `row`.
    func displayedCell(at row: Int) -> UITableViewCell? {
        tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: row, section: 0))
    }
}
