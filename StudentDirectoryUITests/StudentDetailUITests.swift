import XCTest

/// T3: opening the details and going back, as the user does it.
@MainActor
final class StudentDetailUITests: XCTestCase {
    func testTappingStudentOpensDetails() throws {
        let app = launchApp()
        let grace = app.cells["studentCell.00000000-0000-0000-0000-000000000003"]
        try waitOrFail(grace, rule: "the list shows Grace Hopper")

        grace.tap()

        try waitOrFail(app.otherElements["studentDetails"], rule: "tapping a row opens the screen identified as studentDetails")
        XCTAssertTrue(app.staticTexts["Grace Hopper"].exists, "Rule: the details show the tapped student")
    }

    func testBackReturnsToStudentsList() throws {
        let app = launchApp()
        let grace = app.cells["studentCell.00000000-0000-0000-0000-000000000003"]
        try waitOrFail(grace, rule: "the list shows Grace Hopper")
        grace.tap()
        try waitOrFail(app.otherElements["studentDetails"], rule: "the details screen opens")

        // The standard back button is identified as BackButton (PLAN fact 32).
        let back = app.navigationBars.buttons["BackButton"]
        try waitOrFail(back, rule: "the details screen has the standard back button")
        back.tap()

        try waitOrFail(app.navigationBars["Students"], rule: "the standard back button returns to the Students list")
        XCTAssertTrue(app.tables["studentList"].exists, "Rule: the list is shown again")
    }
}
