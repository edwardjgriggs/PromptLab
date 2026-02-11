import Foundation

// MARK: - Enums for Generator Wizard

/// Categories for prompt generation.
enum PromptCategory: String, CaseIterable, Identifiable {
    case writing = "Writing"
    case work = "Work"
    case school = "School"
    case coding = "Coding"
    case brainstorming = "Brainstorming"
    case custom = "Custom"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .writing: return "pencil.line"
        case .work: return "briefcase.fill"
        case .school: return "graduationcap.fill"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        case .brainstorming: return "lightbulb.fill"
        case .custom: return "slider.horizontal.3"
        }
    }

    var subcategories: [String] {
        switch self {
        case .writing: return ["Blog post", "Story", "Social media post", "Essay", "Newsletter"]
        case .work: return ["Email", "Proposal", "Meeting summary", "Report", "Presentation outline"]
        case .school: return ["Study plan", "Explanation", "Flashcards", "Research summary", "Essay"]
        case .coding: return ["Debugging", "Feature spec", "Code review", "Documentation", "Refactoring"]
        case .brainstorming: return ["Ideas", "Naming", "Strategy", "Problem solving", "Creative concepts"]
        case .custom: return []
        }
    }
}

/// Tone options for prompt generation.
enum PromptTone: String, CaseIterable, Identifiable {
    case professional = "Professional"
    case casual = "Casual"
    case friendly = "Friendly"
    case formal = "Formal"
    case persuasive = "Persuasive"
    case educational = "Educational"
    case humorous = "Humorous"

    var id: String { rawValue }
}

/// Output format for the AI response.
enum OutputFormat: String, CaseIterable, Identifiable {
    case freeform = "Freeform"
    case bullets = "Bullet points"
    case numbered = "Numbered list"
    case table = "Table"
    case stepByStep = "Step-by-step"
    case json = "JSON"

    var id: String { rawValue }
}

/// Holds all the user's answers from the Generator wizard.
struct GeneratorAnswers {
    var category: PromptCategory = .writing
    var subcategory: String = ""
    var goal: String = ""
    var context: String = ""
    var audience: String = ""
    var tone: PromptTone = .professional
    var lengthConstraint: String = ""
    var formatConstraint: String = ""
    var mustInclude: String = ""
    var mustAvoid: String = ""
    var exampleInput: String = ""
    var exampleOutput: String = ""
    var outputFormat: OutputFormat = .freeform
    var askClarifyingQuestions: Bool = false
    var askForSources: Bool = false
}

/// The result produced by PromptEngine.
struct PromptResult {
    let finalPrompt: String
    let variants: [VariantResult]
    let explanation: String
}

/// A named variant of a generated prompt.
struct VariantResult {
    let label: String
    let body: String
}
