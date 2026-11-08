import XCTest

/// Thrown after `XCTFail` so a UI test stops at the first missing element.
struct MissingElement: Error {
    let rule: String
}

@MainActor
extension XCTestCase {
    /// A fresh app process, so every test starts from the seed store.
    func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    /// R-4: waits only as a guard against a hanging test; it never measures time.
    func waitOrFail(_ element: XCUIElement, rule: String, file: StaticString = #filePath, line: UInt = #line) throws {
        guard element.waitForExistence(timeout: 10) else {
            XCTFail("Rule: \(rule)", file: file, line: line)
            throw MissingElement(rule: rule)
        }
    }
}
