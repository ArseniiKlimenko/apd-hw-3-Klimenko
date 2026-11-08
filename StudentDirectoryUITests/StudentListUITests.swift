import XCTest

/// T2: the list as the user sees it after launch.
@MainActor
final class StudentListUITests: XCTestCase {
    func testLaunchShowsStudentsList() throws {
        let app = launchApp()

        try waitOrFail(app.navigationBars["Students"], rule: "the first screen is titled Students")
        XCTAssertTrue(app.tables["studentList"].exists, "Rule: the list table is identified as studentList")
    }

    func testSeedStudentCellIsFoundByIdentifier() throws {
        let app = launchApp()
        let ada = app.cells["studentCell.00000000-0000-0000-0000-000000000001"]

        try waitOrFail(ada, rule: "the first seed student's cell is identified as studentCell.<id>")
        XCTAssertTrue(ada.label.contains("Ada Lovelace"), "Rule: the cell's accessibility label names the student, got \(ada.label)")
    }
}
