import XCTest
@testable import PromptCoach

final class PromptEngineTests: XCTestCase {

    private let engine = PromptEngine()

    // MARK: - Basic Generation

    func testGenerateProducesNonEmptyPrompt() {
        var answers = GeneratorAnswers()
        answers.goal = "Write a blog post about Swift concurrency"
        answers.category = .coding

        let result = engine.generate(from: answers)

        XCTAssertFalse(result.finalPrompt.isEmpty, "Final prompt should not be empty")
    }

    func testGenerateIncludesGoalInPrompt() {
        var answers = GeneratorAnswers()
        answers.goal = "Explain photosynthesis to a 10-year-old"
        answers.category = .school

        let result = engine.generate(from: answers)

        XCTAssertTrue(
            result.finalPrompt.contains("Explain photosynthesis to a 10-year-old"),
            "Prompt should contain the user's goal"
        )
    }

    // MARK: - Sections Appear When Provided

    func testContextAppearsWhenProvided() {
        var answers = GeneratorAnswers()
        answers.goal = "Summarize the article"
        answers.context = "The article is about renewable energy trends in 2024"

        let result = engine.generate(from: answers)

        XCTAssertTrue(
            result.finalPrompt.contains("renewable energy trends"),
            "Prompt should include the context"
        )
    }

    func testAudienceAppearsWhenProvided() {
        var answers = GeneratorAnswers()
        answers.goal = "Write a summary"
        answers.audience = "C-level executives"

        let result = engine.generate(from: answers)

        XCTAssertTrue(
            result.finalPrompt.contains("C-level executives"),
            "Prompt should include the audience"
        )
    }

    func testToneAlwaysAppears() {
        var answers = GeneratorAnswers()
        answers.goal = "Draft an email"
        answers.tone = .formal

        let result = engine.generate(from: answers)

        XCTAssertTrue(
            result.finalPrompt.contains("Formal"),
            "Prompt should include the tone"
        )
    }

    func testConstraintsAppearWhenProvided() {
        var answers = GeneratorAnswers()
        answers.goal = "Write a product description"
        answers.lengthConstraint = "Under 100 words"
        answers.mustInclude = "price and availability"
        answers.mustAvoid = "jargon"

        let result = engine.generate(from: answers)

        XCTAssertTrue(result.finalPrompt.contains("Under 100 words"), "Should include length constraint")
        XCTAssertTrue(result.finalPrompt.contains("price and availability"), "Should include must-include")
        XCTAssertTrue(result.finalPrompt.contains("jargon"), "Should include must-avoid")
    }

    func testOutputFormatAppearsWhenNotFreeform() {
        var answers = GeneratorAnswers()
        answers.goal = "List marketing ideas"
        answers.outputFormat = .bullets

        let result = engine.generate(from: answers)

        XCTAssertTrue(
            result.finalPrompt.contains("Bullet points"),
            "Prompt should specify the output format"
        )
    }

    func testOutputFormatOmittedWhenFreeform() {
        var answers = GeneratorAnswers()
        answers.goal = "Write a story"
        answers.outputFormat = .freeform

        let result = engine.generate(from: answers)

        XCTAssertFalse(
            result.finalPrompt.contains("Output Format"),
            "Freeform should not produce an Output Format section"
        )
    }

    func testExamplesAppearWhenProvided() {
        var answers = GeneratorAnswers()
        answers.goal = "Rewrite sentences"
        answers.exampleInput = "This is bad writing."
        answers.exampleOutput = "This is improved writing."

        let result = engine.generate(from: answers)

        XCTAssertTrue(result.finalPrompt.contains("This is bad writing"), "Should include example input")
        XCTAssertTrue(result.finalPrompt.contains("This is improved writing"), "Should include example output")
    }

    func testClarifyingQuestionsToggle() {
        var answers = GeneratorAnswers()
        answers.goal = "Help me plan a project"
        answers.askClarifyingQuestions = true

        let result = engine.generate(from: answers)

        XCTAssertTrue(
            result.finalPrompt.lowercased().contains("clarifying questions"),
            "Should include clarifying questions instruction"
        )
    }

    func testCiteSourcesToggle() {
        var answers = GeneratorAnswers()
        answers.goal = "Research renewable energy"
        answers.askForSources = true

        let result = engine.generate(from: answers)

        XCTAssertTrue(
            result.finalPrompt.lowercased().contains("cite sources"),
            "Should include citation instruction"
        )
    }

