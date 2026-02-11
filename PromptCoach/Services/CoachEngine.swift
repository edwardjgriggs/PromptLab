import Foundation

/// State machine-based coaching engine for the Prompt Assistant chat.
/// Operates entirely offline using rule-based logic and templates.
final class CoachEngine: ObservableObject {

    // MARK: - State Machine

    enum State: String {
        case gatherGoal
        case gatherContext
        case gatherAudience
        case gatherConstraints
        case generatePrompt
        case refine
    }

    struct Message: Identifiable, Equatable {
        let id: UUID
        let role: MessageRole
        let text: String
        let timestamp: Date

        init(role: MessageRole, text: String) {
            self.id = UUID()
            self.role = role
            self.text = text
            self.timestamp = Date()
        }
    }

    enum MessageRole: String {
        case coach
        case user
    }

    // MARK: - Published Properties

    @Published private(set) var messages: [Message] = []
    @Published private(set) var currentState: State = .gatherGoal
    @Published private(set) var generatedPrompt: String?
    @Published private(set) var variants: [VariantResult] = []
    @Published private(set) var isComplete: Bool = false

    // MARK: - Gathered Data

    private var goal: String = ""
    private var context: String = ""
    private var audience: String = ""
    private var constraints: String = ""
    private var refinements: [String] = []

    private let promptEngine = PromptEngine()

    // MARK: - Initialization

    init() {
        addCoachMessage(initialGreeting)
    }

    // MARK: - Public API

    /// Process a user message and advance the state machine.
    func send(_ text: String) {
        let trimmed = text.trimmed
        guard !trimmed.isEmpty else { return }

        addUserMessage(trimmed)
        processInput(trimmed)
    }

    /// Apply a refinement toggle (e.g., "More specific").
    func applyRefinement(_ refinement: RefinementOption) {
        refinements.append(refinement.rawValue)
        addUserMessage("Make it \(refinement.label.lowercased())")
        regenerateWithRefinement(refinement)
    }

    /// Reset the engine to start a new conversation.
    func reset() {
        messages = []
        currentState = .gatherGoal
        generatedPrompt = nil
        variants = []
        isComplete = false
        goal = ""
        context = ""
        audience = ""
        constraints = ""
        refinements = []
        addCoachMessage(initialGreeting)
    }

    // MARK: - State Transitions

    private func processInput(_ input: String) {
        switch currentState {
        case .gatherGoal:
            goal = input
            currentState = .gatherContext
            addCoachMessage("Got it — you want to: \"\(goal)\"\n\nNow, what background information does the AI need to know? For example, any relevant details, data, or situation context.\n\n(Type \"skip\" if there's no extra context needed.)")

        case .gatherContext:
            if input.lowercased() != "skip" {
                context = input
            }
            currentState = .gatherAudience
            addCoachMessage("Who is the intended audience for this output? (e.g., \"my manager\", \"a 5th grader\", \"technical developers\")\n\n(Type \"skip\" to leave this open.)")

        case .gatherAudience:
            if input.lowercased() != "skip" {
                audience = input
            }
            currentState = .gatherConstraints
            addCoachMessage("Any constraints I should know about?\n\nFor example:\n- Length (\"keep it under 200 words\")\n- Things to include or avoid\n- A specific format (bullet points, table, etc.)\n\n(Type \"skip\" for no constraints, or describe what you need.)")

        case .gatherConstraints:
            if input.lowercased() != "skip" {
                constraints = input
            }
            currentState = .generatePrompt
            generatePrompt()

        case .generatePrompt, .refine:
            // User is providing free-form feedback for refinement
            currentState = .refine
            handleFreeformRefinement(input)
        }
    }

    // MARK: - Prompt Generation

    private func generatePrompt() {
        let answers = buildAnswers()
        let result = promptEngine.generate(from: answers)

        generatedPrompt = result.finalPrompt
        variants = result.variants

        var response = "Here's your polished prompt:\n\n---\n\n\(result.finalPrompt)\n\n---\n\n"
        response += "**Why this works:** \(result.explanation.components(separatedBy: "\n\n").first ?? "")\n\n"
        response += "You can copy this prompt, save it, or use the refinement options below to adjust it. You can also type feedback directly."

        isComplete = true
        addCoachMessage(response)
    }

