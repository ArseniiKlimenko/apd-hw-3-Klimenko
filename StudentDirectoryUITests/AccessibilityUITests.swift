import XCTest

/// T5: the real app at the largest Dynamic Type size (R-38, R-40, R-41).
@MainActor
final class AccessibilityUITests: XCTestCase {
    /// Only the raw value works; the long constant name is ignored silently
    /// and the app starts at the default size (PLAN fact 37).
    private let largestTextSize = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
    private let adaCellID = "studentCell.00000000-0000-0000-0000-000000000001"

    func testLargestTextSizeKeepsListDetailsAndFilterUsable() throws {
        // R-40: measure Ada's row at the default size first, so a launch
        // argument that did not apply cannot give a false green.
        let defaultApp = launchApp()
        let defaultAda = defaultApp.cells[adaCellID]
        try waitOrFail(defaultAda, rule: "the list shows Ada Lovelace at the default text size")
        let defaultHeight = defaultAda.frame.height
        defaultApp.terminate()

        let app = launchApp(arguments: largestTextSize)
        let ada = app.cells[adaCellID]
        try waitOrFail(ada, rule: "the list shows Ada Lovelace at the largest text size")
        XCTAssertGreaterThan(
            ada.frame.height, defaultHeight,
            "Rule: the largest text size makes the Ada row taller than the default size"
        )

        ada.tap()
        try waitOrFail(app.navigationBars["Ada Lovelace"], rule: "at the largest text size the Ada row opens Ada's details")
        let design = app.buttons["subjectButton.Design"]
        try waitOrFail(design, rule: "at the largest text size Ada's details show subjectButton.Design")
        // The button is below the screen; tap() scrolls to it (PLAN fact 38).
        // R-41: if it cannot scroll, XCUI fails with its own message, so the
        // rule is the name of this activity.
        XCTContext.runActivity(named: "Rule: at the largest text size the Design button can be scrolled to and tapped") { _ in
            design.tap()
        }
        try waitOrFail(app.navigationBars["Design"], rule: "at the largest text size the Design button opens the Design list")
        XCTAssertTrue(
            app.cells["studentCell.00000000-0000-0000-0000-000000000006"].exists,
            "Rule: at the largest text size the Design list shows Mary Jackson"
        )
    }
}
