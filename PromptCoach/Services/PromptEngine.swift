import Foundation

/// Assembles structured prompts from user answers, generates variants,
/// and provides short coaching explanations.
struct PromptEngine {

    // MARK: - Public API

    /// Generate a complete prompt result from generator wizard answers.
    func generate(from answers: GeneratorAnswers) -> PromptResult {
        let finalPrompt = buildPrompt(from: answers, style: .balanced)
        let variants = buildVariants(from: answers)
        let explanation = buildExplanation(from: answers)
        return PromptResult(
            finalPrompt: finalPrompt,
            variants: variants,
            explanation: explanation
        )
    }

    // MARK: - Prompt Assembly

    private enum PromptStyle {
        case concise
        case balanced
        case detailed
        case strictFormat
    }

    private func buildPrompt(from answers: GeneratorAnswers, style: PromptStyle) -> String {
        var sections: [String] = []

        // Role
        let role = roleSection(for: answers)
        if !role.isEmpty {
            sections.append(role)
        }

        // Task
        let task = taskSection(for: answers, style: style)
        sections.append(task)

        // Context
        if !answers.context.trimmed.isEmpty {
            let contextBlock: String
            switch style {
            case .concise:
                sections.append("Context: \(answers.context.trimmed)")
                contextBlock = ""
            default:
                contextBlock = "**Context:**\n\(answers.context.trimmed)"
                sections.append(contextBlock)
            }
        }

        // Audience
        if !answers.audience.trimmed.isEmpty {
            sections.append("**Audience:** \(answers.audience.trimmed)")
        }

        // Tone
        sections.append("**Tone:** \(answers.tone.rawValue)")

        // Constraints
        let constraints = constraintsSection(for: answers, style: style)
        if !constraints.isEmpty {
            sections.append(constraints)
        }

        // Output format
        if answers.outputFormat != .freeform {
            sections.append("**Output Format:** \(answers.outputFormat.rawValue)")
        }

        // Examples
        let examples = examplesSection(for: answers)
        if !examples.isEmpty {
            sections.append(examples)
        }

        // Quality checks
        var checks: [String] = []
        if answers.askClarifyingQuestions {
            checks.append("Before answering, ask clarifying questions if anything is unclear or ambiguous.")
        }
        if answers.askForSources {
            checks.append("Cite sources where possible. (Note: AI models may not always have access to real-time sources.)")
        }
        if !checks.isEmpty {
            sections.append(checks.joined(separator: "\n"))
        }

        return sections.joined(separator: "\n\n")
    }

    private func roleSection(for answers: GeneratorAnswers) -> String {
        switch answers.category {
        case .writing:
            return "You are an experienced writer and editor."
        case .work:
            return "You are a professional business communication specialist."
        case .school:
            return "You are a patient and knowledgeable tutor."
        case .coding:
            return "You are a senior software engineer and technical writer."
        case .brainstorming:
            return "You are a creative strategist and ideation expert."
        case .custom:
            return ""
        }
    }

    private func taskSection(for answers: GeneratorAnswers, style: PromptStyle) -> String {
        let subcatPrefix = answers.subcategory.isEmpty ? "" : " (\(answers.subcategory))"
        let base = answers.goal.trimmed.isEmpty
            ? "Help me with a \(answers.category.rawValue.lowercased())\(subcatPrefix) task."
            : answers.goal.trimmed

        switch style {
        case .concise:
            return "**Task:** \(base)"
        case .balanced:
            return "**Task:** \(base)"
        case .detailed:
            return "**Task:** \(base)\n\nPlease be thorough and provide detailed explanations for each point."
        case .strictFormat:
            return "**Task:** \(base)\n\nFollow the output format strictly. Do not deviate from the structure specified below."
        }
    }

    private func constraintsSection(for answers: GeneratorAnswers, style: PromptStyle) -> String {
        var constraints: [String] = []

        if !answers.lengthConstraint.trimmed.isEmpty {
            constraints.append("Length: \(answers.lengthConstraint.trimmed)")
        }
        if !answers.formatConstraint.trimmed.isEmpty {
            constraints.append("Format: \(answers.formatConstraint.trimmed)")
        }
        if !answers.mustInclude.trimmed.isEmpty {
            constraints.append("Must include: \(answers.mustInclude.trimmed)")
        }
        if !answers.mustAvoid.trimmed.isEmpty {
            constraints.append("Must avoid: \(answers.mustAvoid.trimmed)")
        }

        guard !constraints.isEmpty else { return "" }

        switch style {
        case .concise:
            return "**Constraints:** " + constraints.joined(separator: "; ")
        default:
            return "**Constraints:**\n" + constraints.map { "- \($0)" }.joined(separator: "\n")
        }
    }

    private func examplesSection(for answers: GeneratorAnswers) -> String {
        let hasInput = !answers.exampleInput.trimmed.isEmpty
        let hasOutput = !answers.exampleOutput.trimmed.isEmpty
        guard hasInput || hasOutput else { return "" }

        var parts: [String] = ["**Examples:**"]
        if hasInput {
            parts.append("Input example:\n\"\"\"\n\(answers.exampleInput.trimmed)\n\"\"\"")
        }
        if hasOutput {
            parts.append("Expected output example:\n\"\"\"\n\(answers.exampleOutput.trimmed)\n\"\"\"")
        }
        return parts.joined(separator: "\n")
    }

    // MARK: - Variants

    private func buildVariants(from answers: GeneratorAnswers) -> [VariantResult] {
        return [
            VariantResult(
                label: "Concise",
                body: buildPrompt(from: answers, style: .concise)
            ),
            VariantResult(
                label: "Detailed",
                body: buildPrompt(from: answers, style: .detailed)
            ),
            VariantResult(
                label: "Strict Format",
                body: buildPrompt(from: answers, style: .strictFormat)
            ),
        ]
    }

    // MARK: - Coaching Explanation

    private func buildExplanation(from answers: GeneratorAnswers) -> String {
        var tips: [String] = []

        tips.append("This prompt uses a clear structure: Role, Task, Context, Constraints, and Output Format. Structured prompts help AI produce focused, relevant responses.")

        if !answers.context.trimmed.isEmpty {
            tips.append("You provided context, which helps the AI understand the situation instead of guessing.")
        }
        if !answers.audience.trimmed.isEmpty {
            tips.append("Specifying your audience ensures the tone and complexity match who will read the result.")
        }
        if answers.askClarifyingQuestions {
            tips.append("Asking the AI to clarify before answering reduces misunderstandings and improves accuracy.")
        }
        if answers.outputFormat != .freeform {
            tips.append("Requesting a specific output format (\(answers.outputFormat.rawValue)) makes the response easier to use directly.")
        }
        if !answers.exampleInput.trimmed.isEmpty || !answers.exampleOutput.trimmed.isEmpty {
            tips.append("Including examples (few-shot prompting) is one of the most effective techniques for guiding AI output.")
        }

        return tips.joined(separator: "\n\n")
    }
}

// MARK: - String Extension

extension String {
    /// Returns the string with leading/trailing whitespace removed.
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