    private func regenerateWithRefinement(_ refinement: RefinementOption) {
        var answers = buildAnswers()

        switch refinement {
        case .moreSpecific:
            if answers.context.isEmpty {
                answers.context = "Be very specific and precise in your response."
            } else {
                answers.context += " Be very specific and precise."
            }
            answers.lengthConstraint = answers.lengthConstraint.isEmpty ? "Detailed with specifics" : answers.lengthConstraint

        case .moreCreative:
            answers.tone = .friendly
            answers.mustInclude = answers.mustInclude.isEmpty
                ? "Creative and original ideas"
                : answers.mustInclude + "; creative and original ideas"

        case .moreFormal:
            answers.tone = .formal

        case .addConstraints:
            answers.askClarifyingQuestions = true
            if answers.mustAvoid.isEmpty {
                answers.mustAvoid = "Vague or generic responses"
            }

        case .addExamples:
            answers.askClarifyingQuestions = true
            if answers.exampleInput.isEmpty {
                answers.exampleInput = "[User would provide a sample input here]"
            }
        }

        let result = promptEngine.generate(from: answers)
        generatedPrompt = result.finalPrompt
        variants = result.variants

        addCoachMessage("Here's the updated prompt with your refinement applied:\n\n---\n\n\(result.finalPrompt)\n\n---\n\nFeel free to copy, save, or refine further.")
    }

    private func handleFreeformRefinement(_ feedback: String) {
        // Incorporate user feedback by adjusting constraints
        let lowerFeedback = feedback.lowercased()

        if lowerFeedback.contains("shorter") || lowerFeedback.contains("concise") || lowerFeedback.contains("brief") {
            applyRefinement(.moreSpecific)
            return
        }
        if lowerFeedback.contains("formal") || lowerFeedback.contains("professional") {
            applyRefinement(.moreFormal)
            return
        }
        if lowerFeedback.contains("creative") || lowerFeedback.contains("fun") || lowerFeedback.contains("playful") {
            applyRefinement(.moreCreative)
            return
        }

        // General feedback — add as constraint and regenerate
        if !constraints.isEmpty {
            constraints += "; \(feedback)"
        } else {
            constraints = feedback
        }

        let answers = buildAnswers()
        let result = promptEngine.generate(from: answers)
        generatedPrompt = result.finalPrompt
        variants = result.variants

        addCoachMessage("I've incorporated your feedback. Here's the updated prompt:\n\n---\n\n\(result.finalPrompt)\n\n---")
    }

    // MARK: - Helpers

    private func buildAnswers() -> GeneratorAnswers {
        var answers = GeneratorAnswers()
        answers.goal = goal
        answers.context = context
        answers.audience = audience
        answers.category = .custom

        // Parse constraints
        let lower = constraints.lowercased()
        if lower.contains("bullet") {
            answers.outputFormat = .bullets
        } else if lower.contains("table") {
            answers.outputFormat = .table
        } else if lower.contains("step") {
            answers.outputFormat = .stepByStep
        } else if lower.contains("number") {
            answers.outputFormat = .numbered
        }

        // Extract length constraints
        if lower.contains("word") || lower.contains("short") || lower.contains("long") || lower.contains("brief") {
            answers.lengthConstraint = constraints
        } else if !constraints.isEmpty {
            answers.formatConstraint = constraints
        }

        return answers
    }

    private func addCoachMessage(_ text: String) {
        messages.append(Message(role: .coach, text: text))
    }

    private func addUserMessage(_ text: String) {
        messages.append(Message(role: .user, text: text))
    }

    // MARK: - Static Content

    private var initialGreeting: String {
        """
        Hi! I'm your Prompt Coach. I'll help you build a great prompt step by step.

        Let's start: **What do you want the AI to do?**

        For example:
        - "Write a cover letter for a marketing job"
        - "Explain quantum computing to a teenager"
        - "Create a weekly meal plan for a vegetarian"
        """
    }
}

// MARK: - Refinement Options

enum RefinementOption: String, CaseIterable, Identifiable {
    case moreSpecific
    case moreCreative
    case moreFormal
    case addConstraints
    case addExamples

    var id: String { rawValue }

    var label: String {
        switch self {
        case .moreSpecific: return "More Specific"
        case .moreCreative: return "More Creative"
        case .moreFormal: return "More Formal"
        case .addConstraints: return "Add Constraints"
        case .addExamples: return "Add Examples"
        }
    }

    var icon: String {
        switch self {
        case .moreSpecific: return "scope"
        case .moreCreative: return "sparkles"
        case .moreFormal: return "briefcase"
        case .addConstraints: return "checklist"
        case .addExamples: return "doc.text"
        }
    }
}
