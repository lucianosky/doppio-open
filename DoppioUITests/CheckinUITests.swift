// CheckinUITests.swift
// DoppioUITests
//
// Layer 2: Tests the check-in flow using -uitest_authenticated.
// Navigates to City tab → first shop → check-in form → submits.

import XCTest

final class CheckinUITests: UITestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        launchAuthenticated()
    }

    private func navigateToShopDetail() -> Bool {
        guard app.buttons["Cafés"].waitForExistence(timeout: 3) else { return false }
        app.buttons["Cafés"].tap()
        switchCityToListIfNeeded()

        let firstCell = app.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 10) else { return false }
        firstCell.tap()
        return true
    }

    func testCheckinButtonAppearsOnShopDetail() {
        guard navigateToShopDetail() else {
            XCTFail("Could not navigate to shop detail")
            return
        }

        XCTAssertTrue(
            app.buttons["shop_checkin_button"].waitForExistence(timeout: 5),
            "Check-in button must be visible on shop detail"
        )
    }

    func testCheckinFormOpens() {
        guard navigateToShopDetail() else {
            XCTFail("Could not navigate to shop detail")
            return
        }

        let checkinButton = app.buttons["shop_checkin_button"]
        XCTAssertTrue(checkinButton.waitForExistence(timeout: 5))
        checkinButton.tap()

        XCTAssertTrue(
            app.navigationBars["Check-in"].waitForExistence(timeout: 3),
            "Check-in screen must open after tapping the button"
        )
    }

    func testCheckinFirstVisitSelection() {
        guard navigateToShopDetail() else {
            XCTFail("Could not navigate to shop detail")
            return
        }

        let checkinButton = app.buttons["shop_checkin_button"]
        XCTAssertTrue(checkinButton.waitForExistence(timeout: 5))
        checkinButton.tap()

        XCTAssertTrue(app.navigationBars["Check-in"].waitForExistence(timeout: 3))

        let yesButton = app.buttons["checkin_first_visit_yes"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 3))
        yesButton.tap()

        let noButton = app.buttons["checkin_first_visit_no"]
        XCTAssertTrue(noButton.exists)
        noButton.tap()
    }

    func testCheckinSubmit() {
        guard navigateToShopDetail() else {
            XCTFail("Could not navigate to shop detail")
            return
        }

        let checkinButton = app.buttons["shop_checkin_button"]
        XCTAssertTrue(checkinButton.waitForExistence(timeout: 5))
        checkinButton.tap()

        XCTAssertTrue(app.navigationBars["Check-in"].waitForExistence(timeout: 3))

        let submitButton = app.buttons["checkin_submit_button"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 3))
        submitButton.tap()

        // Either success state or an error alert (network may be unavailable in CI)
        let successOrError = app.staticTexts["checkin_success_title"].waitForExistence(timeout: 8)
            || app.alerts.firstMatch.waitForExistence(timeout: 8)
        XCTAssertTrue(successOrError, "Check-in must show success or error after submit")
    }
}
