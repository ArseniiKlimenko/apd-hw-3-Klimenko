import XCTest

/// T4: from a student's subject to the filtered list, as the user does it.
@MainActor
final class SubjectFilterUITests: XCTestCase {
    func testSubjectButtonOpensFilteredList() throws {
        let app = try openDesignListFromAda()

        for id in ["01", "06", "08", "09"] {
            XCTAssertTrue(
                app.cells["studentCell.00000000-0000-0000-0000-0000000000\(id)"].exists,
                "Rule: the Design list shows student \(id), who has Design"
            )
        }
        // Cells of earlier screens are gone from the tree after a push (PLAN fact 36).
        XCTAssertFalse(
            app.cells["studentCell.00000000-0000-0000-0000-000000000002"].exists,
            "Rule: the Design list hides Alan Turing, who has no Design"
        )
    }

    func testFilteredListRowOpensCorrectDetails() throws {
        let app = try openDesignListFromAda()

        app.cells["studentCell.00000000-0000-0000-0000-000000000006"].tap()

        try waitOrFail(app.navigationBars["Mary Jackson"], rule: "a row of the Design list opens that student's details")
        XCTAssertTrue(app.otherElements["studentDetails"].exists, "Rule: the opened screen is the details screen")
    }

    /// List -> Ada Lovelace -> subject Design.
    private func openDesignListFromAda() throws -> XCUIApplication {
        let app = launchApp()
        let ada = app.cells["studentCell.00000000-0000-0000-0000-000000000001"]
        try waitOrFail(ada, rule: "the list shows Ada Lovelace")
        ada.tap()
        let design = app.buttons["subjectButton.Design"]
        try waitOrFail(design, rule: "Ada's details show the subject button subjectButton.Design")
        design.tap()
        try waitOrFail(app.navigationBars["Design"], rule: "the subject button opens a list titled Design")
        return app
    }
}
