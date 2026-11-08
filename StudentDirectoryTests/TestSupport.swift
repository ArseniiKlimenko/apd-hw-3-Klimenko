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
