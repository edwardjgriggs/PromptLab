import XCTest
@testable import PromptCoach

final class CoachEngineTests: XCTestCase {

    // MARK: - Initialization

    func testInitialStateIsGatherGoal() {
        let engine = CoachEngine()
        XCTAssertEqual(engine.currentState, .gatherGoal)
    }

    func testInitialMessageIsCoachGreeting() {
        let engine = CoachEngine()
        XCTAssertEqual(engine.messages.count, 1)
        XCTAssertEqual(engine.messages.first?.role, .coach)
        XCTAssertTrue(engine.messages.first?.text.contains("Prompt Coach") ?? false)
    }

    func testIsNotCompleteOnInit() {
        let engine = CoachEngine()
        XCTAssertFalse(engine.isComplete)
        XCTAssertNil(engine.generatedPrompt)
    }

    // MARK: - State Transitions

    func testSendingGoalTransitionsToGatherContext() {
        let engine = CoachEngine()
        engine.send("Write a cover letter for a marketing role")

        XCTAssertEqual(engine.currentState, .gatherContext)
        // Should have: greeting, user message, coach response
        XCTAssertEqual(engine.messages.count, 3)
    }

    func testSendingContextTransitionsToGatherAudience() {
        let engine = CoachEngine()
        engine.send("Write a cover letter")
        engine.send("I have 5 years of experience in digital marketing")

        XCTAssertEqual(engine.currentState, .gatherAudience)
    }

    func testSkippingContextWorks() {
        let engine = CoachEngine()
        engine.send("Write a cover letter")
        engine.send("skip")

        XCTAssertEqual(engine.currentState, .gatherAudience)
    }

    func testSendingAudienceTransitionsToGatherConstraints() {
        let engine = CoachEngine()
        engine.send("Write a cover letter")
        engine.send("5 years experience")
        engine.send("Hiring manager at a tech startup")

        XCTAssertEqual(engine.currentState, .gatherConstraints)
    }

    func testSkippingAudienceWorks() {
        let engine = CoachEngine()
        engine.send("Write a cover letter")
        engine.send("Context here")
        engine.send("skip")

        XCTAssertEqual(engine.currentState, .gatherConstraints)
    }

    func testSendingConstraintsGeneratesPrompt() {
        let engine = CoachEngine()
        engine.send("Write a cover letter")
        engine.send("5 years experience")
        engine.send("Hiring manager")
        engine.send("Keep it under 300 words")

        XCTAssertEqual(engine.currentState, .generatePrompt)
        XCTAssertTrue(engine.isComplete)
        XCTAssertNotNil(engine.generatedPrompt)
    }

    func testSkippingConstraintsStillGenerates() {
        let engine = CoachEngine()
        engine.send("Write a cover letter")
        engine.send("skip")
        engine.send("skip")
        engine.send("skip")

        XCTAssertTrue(engine.isComplete)
        XCTAssertNotNil(engine.generatedPrompt)
    }

    // MARK: - Generated Prompt Quality

    func testGeneratedPromptContainsGoal() {
        let engine = CoachEngine()
        engine.send("Explain quantum computing to a teenager")
        engine.send("skip")
        engine.send("skip")
        engine.send("skip")

        XCTAssertTrue(
            engine.generatedPrompt?.contains("quantum computing") ?? false,
            "Generated prompt should contain the goal"
        )
    }

    func testGeneratedPromptContainsContext() {
        let engine = CoachEngine()
        engine.send("Write a proposal")
        engine.send("The project is about building a mobile app")
        engine.send("skip")
        engine.send("skip")

        XCTAssertTrue(
            engine.generatedPrompt?.contains("mobile app") ?? false,
            "Generated prompt should contain the context"
        )
    }

    func testVariantsAreGenerated() {
        let engine = CoachEngine()
        engine.send("Write a blog post")
        engine.send("skip")
        engine.send("skip")
        engine.send("skip")

        XCTAssertEqual(engine.variants.count, 3, "Should generate 3 variants")
    }

    // MARK: - Refinement

    func testRefinementUpdatesPrompt() {
        let engine = CoachEngine()
        engine.send("Write a summary")
        engine.send("skip")
        engine.send("skip")
        engine.send("skip")

        let originalPrompt = engine.generatedPrompt
        engine.applyRefinement(.moreFormal)

        XCTAssertNotEqual(engine.generatedPrompt, originalPrompt, "Prompt should change after refinement")
    }

    func testFreeformRefinementAfterGeneration() {
        let engine = CoachEngine()
        engine.send("Write an email")
        engine.send("skip")
        engine.send("skip")
        engine.send("skip")

        let messageCountBefore = engine.messages.count
        engine.send("Make it shorter and more concise")

        XCTAssertTrue(engine.messages.count > messageCountBefore, "Should add new messages for refinement")
    }

    // MARK: - Reset

    func testResetClearsEverything() {
        let engine = CoachEngine()
        engine.send("Write something")
        engine.send("Context")
        engine.send("Audience")
        engine.send("Constraints")

        engine.reset()

        XCTAssertEqual(engine.currentState, .gatherGoal)
        XCTAssertEqual(engine.messages.count, 1) // Just the greeting
        XCTAssertNil(engine.generatedPrompt)
        XCTAssertTrue(engine.variants.isEmpty)
        XCTAssertFalse(engine.isComplete)
    }

    // MARK: - Message Tracking

    func testUserMessagesAreRecorded() {
        let engine = CoachEngine()
        engine.send("Write a poem")

        let userMessages = engine.messages.filter { $0.role == .user }
        XCTAssertEqual(userMessages.count, 1)
        XCTAssertEqual(userMessages.first?.text, "Write a poem")
    }

    func testEmptyMessagesAreIgnored() {
        let engine = CoachEngine()
        let initialCount = engine.messages.count
        engine.send("")
        engine.send("   ")

        XCTAssertEqual(engine.messages.count, initialCount, "Empty messages should be ignored")
    }

    // MARK: - Full Flow

    func testFullConversationFlow() {
        let engine = CoachEngine()

        // Step 1: Goal
        XCTAssertEqual(engine.currentState, .gatherGoal)
        engine.send("Create a weekly meal plan for a vegetarian")

        // Step 2: Context
        XCTAssertEqual(engine.currentState, .gatherContext)
        engine.send("Budget of $50/week, cooking for one person")

        // Step 3: Audience
        XCTAssertEqual(engine.currentState, .gatherAudience)
        engine.send("Just for me, a college student")

        // Step 4: Constraints
        XCTAssertEqual(engine.currentState, .gatherConstraints)
        engine.send("No more than 30 minutes per meal, use bullet points")

        // Final state
        XCTAssertTrue(engine.isComplete)
        XCTAssertNotNil(engine.generatedPrompt)

        let prompt = engine.generatedPrompt!
        XCTAssertTrue(prompt.contains("meal plan"), "Should contain goal keywords")
        XCTAssertTrue(prompt.contains("vegetarian") || prompt.contains("Vegetarian"), "Should contain goal specifics")
        XCTAssertEqual(engine.variants.count, 3)
    }
}
