import XCTest

/// T6.4: swipe to delete with confirmation, as the user does it (R-58).
@MainActor
final class DeleteStudentUITests: XCTestCase {
    func testConfirmedSwipeDeleteRemovesStudent() throws {
        let (app, grace) = try swipeDeleteGrace()

        app.alerts.buttons["Delete"].tap()

        try waitForDisappearanceOrFail(grace, rule: "a confirmed delete removes Grace Hopper from the list")
    }

    func testCancelledDeleteKeepsStudent() throws {
        let (app, grace) = try swipeDeleteGrace()

        app.alerts.buttons["Cancel"].tap()

        try waitForDisappearanceOrFail(app.alerts.firstMatch, rule: "Cancel closes the confirmation")
        XCTAssertTrue(grace.exists, "Rule: a cancelled delete keeps Grace Hopper in the list")
    }

    /// Students list -> swipe Grace Hopper -> Delete -> confirmation alert.
    private func swipeDeleteGrace() throws -> (XCUIApplication, XCUIElement) {
        let app = launchApp()
        let grace = app.cells["studentCell.00000000-0000-0000-0000-000000000003"]
        try waitOrFail(grace, rule: "the list shows Grace Hopper")
        grace.swipeLeft()
        let delete = app.buttons["Delete"]
        try waitOrFail(delete, rule: "swiping a row shows Delete")
        delete.tap()
        try waitOrFail(app.alerts["Delete Grace Hopper?"], rule: "Delete asks for confirmation naming Grace Hopper")
        return (app, grace)
    }
}
