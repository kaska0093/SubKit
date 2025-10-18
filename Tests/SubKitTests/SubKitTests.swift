import XCTest
@testable import SubKit

final class SubscriptionParserTests: XCTestCase {
    func testParseHeaders() throws {
        let url = URL(string: "https://sub.example.com")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "profile-title": "VGVzdCBQcm9maWxl", // Base64: "Test Profile"
                "subscription-userinfo": "upload=1024; download=2147483648; total=10737418240; expire=1735689600",
                "profile-web-page-url": "https://example.com/profile",
                "support-url": "https://support.example.com",
                "profile-update-interval": "24",
                "providerid": "my-provider-01",
                "ping-type": "tcp"
            ]
        )!

        let info = parseHeaders(from: response)

        XCTAssertEqual(info.profileTitle, "Test Profile")
        XCTAssertEqual(info.uploadBytes, 1024)
        XCTAssertEqual(info.downloadGB, 2.0, accuracy: 0.01)
        XCTAssertEqual(info.totalBytes, 10_737_418_240)
        XCTAssertEqual(info.expireTimestamp, 1735689600)
        XCTAssertEqual(info.profileWebPageURL?.absoluteString, "https://example.com/profile")
        XCTAssertEqual(info.supportURL?.absoluteString, "https://support.example.com")
        XCTAssertEqual(info.profileUpdateIntervalHours, 24)
        XCTAssertEqual(info.providerID, "my-provider-01")
        XCTAssertEqual(info.pingType, "tcp")
    }

    func testEmptyHeaders() {
        let url = URL(string: "https://empty.com")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: [:])!
        let info = parseHeaders(from: response)

        XCTAssertEqual(info.profileTitle, "")
        XCTAssertEqual(info.uploadBytes, 0)
        XCTAssertEqual(info.downloadGB, 0.0)
        XCTAssertEqual(info.totalBytes, 0)
        XCTAssertNil(info.expireTimestamp)
        XCTAssertEqual(info.announce, "")
        XCTAssertNil(info.supportURL)
        XCTAssertNil(info.profileUpdateIntervalHours)
        XCTAssertEqual(info.providerID, "")
        XCTAssertEqual(info.pingType, "")
    }
}
