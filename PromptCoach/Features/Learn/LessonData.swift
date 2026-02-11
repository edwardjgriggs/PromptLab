import Foundation

/// Static lesson content for the Learn section.
struct Lesson: Identifiable {
    let id: String
    let title: String
    let icon: String
    let durationLabel: String
    let summary: String
    let sections: [LessonSection]
    let badExample: LessonExample
    let goodExample: LessonExample
    /// Pre-filled GeneratorAnswers for the "Try it" button.
    let tryItAnswers: GeneratorAnswers
}

struct LessonSection {
    let heading: String
    let body: String
}

struct LessonExample {
    let label: String
    let prompt: String
    let explanation: String
}

// MARK: - All Lessons

enum LessonCatalog {
    static let all: [Lesson] = [
        lesson1RoleTaskContext,
        lesson2UsingExamples,
        lesson3AvoidAmbiguity,
        lesson4Iteration,
        lesson5FormattingOutputs,
    ]

    // MARK: Lesson 1
    static let lesson1RoleTaskContext = Lesson(
        id: "lesson_1",
        title: "The Prompt Formula",
        icon: "function",
        durationLabel: "2 min",
        summary: "Learn the Role + Task + Context + Constraints + Output formula that works with any AI.",
        sections: [
            LessonSection(
                heading: "The 5-Part Formula",
                body: """
                Great prompts share a simple structure:
                1. **Role** — Tell the AI who to be (e.g., "You are an experienced editor").
                2. **Task** — State exactly what you want done.
                3. **Context** — Provide background info the AI needs.
                4. **Constraints** — Set boundaries (length, tone, things to avoid).
                5. **Output format** — Describe how you want the result delivered.
                """
            ),
            LessonSection(
                heading: "Why It Works",
                body: "AI models respond to structure. Without it, the model guesses your intent. With it, the model focuses on exactly what you need."
            ),
        ],
        badExample: LessonExample(
            label: "Vague prompt",
            prompt: "Write something about marketing.",
            explanation: "Too vague. The AI doesn't know what kind of content, for whom, or how long."
        ),
        goodExample: LessonExample(
            label: "Structured prompt",
            prompt: """
            You are a senior marketing strategist.

            **Task:** Write 3 social media post ideas for launching a new eco-friendly water bottle.

            **Context:** The target audience is health-conscious millennials. The brand tone is upbeat and casual.

            **Constraints:** Each post should be under 280 characters. Avoid clichés like "game-changer."

            **Output:** Numbered list with the post text and a suggested hashtag for each.
            """,
            explanation: "Clear role, specific task, audience context, concrete constraints, and a defined output format."
        ),
        tryItAnswers: {
            var a = GeneratorAnswers()
            a.category = .writing
            a.subcategory = "Social media post"
            a.goal = "Write 3 social media post ideas for launching a new eco-friendly water bottle"
            a.audience = "Health-conscious millennials"
            a.tone = .casual
            a.lengthConstraint = "Each post under 280 characters"
            a.mustAvoid = "Clichés like 'game-changer'"
            a.outputFormat = .numbered
            return a
        }()
    )

    // MARK: Lesson 2
    static let lesson2UsingExamples = Lesson(
        id: "lesson_2",
        title: "Using Examples",
        icon: "doc.text.magnifyingglass",
        durationLabel: "2 min",
        summary: "Show the AI what you want by including input/output examples (few-shot prompting).",
        sections: [
            LessonSection(
                heading: "What Are Few-Shot Examples?",
                body: "Instead of just describing what you want, you *show* the AI with one or more examples of input and expected output. This is called \"few-shot prompting\" and it's one of the most powerful techniques available."
            ),
            LessonSection(
                heading: "When to Use Examples",
                body: """
                Use examples when:
                - The output format is specific or unusual
                - You need a consistent style across multiple outputs
                - Words alone can't fully describe what you want
                - The AI keeps misunderstanding your intent
                """
            ),
        ],
        badExample: LessonExample(
            label: "No example",
            prompt: "Rewrite these sentences to be more professional.",
            explanation: "The AI has to guess what 'professional' means to you. Everyone's standard is different."
        ),
        goodExample: LessonExample(
            label: "With example",
            prompt: """
            Rewrite the following sentences to be more professional.

            **Example:**
            Input: "Hey, can you get that report done ASAP?"
            Output: "Could you please prioritize completing the report by end of day?"

            Now rewrite these:
            1. "That idea is kinda meh."
            2. "Let's just wing the presentation."
            """,
            explanation: "The example shows the AI exactly what 'professional' means in your context: polite, specific, and measured."
        ),
        tryItAnswers: {
            var a = GeneratorAnswers()
            a.category = .work
            a.subcategory = "Email"
            a.goal = "Rewrite informal sentences to be more professional"
            a.tone = .professional
            a.exampleInput = "Hey, can you get that report done ASAP?"
            a.exampleOutput = "Could you please prioritize completing the report by end of day?"
            return a
        }()
    )

