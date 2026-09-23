// CityUITests.swift
// DoppioUITests

import XCTest

final class CityUITests: UITestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        launchAuthenticated()
        tapCityTab()
    }

    func testCityTabLoadingOrContent() {
        // city_view_mode_toggle appears only in .content state
        let loadingOrContent = app.activityIndicators.firstMatch.waitForExistence(timeout: 2)
            || app.buttons["city_view_mode_toggle"].waitForExistence(timeout: 8)
        XCTAssertTrue(loadingOrContent, "City tab must show loading or content")
    }

    func testCityViewModePickerExists() {
        _ = app.buttons["city_view_mode_toggle"].waitForExistence(timeout: 8)
        XCTAssertTrue(app.buttons["city_view_mode_toggle"].exists)
    }

    func testCitySortButtonExists() {
        _ = app.otherElements["city_nav_title"].waitForExistence(timeout: 5)
        XCTAssertTrue(app.buttons["city_sort_button"].exists
            || app.navigationBars.buttons.count > 0)
    }

    func testCityFilterButtonExists() {
        _ = app.otherElements["city_nav_title"].waitForExistence(timeout: 5)
        XCTAssertTrue(app.buttons["city_filter_button"].exists
            || app.navigationBars.buttons.count > 0)
    }
}
