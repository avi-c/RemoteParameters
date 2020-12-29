import XCTest
@testable import RemoteParameters

final class RemoteParametersTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RemoteParameters().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
