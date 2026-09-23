// RatingUITests.swift
// DoppioUITests
//
// Layer 2: Tests the rating flow using -uitest_authenticated.
// Navigates to City tab → first shop → rating form → selects stars → submits.

import XCTest

final class RatingUITests: UITestCase {

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

    private func openRatingForm() -> Bool {
        guard navigateToShopDetail() else { return false }

        let ratingButton = app.buttons["shop_rating_button"]
        guard ratingButton.waitForExistence(timeout: 5) else { return false }

        // Rating button may be below the fold — scroll to it
        ratingButton.tap()
        return app.navigationBars["Avaliação"].waitForExistence(timeout: 3)
    }

    func testRatingButtonAppearsOnShopDetail() {
        guard navigateToShopDetail() else {
            XCTFail("Could not navigate to shop detail")
            return
        }

        XCTAssertTrue(
            app.buttons["shop_rating_button"].waitForExistence(timeout: 5),
            "Rating button must be visible on shop detail"
        )
    }

    func testRatingFormOpens() {
        guard navigateToShopDetail() else {
            XCTFail("Could not navigate to shop detail")
            return
        }

        let ratingButton = app.buttons["shop_rating_button"]
        XCTAssertTrue(ratingButton.waitForExistence(timeout: 5))
        ratingButton.tap()

        XCTAssertTrue(
            app.navigationBars["Avaliação"].waitForExistence(timeout: 3),
            "Rating screen must open after tapping the button"
        )
    }

    func testRatingStarsExist() {
        guard openRatingForm() else {
            XCTFail("Could not open rating form")
            return
        }

        for star in 1...5 {
            XCTAssertTrue(
                app.images["rating_star_\(star)"].waitForExistence(timeout: 3),
                "Star \(star) must be visible in rating form"
            )
        }
    }

    func testRatingStarTapEnablesSubmit() {
        guard openRatingForm() else {
            XCTFail("Could not open rating form")
            return
        }

        // Submit button is disabled until at least 1 star is selected
        let submitButton = app.buttons["rating_submit_button"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 3))
        XCTAssertFalse(submitButton.isEnabled, "Submit must be disabled before star selection")

        app.images["rating_star_4"].tap()

        XCTAssertTrue(submitButton.isEnabled, "Submit must be enabled after selecting a star")
    }

    func testRatingSubmit() {
        guard openRatingForm() else {
            XCTFail("Could not open rating form")
            return
        }

        app.images["rating_star_5"].tap()

        let submitButton = app.buttons["rating_submit_button"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 3))
        XCTAssertTrue(submitButton.isEnabled)
        submitButton.tap()

        // Either success state or an error alert (network may be unavailable in CI)
        let successOrError = app.staticTexts["rating_success_title"].waitForExistence(timeout: 8)
            || app.alerts.firstMatch.waitForExistence(timeout: 8)
        XCTAssertTrue(successOrError, "Rating must show success or error after submit")
    }
}