    // MARK: - Sections Omitted When Empty

    func testContextOmittedWhenEmpty() {
        var answers = GeneratorAnswers()
        answers.goal = "Write something"
        answers.context = ""

        let result = engine.generate(from: answers)

        XCTAssertFalse(
            result.finalPrompt.contains("**Context:**"),
            "Context section should not appear when empty"
        )
    }

    func testExamplesOmittedWhenEmpty() {
        var answers = GeneratorAnswers()
        answers.goal = "Write something"
        answers.exampleInput = ""
        answers.exampleOutput = ""

        let result = engine.generate(from: answers)

        XCTAssertFalse(
            result.finalPrompt.contains("**Examples:**"),
            "Examples section should not appear when empty"
        )
    }

    // MARK: - Variants

    func testGeneratesThreeVariants() {
        var answers = GeneratorAnswers()
        answers.goal = "Write a blog post"

        let result = engine.generate(from: answers)

        XCTAssertEqual(result.variants.count, 3, "Should generate exactly 3 variants")
    }

    func testVariantLabelsAreDistinct() {
        var answers = GeneratorAnswers()
        answers.goal = "Draft an email"

        let result = engine.generate(from: answers)
        let labels = Set(result.variants.map(\.label))

        XCTAssertEqual(labels.count, 3, "All variant labels should be unique")
    }

    func testVariantsContainExpectedLabels() {
        var answers = GeneratorAnswers()
        answers.goal = "Write a report"

        let result = engine.generate(from: answers)
        let labels = result.variants.map(\.label)

        XCTAssertTrue(labels.contains("Concise"), "Should have a Concise variant")
        XCTAssertTrue(labels.contains("Detailed"), "Should have a Detailed variant")
        XCTAssertTrue(labels.contains("Strict Format"), "Should have a Strict Format variant")
    }

    func testVariantBodiesAreNonEmpty() {
        var answers = GeneratorAnswers()
        answers.goal = "Create a study plan"

        let result = engine.generate(from: answers)

        for variant in result.variants {
            XCTAssertFalse(variant.body.isEmpty, "Variant '\(variant.label)' body should not be empty")
        }
    }

    // MARK: - Explanation

    func testExplanationIsNonEmpty() {
        var answers = GeneratorAnswers()
        answers.goal = "Write a cover letter"

        let result = engine.generate(from: answers)

        XCTAssertFalse(result.explanation.isEmpty, "Explanation should not be empty")
    }

    func testExplanationMentionsStructure() {
        var answers = GeneratorAnswers()
        answers.goal = "Draft a proposal"

        let result = engine.generate(from: answers)

        XCTAssertTrue(
            result.explanation.lowercased().contains("structure") || result.explanation.lowercased().contains("role"),
            "Explanation should mention prompt structure"
        )
    }

    // MARK: - Role Section

    func testWritingCategoryGetsWriterRole() {
        var answers = GeneratorAnswers()
        answers.goal = "Write a blog"
        answers.category = .writing

        let result = engine.generate(from: answers)

        XCTAssertTrue(
            result.finalPrompt.lowercased().contains("writer"),
            "Writing category should include a writer role"
        )
    }

    func testCodingCategoryGetsEngineerRole() {
        var answers = GeneratorAnswers()
        answers.goal = "Review code"
        answers.category = .coding

        let result = engine.generate(from: answers)

        XCTAssertTrue(
            result.finalPrompt.lowercased().contains("engineer"),
            "Coding category should include an engineer role"
        )
    }

    func testCustomCategoryOmitsRole() {
        var answers = GeneratorAnswers()
        answers.goal = "Do something custom"
        answers.category = .custom

        let result = engine.generate(from: answers)

        // Custom should not have a role like "writer" or "engineer"
        XCTAssertFalse(
            result.finalPrompt.contains("You are"),
            "Custom category should not include a role section"
        )
    }

    // MARK: - Edge Cases

    func testWhitespaceOnlyFieldsTreatedAsEmpty() {
        var answers = GeneratorAnswers()
        answers.goal = "Write something"
        answers.context = "   "
        answers.audience = "  \n  "

        let result = engine.generate(from: answers)

        XCTAssertFalse(result.finalPrompt.contains("**Context:**"), "Whitespace-only context should be treated as empty")
        XCTAssertFalse(result.finalPrompt.contains("**Audience:**"), "Whitespace-only audience should be treated as empty")
    }
}
