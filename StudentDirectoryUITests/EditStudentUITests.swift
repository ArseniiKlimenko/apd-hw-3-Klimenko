import XCTest

/// T6.3: editing a student from the details screen, as the user does it.
@MainActor
final class EditStudentUITests: XCTestCase {
    func testEditingStudentUpdatesDetailsAndList() throws {
        let app = launchApp()
        let grace = app.cells["studentCell.00000000-0000-0000-0000-000000000003"]
        try waitOrFail(grace, rule: "the list shows Grace Hopper")
        grace.tap()
        let edit = app.buttons["editStudentButton"]
        try waitOrFail(edit, rule: "the details screen has the editStudentButton")
        edit.tap()
        let name = app.textFields["studentNameField"]
        try waitOrFail(name, rule: "the edit button opens the form")

        name.tap()
        name.typeText(" Jr")
        app.buttons["saveStudentButton"].tap()

        try waitOrFail(app.navigationBars["Grace Hopper Jr"], rule: "after saving, the details title shows the new name")
        app.navigationBars.buttons["BackButton"].tap()
        try waitOrFail(app.navigationBars["Students"], rule: "back returns to the Students list")
        XCTAssertTrue(grace.label.hasPrefix("Grace Hopper Jr, age 22,"), "Rule: the list shows the edited name, got \(grace.label)")
    }
}
