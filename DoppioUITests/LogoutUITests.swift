// LogoutUITests.swift
// DoppioUITests
//
// Layer 2: Tests the logout flow using -uitest_authenticated to inject a mock session.

import XCTest

final class LogoutUITests: UITestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        launchAuthenticated()
    }

    func testMainViewAppearsWhenAuthenticated() {
        XCTAssertTrue(
            app.buttons["Home"].waitForExistence(timeout: 3),
            "MainView must appear immediately when session is injected"
        )
    }

    func testProfileSheetOpens() {
        XCTAssertTrue(app.buttons["Home"].waitForExistence(timeout: 3))

        app.buttons["Perfil"].tap()

        XCTAssertTrue(
            app.navigationBars["Perfil"].waitForExistence(timeout: 3),
            "Profile sheet must open after tapping the profile button"
        )
    }

    func testLogoutReturnsToLoginScreen() {
        XCTAssertTrue(app.buttons["Home"].waitForExistence(timeout: 3))

        app.buttons["Perfil"].tap()
        XCTAssertTrue(app.navigationBars["Perfil"].waitForExistence(timeout: 3))

        let logoutButton = app.buttons["profile_logout_button"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 3))
        logoutButton.tap()

        XCTAssertTrue(
            app.buttons["login_explore_button"].waitForExistence(timeout: 3),
            "Login screen must appear after logout"
        )
    }
}
