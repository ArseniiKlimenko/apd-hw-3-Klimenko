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
}