    // MARK: Lesson 3
    static let lesson3AvoidAmbiguity = Lesson(
        id: "lesson_3",
        title: "Avoiding Ambiguity",
        icon: "exclamationmark.triangle",
        durationLabel: "1 min",
        summary: "Vague prompts get vague results. Learn to be specific without being verbose.",
        sections: [
            LessonSection(
                heading: "Common Ambiguities",
                body: """
                Watch out for words that seem clear but aren't:
                - "Good" — good how? Accurate? Engaging? Brief?
                - "Some" — how many? 3? 10?
                - "Improve" — in what way?
                - "Etc." — the AI can't read your mind
                """
            ),
            LessonSection(
                heading: "The Fix",
                body: "Replace vague words with measurable specifics. Instead of 'short,' say 'under 100 words.' Instead of 'improve,' say 'make the tone more empathetic while keeping it under 3 paragraphs.'"
            ),
        ],
        badExample: LessonExample(
            label: "Ambiguous",
            prompt: "Give me some good ideas for my business.",
            explanation: "'Some,' 'good,' and 'my business' are all ambiguous. The AI has no specifics to work with."
        ),
        goodExample: LessonExample(
            label: "Specific",
            prompt: """
            Give me 5 marketing ideas for a small bakery in Portland, Oregon.

            Focus on low-cost strategies that can be started this week. The bakery specializes in sourdough bread and has an Instagram account with 500 followers.
            """,
            explanation: "Exact number, specific business, location, budget constraint, timeline, and relevant details."
        ),
        tryItAnswers: {
            var a = GeneratorAnswers()
            a.category = .brainstorming
            a.subcategory = "Ideas"
            a.goal = "Give me 5 marketing ideas for a small bakery"
            a.context = "Small bakery in Portland, Oregon. Specializes in sourdough bread. Has an Instagram account with 500 followers."
            a.lengthConstraint = "5 ideas"
            a.mustInclude = "Low-cost strategies that can be started this week"
            a.outputFormat = .numbered
            return a
        }()
    )

    // MARK: Lesson 4
    static let lesson4Iteration = Lesson(
        id: "lesson_4",
        title: "Ask Questions First",
        icon: "questionmark.bubble",
        durationLabel: "1 min",
        summary: "Let the AI ask clarifying questions before it answers — a simple trick for better results.",
        sections: [
            LessonSection(
                heading: "The Technique",
                body: "Add one line to the end of your prompt: \"Before answering, ask me any clarifying questions you need.\" This turns the AI into a collaborator instead of a guesser."
            ),
            LessonSection(
                heading: "Why It Works",
                body: "You might forget to include important context. The AI can identify gaps in your prompt and ask about them, leading to a more accurate result on the next turn."
            ),
        ],
        badExample: LessonExample(
            label: "No iteration",
            prompt: "Write a project proposal for my team.",
            explanation: "The AI doesn't know the project, the team, the audience, or the format. It will fill in the blanks with generic content."
        ),
        goodExample: LessonExample(
            label: "With clarifying step",
            prompt: """
            I need to write a project proposal. Before you write anything, ask me clarifying questions about:
            - The project goal and scope
            - The intended audience for the proposal
            - Any format or length requirements
            - Key stakeholders or constraints
            """,
            explanation: "The AI will ask targeted questions, then produce a proposal that actually fits your situation."
        ),
        tryItAnswers: {
            var a = GeneratorAnswers()
            a.category = .work
            a.subcategory = "Proposal"
            a.goal = "Write a project proposal"
            a.askClarifyingQuestions = true
            a.tone = .professional
            return a
        }()
    )

    // MARK: Lesson 5
    static let lesson5FormattingOutputs = Lesson(
        id: "lesson_5",
        title: "Formatting Outputs",
        icon: "text.badge.checkmark",
        durationLabel: "1 min",
        summary: "Control how the AI structures its response — tables, lists, step-by-step, and more.",
        sections: [
            LessonSection(
                heading: "Why Format Matters",
                body: "A wall of text is hard to use. By specifying the output format, you get results you can immediately copy, paste, and act on."
            ),
            LessonSection(
                heading: "Common Formats",
                body: """
                - **Bullet points** — great for lists and quick scans
                - **Numbered lists** — for ordered steps or ranked items
                - **Tables** — for comparisons (use Markdown table syntax)
                - **Step-by-step** — for instructions or processes
                - **JSON** — for structured data you'll use in code
                """
            ),
        ],
        badExample: LessonExample(
            label: "No format specified",
            prompt: "Compare Python and JavaScript for web development.",
            explanation: "You'll get a long essay. Hard to scan, hard to compare, hard to reference later."
        ),
        goodExample: LessonExample(
            label: "With format",
            prompt: """
            Compare Python and JavaScript for web development.

            Present the comparison as a Markdown table with these columns:
            | Feature | Python | JavaScript |

            Cover: learning curve, ecosystem, performance, job market, and best use cases.
            Keep each cell to 1-2 sentences.
            """,
            explanation: "You'll get a clean, scannable table that's easy to share and reference."
        ),
        tryItAnswers: {
            var a = GeneratorAnswers()
            a.category = .coding
            a.subcategory = "Documentation"
            a.goal = "Compare Python and JavaScript for web development"
            a.outputFormat = .table
            a.lengthConstraint = "1-2 sentences per cell"
            a.mustInclude = "learning curve, ecosystem, performance, job market, best use cases"
            return a
        }()
    )
}
