import UIKit
import XCTest
@testable import StudentDirectory

/// T6.4: swipe to delete with confirmation (R-49, R-58, R-59).
@MainActor
final class DeleteStudentTests: XCTestCase {
    private let zed = makeStudent(id: 1, name: "Zed", subjects: ["Physics"])
    private let amy = makeStudent(id: 2, name: "Amy", subjects: ["Design"])

    func testSwipeOffersDestructiveDeleteAction() throws {
        let list = makeLoadedList(store: StudentStore(students: [zed, amy]))

        let configuration = list.tableView.delegate?.tableView?(list.tableView, trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 1, section: 0))

        let actions = try XCTUnwrap(configuration?.actions, "Rule: a row offers swipe actions")
        XCTAssertEqual(actions.map(\.title), ["Delete"], "Rule: the swipe action is Delete")
        XCTAssertEqual(actions.first?.style, .destructive, "Rule: Delete is a destructive action")
    }

    func testSwipeDeleteAsksForConfirmationFirst() throws {
        let store = StudentStore(students: [zed, amy])
        let (window, navigation, list) = makeListInWindow(store: store)
        defer { window.isHidden = true }
        let action = try XCTUnwrap(list.tableView.delegate?.tableView?(list.tableView, trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 1, section: 0))?.actions.first, "Rule: a row offers a Delete swipe action")

        action.handler(action, UIView()) { _ in }

        let alert = try XCTUnwrap(navigation.presentedViewController as? UIAlertController, "Rule: Delete asks for confirmation (R-58)")
        XCTAssertEqual(alert.title, "Delete Amy?", "Rule: the confirmation names the student of the swiped row")
        XCTAssertEqual(alert.actions.map(\.title), ["Delete", "Cancel"], "Rule: the confirmation offers Delete and Cancel")
        XCTAssertEqual(alert.actions.map(\.style), [.destructive, .cancel], "Rule: Delete is destructive, Cancel is the cancel action")
        XCTAssertEqual(store.students, [zed, amy], "Rule: nothing is deleted before the confirmation")
    }

    func testConfirmedDeleteRemovesStudentFromStoreAndList() {
        let store = StudentStore(students: [zed, amy])
        let (window, _, list) = makeListInWindow(store: store)
        defer { window.isHidden = true }

        list.deleteStudent(withID: amy.id)

        XCTAssertEqual(store.students, [zed], "Rule: a confirmed delete removes the student from the shared store")
        XCTAssertEqual(list.tableView.numberOfRows(inSection: 0), 1, "Rule: the list drops the deleted row (refresh)")
    }

    func testConfirmedDeleteOnFilteredListRemovesStudentEverywhere() {
        let store = StudentStore(students: [zed, amy])
        let filtered = makeLoadedFilteredList(store: store, subject: "Design")

        filtered.deleteStudent(withID: amy.id)

        XCTAssertEqual(store.students, [zed], "Rule: deleting on a filtered list deletes from the shared store (R-49)")
        XCTAssertEqual(filtered.tableView.numberOfRows(inSection: 0), 0, "Rule: the filtered list drops the deleted row")
        XCTAssertEqual(makeLoadedList(store: store).displayedRowCount, 1, "Rule: the main list no longer has the deleted student")
    }
}
