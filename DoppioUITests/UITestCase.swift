// UITestCase.swift
// DoppioUITests

import XCTest

class UITestCase: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uitest_skip_splash", "-uitest_clear_session"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    // MARK: - Launch Helpers

    func launchAuthenticated() {
        app = XCUIApplication()
        app.launchArguments = ["-uitest_skip_splash", "-uitest_authenticated"]
        app.launch()
    }

    // MARK: - Tab Helpers (FloatingTabBar uses accessibilityLabel on TabPill)

    func tapHomeTab() {
        app.buttons["Home"].tap()
    }

    func tapCityTab() {
        app.buttons["Cafés"].tap()
    }

    /// Switches City to list mode if it opened in map mode.
    /// Call after tapping the Cafés tab and waiting for content to load.
    func switchCityToListIfNeeded() {
        let toggle = app.buttons["city_view_mode_toggle"]
        guard toggle.waitForExistence(timeout: 8) else { return }
        // accessibilityLabel is "Mudar para Lista" when in map mode
        if toggle.label == "Mudar para Lista" {
            toggle.tap()
        }
    }

    func tapBaristaTab() {
        app.buttons["Baristas"].tap()
    }

    // MARK: - Wait Helper

    @discardableResult
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        element.waitForExistence(timeout: timeout)
    }
}
