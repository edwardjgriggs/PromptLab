import XCTest

final class PromptCoachUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    // MARK: - Onboarding

    func testOnboardingAppears() throws {
        // The welcome screen should be visible on first launch
        let welcome = app.staticTexts["Welcome to PromptCoach"]
        XCTAssertTrue(welcome.waitForExistence(timeout: 3), "Welcome text should appear on first launch")
    }

    func testOnboardingNextButtonExists() throws {
        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 3), "Next button should exist on onboarding")
    }

    func testCanNavigateThroughOnboarding() throws {
        // Page 1 -> 2
        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 3))
        nextButton.tap()

        // Should see category selection
        let categoryText = app.staticTexts["What will you use AI for?"]
        XCTAssertTrue(categoryText.waitForExistence(timeout: 3), "Category page should appear")
    }

    func testCompleteOnboardingFlow() throws {
        // Navigate through all pages
        let nextButton = app.buttons["Next"]

        // Page 1: Welcome -> Next
        XCTAssertTrue(nextButton.waitForExistence(timeout: 3))
        nextButton.tap()

        // Page 2: Categories -> Select one and Next
        let writingButton = app.buttons["Writing"]
        if writingButton.waitForExistence(timeout: 2) {
            writingButton.tap()
        }
        nextButton.tap()

        // Page 3: Verbosity -> Next
        nextButton.tap()

        // Page 4: Model -> Get Started
        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 3))
        getStartedButton.tap()

        // Should now see Home
        let homeTitle = app.navigationBars["PromptCoach"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 5), "Should navigate to Home after onboarding")
    }

    // MARK: - Home Screen

    func testHomeShowsTiles() throws {
        completeOnboarding()

        let generateTile = app.staticTexts["Generate a Prompt"]
        let assistantTile = app.staticTexts["Prompt Assistant"]
        let learnTile = app.staticTexts["Learn Prompting"]

        XCTAssertTrue(generateTile.waitForExistence(timeout: 3), "Generate tile should be visible")
        XCTAssertTrue(assistantTile.waitForExistence(timeout: 3), "Assistant tile should be visible")
        XCTAssertTrue(learnTile.waitForExistence(timeout: 3), "Learn tile should be visible")
    }

    // MARK: - Generator

    func testCanOpenGenerator() throws {
        completeOnboarding()

        let generateTile = app.staticTexts["Generate a Prompt"]
        XCTAssertTrue(generateTile.waitForExistence(timeout: 3))
        generateTile.tap()

        let categoryTitle = app.staticTexts["What type of prompt?"]
        XCTAssertTrue(categoryTitle.waitForExistence(timeout: 3), "Generator should open with category selection")
    }

    func testCanDismissGenerator() throws {
        completeOnboarding()

        let generateTile = app.staticTexts["Generate a Prompt"]
        XCTAssertTrue(generateTile.waitForExistence(timeout: 3))
        generateTile.tap()

        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 3))
        cancelButton.tap()

        // Should be back on Home
        let homeTile = app.staticTexts["Generate a Prompt"]
        XCTAssertTrue(homeTile.waitForExistence(timeout: 3))
    }

    // MARK: - Chat Coach

    func testCanOpenChatCoach() throws {
        completeOnboarding()

        let chatTile = app.staticTexts["Prompt Assistant"]
        XCTAssertTrue(chatTile.waitForExistence(timeout: 3))
        chatTile.tap()

        // Should see the greeting message
        let greeting = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Prompt Coach'"))
        XCTAssertTrue(greeting.firstMatch.waitForExistence(timeout: 3))
    }

    // MARK: - Tab Navigation

    func testTabBarNavigation() throws {
        completeOnboarding()

        // Navigate to Library
        let libraryTab = app.tabBars.buttons["Library"]
        XCTAssertTrue(libraryTab.waitForExistence(timeout: 3))
        libraryTab.tap()

        let libraryTitle = app.navigationBars["Library"]
        XCTAssertTrue(libraryTitle.waitForExistence(timeout: 3))

        // Navigate to Learn
        let learnTab = app.tabBars.buttons["Learn"]
        learnTab.tap()

        let learnTitle = app.navigationBars["Learn"]
        XCTAssertTrue(learnTitle.waitForExistence(timeout: 3))

        // Navigate to Settings
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3))
    }

    // MARK: - Helpers

    /// Complete onboarding by tapping through all pages.
    private func completeOnboarding() {
        let nextButton = app.buttons["Next"]
        if nextButton.waitForExistence(timeout: 2) {
            nextButton.tap()
            if nextButton.waitForExistence(timeout: 1) { nextButton.tap() }
            if nextButton.waitForExistence(timeout: 1) { nextButton.tap() }
            let getStarted = app.buttons["Get Started"]
            if getStarted.waitForExistence(timeout: 1) { getStarted.tap() }
        }
    }
}
