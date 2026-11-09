import UIKit
import XCTest
@testable import StudentDirectory

/// T6.2: the add form and the add button (R-43…R-48, R-52…R-56).
@MainActor
final class AddStudentTests: XCTestCase {
    private let zed = makeStudent(id: 1, name: "Zed", subjects: ["Physics"])
    private let amy = makeStudent(id: 2, name: "Amy", subjects: ["Design"])

    private func makeForm(store: StudentStore, name: String, age: String) -> StudentFormViewController {
        let form = StudentFormViewController(store: store)
        form.loadViewIfNeeded()
        form.nameField.text = name
        form.ageField.text = age
        return form
    }

    func testMainListHasAddStudentButton() {
        let list = makeLoadedList(store: StudentStore(students: [zed, amy]))

        XCTAssertEqual(list.navigationItem.rightBarButtonItem?.accessibilityIdentifier, "addStudentButton", "Rule: the Students list has the addStudentButton")
    }

    func testFilteredListHasNoAddStudentButton() {
        let list = makeLoadedFilteredList(store: StudentStore(students: [zed, amy]), subject: "Design")

        XCTAssertNil(list.navigationItem.rightBarButtonItem, "Rule: a filtered list has no add button (R-44)")
    }

    func testAddButtonPresentsEmptyAddForm() throws {
        let (window, navigation, list) = makeListInWindow(store: StudentStore(students: [zed, amy]))
        defer { window.isHidden = true }

        list.showAddForm()

        let presented = try XCTUnwrap(navigation.presentedViewController as? UINavigationController, "Rule: the add button presents the form in its own navigation controller")
        let form = try XCTUnwrap(presented.topViewController as? StudentFormViewController, "Rule: the presented screen is the student form")
        form.loadViewIfNeeded()
        XCTAssertEqual(form.title, "New Student", "Rule: the add form is titled New Student")
        XCTAssertEqual(form.nameField.text ?? "", "", "Rule: the add form starts with an empty name")
        XCTAssertEqual(form.ageField.text ?? "", "", "Rule: the add form starts with an empty age")
        XCTAssertEqual(form.nameField.accessibilityIdentifier, "studentNameField", "Rule: the name field is studentNameField")
        XCTAssertEqual(form.ageField.accessibilityIdentifier, "studentAgeField", "Rule: the age field is studentAgeField")
        XCTAssertEqual(form.errorLabel.accessibilityIdentifier, "studentFormError", "Rule: the error label is studentFormError")
        XCTAssertEqual(form.navigationItem.rightBarButtonItem?.accessibilityIdentifier, "saveStudentButton", "Rule: the form has the saveStudentButton")
        XCTAssertEqual(form.navigationItem.leftBarButtonItem?.accessibilityIdentifier, "cancelStudentButton", "Rule: the form has the cancelStudentButton")
    }

    func testSavingValidInputAddsStudentAndRefreshesList() throws {
        let store = StudentStore(students: [zed, amy])
        let (window, navigation, list) = makeListInWindow(store: store)
        defer { window.isHidden = true }
        XCTAssertEqual(list.tableView.numberOfRows(inSection: 0), 2, "Precondition: the table shows the two students")
        list.showAddForm()
        let form = try XCTUnwrap((navigation.presentedViewController as? UINavigationController)?.topViewController as? StudentFormViewController, "Rule: the add button presents the student form")
        form.loadViewIfNeeded()
        form.nameField.text = "Noa"
        form.ageField.text = "19"

        form.save()

        XCTAssertEqual(store.students.count, 3, "Rule: saving valid input adds one student to the shared store")
        XCTAssertEqual(store.students.last?.name, "Noa", "Rule: the added student has the typed name")
        XCTAssertEqual(store.students.last?.age, 19, "Rule: the added student has the typed age")
        // numberOfRows is the table's own count; it changes only after a reload.
        XCTAssertEqual(list.tableView.numberOfRows(inSection: 0), 3, "Rule: the list shows the added student after saving (refresh)")
    }

    func testBlankNameShowsErrorAndKeepsStore() {
        let store = StudentStore(students: [zed, amy])
        let form = makeForm(store: store, name: "  ", age: "19")
        var saves = 0
        form.onSave = { saves += 1 }

        form.save()

        XCTAssertEqual(form.errorLabel.text, "Name must not be blank", "Rule: a blank name shows Name must not be blank")
        XCTAssertFalse(form.errorLabel.isHidden, "Rule: the error is visible")
        XCTAssertEqual(store.students, [zed, amy], "Rule: a rejected add does not change the store")
        XCTAssertEqual(saves, 0, "Rule: a rejected add does not report a save")
    }

    func testNonPositiveAgeShowsErrorAndKeepsStore() {
        let store = StudentStore(students: [zed, amy])
        let form = makeForm(store: store, name: "Noa", age: "0")

        form.save()

        XCTAssertEqual(form.errorLabel.text, "Age must be a positive whole number", "Rule: age 0 shows Age must be a positive whole number")
        XCTAssertEqual(store.students, [zed, amy], "Rule: a rejected add does not change the store")
    }

    func testNonNumericAgeShowsErrorAndKeepsStore() {
        let store = StudentStore(students: [zed, amy])

        // R-47, R-54: the age text must be a whole number exactly as typed.
        for age in ["abc", " 19", ""] {
            let form = makeForm(store: store, name: "Noa", age: age)
            form.save()
            XCTAssertEqual(form.errorLabel.text, "Age must be a positive whole number", "Rule: the age text \(age.debugDescription) shows Age must be a positive whole number")
        }

        XCTAssertEqual(store.students, [zed, amy], "Rule: a non-numeric age does not change the store")
    }

    func testNameIsSavedAsTyped() {
        let store = StudentStore(students: [zed, amy])
        let form = makeForm(store: store, name: "  Noa  ", age: "19")

        form.save()

        XCTAssertEqual(store.students.last?.name, "  Noa  ", "Rule: the form passes the name to the store as typed (R-48)")
    }

    func testCancelDoesNotChangeStore() {
        let store = StudentStore(students: [zed, amy])
        let form = makeForm(store: store, name: "Noa", age: "19")
        var saves = 0
        form.onSave = { saves += 1 }

        form.cancel()

        XCTAssertEqual(store.students, [zed, amy], "Rule: cancel never adds, even with valid input")
        XCTAssertEqual(saves, 0, "Rule: cancel does not report a save")
    }

    func testFormSupportsDynamicType() {
        let form = StudentFormViewController(store: StudentStore(students: [zed, amy]))
        form.loadViewIfNeeded()

        assertFieldFollowsDynamicType(form.nameField, "name field")
        assertFieldFollowsDynamicType(form.ageField, "age field")
        assertFollowsDynamicType(form.errorLabel, "form error label")
    }
}
