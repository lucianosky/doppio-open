// LoginUITests.swift
// DoppioUITests
//
// Layer 1: Tests the anonymous login path (Explorar cafés).
// Apple Sign-In cannot be automated in UI tests.

import XCTest

final class LoginUITests: UITestCase {

    // App launches showing LoginView (splash is skipped via -uitest_skip_splash,
    // session is not injected, so hasPassedLogin = false).

    func testLoginScreenIsShown() {
        XCTAssertTrue(
            app.buttons["login_explore_button"].waitForExistence(timeout: 3),
            "Login screen must appear on fresh launch"
        )
    }

    func testExploreButtonNavigatesToMainView() {
        let exploreButton = app.buttons["login_explore_button"]
        XCTAssertTrue(exploreButton.waitForExistence(timeout: 3))
        exploreButton.tap()

        // After tapping Explorar cafés the MainView appears with the floating tab bar
        XCTAssertTrue(
            app.buttons["Home"].waitForExistence(timeout: 3),
            "Main view with Home tab must appear after anonymous login"
        )
    }

    func testExploreButtonShowsCityTab() {
        let exploreButton = app.buttons["login_explore_button"]
        XCTAssertTrue(exploreButton.waitForExistence(timeout: 3))
        exploreButton.tap()

        XCTAssertTrue(app.buttons["Cafés"].waitForExistence(timeout: 3))
        app.buttons["Cafés"].tap()

        // City tab loaded — view mode toggle only appears in .content state
        XCTAssertTrue(
            app.buttons["city_view_mode_toggle"].waitForExistence(timeout: 8),
            "City tab must show content or loading after anonymous login"
        )
    }
}
