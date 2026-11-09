import UIKit
import XCTest
@testable import StudentDirectory

/// T6.3: editing name and age from the details screen (R-43, R-44, R-46).
@MainActor
final class EditStudentTests: XCTestCase {
    private let zed = makeStudent(id: 1, name: "Zed", subjects: ["Physics"])
    private let amy = makeStudent(id: 2, name: "Amy", subjects: ["Design"])

    /// Details of Amy in a window with the edit form presented.
    private func presentEditForm(store: StudentStore) throws -> (window: UIWindow, details: StudentDetailViewController, form: StudentFormViewController) {
        let (window, navigation, details) = makeDetailsInWindow(store: store, studentID: amy.id)
        details.showEditForm()
        let presented = try XCTUnwrap(navigation.presentedViewController as? UINavigationController, "Rule: the edit button presents the form in its own navigation controller")
        let form = try XCTUnwrap(presented.topViewController as? StudentFormViewController, "Rule: the presented screen is the student form")
        form.loadViewIfNeeded()
        return (window, details, form)
    }

    func testDetailsHaveEditStudentButton() {
        let details = makeLoadedDetails(store: StudentStore(students: [zed, amy]), studentID: amy.id)

        XCTAssertEqual(details.navigationItem.rightBarButtonItem?.accessibilityIdentifier, "editStudentButton", "Rule: the details screen has the editStudentButton")
    }

    func testNotFoundDetailsHaveNoEditButton() {
        let details = makeLoadedDetails(store: StudentStore(students: [zed]), studentID: amy.id)

        XCTAssertNil(details.navigationItem.rightBarButtonItem, "Rule: Student not found has no edit button (R-44)")
    }

    func testEditButtonPresentsFilledEditForm() throws {
        let (window, _, form) = try presentEditForm(store: StudentStore(students: [zed, amy]))
        defer { window.isHidden = true }

        XCTAssertEqual(form.title, "Edit Student", "Rule: the edit form is titled Edit Student")
        XCTAssertEqual(form.nameField.text, "Amy", "Rule: the edit form starts with the student's name")
        XCTAssertEqual(form.ageField.text, "20", "Rule: the edit form starts with the student's age")
    }

    func testSavingEditUpdatesStoreAndRefreshesDetails() throws {
        let store = StudentStore(students: [zed, amy])
        let (window, details, form) = try presentEditForm(store: store)
        defer { window.isHidden = true }
        form.nameField.text = "Ann"
        form.ageField.text = "33"

        form.save()

        var expectedAmy = amy
        expectedAmy.name = "Ann"
        expectedAmy.age = 33
        XCTAssertEqual(store.students, [zed, expectedAmy], "Rule: saving an edit updates only that student's name and age in the shared store")
        XCTAssertEqual(details.title, "Ann", "Rule: the details title shows the new name after saving")
        XCTAssertEqual(details.nameLabel.text, "Ann", "Rule: the details show the new name after saving")
        XCTAssertEqual(details.ageLabel.text, "Age 33", "Rule: the details show the new age after saving")
    }

    func testInvalidEditShowsErrorAndKeepsStore() {
        let store = StudentStore(students: [zed, amy])
        let form = StudentFormViewController(store: store, editing: amy.id)
        form.loadViewIfNeeded()
        form.nameField.text = " "

        form.save()

        XCTAssertEqual(form.errorLabel.text, "Name must not be blank", "Rule: a blank name in an edit shows Name must not be blank")
        XCTAssertEqual(store.students, [zed, amy], "Rule: a rejected edit does not change the store")
    }

    func testEditOfDeletedStudentShowsNotFound() throws {
        let store = StudentStore(students: [zed, amy])
        let form = StudentFormViewController(store: store, editing: amy.id)
        form.loadViewIfNeeded()
        try store.deleteStudent(id: amy.id)

        form.save()

        XCTAssertEqual(form.errorLabel.text, "Student not found", "Rule: editing a student that is gone shows Student not found")
        XCTAssertEqual(store.students, [zed], "Rule: an edit of an unknown id does not change the store")
    }

    func testListReloadsWhenItAppearsAgain() throws {
        let store = StudentStore(students: [zed, amy])
        let (window, _, list) = makeListInWindow(store: store)
        defer { window.isHidden = true }
        try store.updateStudent(id: amy.id, name: "Ann", age: 33)

        list.viewWillAppear(false)

        let cell = list.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? StudentCell
        XCTAssertEqual(cell?.nameLabel.text, "Ann", "Rule: the list shows edited data when it appears again (R-46)")
    }
}
