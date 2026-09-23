// AppLaunchTests.swift
// DoppioUITests

import XCTest

final class AppLaunchTests: UITestCase {

    func testAppLaunchesSuccessfully() {
        XCTAssertTrue(app.state == .runningForeground)
    }

    func testLoginScreenAppearsOnColdStart() {
        // Default launch has no session — LoginView must appear
        XCTAssertTrue(
            app.buttons["login_explore_button"].waitForExistence(timeout: 3),
            "Login screen must appear on cold start"
        )
    }

    func testFloatingTabBarAppearsAfterLogin() {
        // FloatingTabBar is a custom HStack, not a system tabBar
        let exploreButton = app.buttons["login_explore_button"]
        XCTAssertTrue(exploreButton.waitForExistence(timeout: 3))
        exploreButton.tap()

        XCTAssertTrue(app.buttons["Home"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Cafés"].exists)
        XCTAssertTrue(app.buttons["Baristas"].exists)
    }

    func testFloatingTabBarAppearsWhenAuthenticated() {
        launchAuthenticated()

        XCTAssertTrue(app.buttons["Home"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Cafés"].exists)
        XCTAssertTrue(app.buttons["Baristas"].exists)
    }
}
