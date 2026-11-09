import XCTest

/// Thrown after `XCTFail` so a UI test stops at the first missing element.
struct MissingElement: Error {
    let rule: String
}

@MainActor
extension XCTestCase {
    /// A fresh app process, so every test starts from the seed store.
    func launchApp(arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = arguments
        app.launch()
        return app
    }

    /// R-4: waits only as a guard against a hanging test; it never measures time.
    /// R-27: 20 s after one repetition under load showed no window for 10 s.
    func waitOrFail(_ element: XCUIElement, rule: String, file: StaticString = #filePath, line: UInt = #line) throws {
        guard element.waitForExistence(timeout: 20) else {
            XCTFail("Rule: \(rule)", file: file, line: line)
            throw MissingElement(rule: rule)
        }
    }

    /// The opposite guard: waits (20 s at most) until `element` is gone.
    /// Uses `XCTNSPredicateExpectation`, which exists on Xcode 16.4 and 26.
    func waitForDisappearanceOrFail(_ element: XCUIElement, rule: String, file: StaticString = #filePath, line: UInt = #line) throws {
        let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: element)
        guard XCTWaiter().wait(for: [gone], timeout: 20) == .completed else {
            XCTFail("Rule: \(rule)", file: file, line: line)
            throw MissingElement(rule: rule)
        }
    }

    /// Cells whose accessibility label starts with `prefix` (new students have
    /// a random id, so they are found by name; grade text depends on locale).
    func cells(labelStartingWith prefix: String, in app: XCUIApplication) -> XCUIElementQuery {
        app.cells.matching(NSPredicate(format: "label BEGINSWITH %@", prefix))
    }
}
