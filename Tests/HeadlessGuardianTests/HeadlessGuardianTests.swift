import XCTest
@testable import HeadlessGuardian

final class HeadlessGuardianTests: XCTestCase {

    // MARK: - detectLaunchMode

    func testDetectLaunchMode_headlessFlagPresent() {
        XCTAssertTrue(detectLaunchMode(args: ["MyApp", "--headless"]))
    }

    func testDetectLaunchMode_headlessFlagAbsent() {
        XCTAssertFalse(detectLaunchMode(args: ["MyApp", "--opacity"]))
    }

    func testDetectLaunchMode_emptyArgs() {
        XCTAssertFalse(detectLaunchMode(args: []))
    }

    func testDetectLaunchMode_wrongCase() {
        XCTAssertFalse(detectLaunchMode(args: ["MyApp", "--Headless"]))
    }

    // MARK: - parsePort

    func testParsePort_validPort() {
        XCTAssertEqual(parsePort(from: ["app", "--port", "9090"]), 9090)
    }

    func testParsePort_flagPresentNoValue() {
        XCTAssertEqual(parsePort(from: ["app", "--port"]), 8547)
    }

    func testParsePort_nonNumericValue() {
        XCTAssertEqual(parsePort(from: ["app", "--port", "abc"]), 8547)
    }

    func testParsePort_boundaryLow() {
        XCTAssertEqual(parsePort(from: ["app", "--port", "0"]), 0)
    }

    func testParsePort_boundaryHigh() {
        XCTAssertEqual(parsePort(from: ["app", "--port", "65535"]), 65535)
    }

    func testParsePort_uint16Overflow() {
        XCTAssertEqual(parsePort(from: ["app", "--port", "99999"]), 8547)
    }

    func testParsePort_flagAbsent() {
        XCTAssertEqual(parsePort(from: ["app", "--headless"]), 8547)
    }

    func testParsePort_customDefault() {
        XCTAssertEqual(parsePort(from: [], default: 1234), 1234)
    }

    // MARK: - rotateLogsIfNeeded

    func testRotateLogs_nonexistentFile_noError() {
        // Should return silently without crashing when file does not exist
        rotateLogsIfNeeded(logPath: "/tmp/guardian_test_nonexistent_\(UUID().uuidString).log")
    }

    func testRotateLogs_smallFile_noRotation() throws {
        let path = "/tmp/guardian_test_small_\(UUID().uuidString).log"
        let content = Data("hello\n".utf8)
        try content.write(to: URL(fileURLWithPath: path))
        defer { try? FileManager.default.removeItem(atPath: path) }

        let statBefore = try FileManager.default.attributesOfItem(atPath: path)
        let sizeBefore = statBefore[.size] as? Int

        rotateLogsIfNeeded(logPath: path)

        let statAfter = try FileManager.default.attributesOfItem(atPath: path)
        let sizeAfter = statAfter[.size] as? Int

        // File should be unchanged — no rotation triggered for small files
        XCTAssertEqual(sizeBefore, sizeAfter)
    }
}
