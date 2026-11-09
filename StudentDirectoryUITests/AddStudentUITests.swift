import XCTest

/// T6.2: adding a student through the form, as the user does it.
@MainActor
final class AddStudentUITests: XCTestCase {
    func testAddingStudentShowsItInList() throws {
        let app = try openAddForm()

        app.textFields["studentNameField"].tap()
        app.textFields["studentNameField"].typeText("Noa Test")
        app.textFields["studentAgeField"].tap()
        app.textFields["studentAgeField"].typeText("19")
        app.buttons["saveStudentButton"].tap()

        try waitForDisappearanceOrFail(app.textFields["studentNameField"], rule: "a valid save closes the form")
        let added = cells(labelStartingWith: "Noa Test, age 19,", in: app).firstMatch
        try waitOrFail(added, rule: "the list shows the added student Noa Test")
        XCTAssertTrue(added.isHittable, "Rule: the list scrolls to the added student (R-52)")
    }

    func testInvalidInputShowsErrorAndKeepsForm() throws {
        let app = try openAddForm()

        app.textFields["studentAgeField"].tap()
        app.textFields["studentAgeField"].typeText("19")
        app.buttons["saveStudentButton"].tap()

        let error = app.staticTexts["studentFormError"]
        try waitOrFail(error, rule: "a blank name shows the form error")
        XCTAssertEqual(error.label, "Name must not be blank", "Rule: the form error says Name must not be blank")
        XCTAssertTrue(app.textFields["studentNameField"].exists, "Rule: the form stays open after invalid input")
    }

    func testCancelClosesFormWithoutAdding() throws {
        let app = try openAddForm()

        app.textFields["studentNameField"].tap()
        app.textFields["studentNameField"].typeText("Noa Test")
        app.buttons["cancelStudentButton"].tap()

        try waitForDisappearanceOrFail(app.textFields["studentNameField"], rule: "cancel closes the form")
        XCTAssertEqual(cells(labelStartingWith: "Noa Test,", in: app).count, 0, "Rule: cancel adds no student")
    }

    /// Students list -> add button -> empty form.
    private func openAddForm() throws -> XCUIApplication {
        let app = launchApp()
        let add = app.buttons["addStudentButton"]
        try waitOrFail(add, rule: "the Students list has the addStudentButton")
        add.tap()
        try waitOrFail(app.textFields["studentNameField"], rule: "the add button opens the form with studentNameField")
        return app
    }
}
