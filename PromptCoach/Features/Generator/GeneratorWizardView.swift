import SwiftUI
import SwiftData

/// Step-by-step wizard for generating a structured prompt.
struct GeneratorWizardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var currentStep = 0
    @State private var answers = GeneratorAnswers()
    @State private var result: PromptResult?
    @State private var showSaveSheet = false
    @State private var showToast = false

    private let totalSteps = 6

    var body: some View {
        VStack(spacing: 0) {
            StepProgressBar(totalSteps: totalSteps + 1, currentStep: currentStep)
                .padding(.vertical, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if currentStep <= totalSteps - 1 {
                        stepContent
                    } else {
                        resultContent
                    }
                }
                .padding()
            }

            // Live Preview (collapsed)
            if currentStep > 0 && currentStep < totalSteps {
                livePreview
            }

            bottomBar
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Generate a Prompt")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .sheet(isPresented: $showSaveSheet) {
            SavePromptSheet(promptBody: result?.finalPrompt ?? "", category: answers.category.rawValue, variants: result?.variants ?? []) {
                dismiss()
            }
        }
        .toast(isShowing: $showToast, message: "Copied to clipboard")
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0: categoryStep
        case 1: goalStep
        case 2: contextStep
        case 3: audienceToneStep
        case 4: constraintsStep
        case 5: optionsStep
        default: EmptyView()
        }
    }

    // Step 0: Category
    private var categoryStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What type of prompt?")
                .font(.title2.bold())
            Text("Choose a category to get tailored structure and suggestions.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            categoryGrid

            if !answers.category.subcategories.isEmpty {
                subcategoryPicker
            }
        }
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(PromptCategory.allCases) { category in
                categoryButton(for: category)
            }
        }
    }

    private func categoryButton(for category: PromptCategory) -> some View {
        let isSelected = answers.category == category
        return Button {
            answers.category = category
        } label: {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title2)
                Text(category.rawValue)
                    .font(.subheadline.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
            .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var subcategoryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subcategory")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(answers.category.subcategories, id: \.self) { sub in
                        TagChip(
                            text: sub,
                            isSelected: answers.subcategory == sub
                        ) {
                            answers.subcategory = answers.subcategory == sub ? "" : sub
                        }
                    }
                }
            }
        }
    }

    // Step 1: Goal
    private var goalStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What do you want the AI to do?")
                .font(.title2.bold())
            Text("Be specific. The clearer your goal, the better the result.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextEditor(text: $answers.goal)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .accessibilityLabel("Goal description")
        }
    }

    // Step 2: Context
    private var contextStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Background context")
                .font(.title2.bold())
            Text("What does the AI need to know? Any relevant details, data, or situation.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextEditor(text: $answers.context)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .accessibilityLabel("Context description")

            Text("Leave blank if no extra context is needed.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // Step 3: Audience + Tone
    private var audienceToneStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Audience & Tone")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 8) {
                Text("Who is this for?")
                    .font(.headline)
                TextField("e.g., my manager, a 5th grader, developers", text: $answers.audience)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityLabel("Target audience")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("What tone should the AI use?")
                    .font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(PromptTone.allCases) { tone in
                            TagChip(
                                text: tone.rawValue,
                                isSelected: answers.tone == tone
                            ) {
                                answers.tone = tone
                            }
                        }
                    }
                }
            }
        }
    }

    // Step 4: Constraints
    private var constraintsStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Constraints")
                .font(.title2.bold())
            Text("Set boundaries for the AI's response.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Group {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Length").font(.subheadline.weight(.medium))
                    TextField("e.g., under 200 words, 3 paragraphs", text: $answers.lengthConstraint)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Format").font(.subheadline.weight(.medium))
                    TextField("e.g., email format, markdown", text: $answers.formatConstraint)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Must include").font(.subheadline.weight(.medium))
                    TextField("e.g., specific keywords, topics", text: $answers.mustInclude)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Must avoid").font(.subheadline.weight(.medium))
                    TextField("e.g., jargon, clichés", text: $answers.mustAvoid)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
    }

    // Step 5: Output format + quality checks
    private var optionsStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Output & Quality")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 8) {
                Text("Output format").font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(OutputFormat.allCases) { format in
                            TagChip(
                                text: format.rawValue,
                                isSelected: answers.outputFormat == format
                            ) {
                                answers.outputFormat = format
                            }
                        }
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Examples (optional)").font(.headline)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sample input").font(.subheadline.weight(.medium))
                    TextField("Paste a sample input", text: $answers.exampleInput)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expected output").font(.subheadline.weight(.medium))
                    TextField("Paste what you'd expect", text: $answers.exampleOutput)
                        .textFieldStyle(.roundedBorder)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Quality checks").font(.headline)

                Toggle("Ask AI to clarify before answering", isOn: $answers.askClarifyingQuestions)
                    .tint(.accentColor)

                Toggle("Ask AI to cite sources", isOn: $answers.askForSources)
                    .tint(.accentColor)

                if answers.askForSources {
                    Text("Note: AI citations depend on the model and may not always be accurate.")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
    }

    // MARK: - Live Preview

    private var livePreview: some View {
        DisclosureGroup("Live Preview") {
            Text(PromptEngine().generate(from: answers).finalPrompt)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
        .padding()
        .background(.ultraThinMaterial)
        .accessibilityLabel("Live prompt preview")
    }

    // MARK: - Result

    private var resultContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let result {
                // Final prompt
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Your Prompt")
                            .font(.title2.bold())
                        Spacer()
                        CopyButton(result.finalPrompt)
                    }
                    Text(result.finalPrompt)
                        .font(.body)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .textSelection(.enabled)
                }

                // Variants
                VStack(alignment: .leading, spacing: 8) {
                    Text("Variants")
                        .font(.headline)

                    ForEach(result.variants, id: \.label) { variant in
                        DisclosureGroup(variant.label) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(variant.body)
                                    .font(.caption)
                                    .textSelection(.enabled)
                                CopyButton(variant.body, label: "Copy variant")
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                // Coaching
                VStack(alignment: .leading, spacing: 8) {
                    Text("Why this works")
                        .font(.headline)
                    Text(result.explanation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.accentColor.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            if currentStep > 0 {
                Button("Back") {
                    withAnimation { currentStep -= 1 }
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            if currentStep <= totalSteps - 1 {
                Button {
                    if currentStep == totalSteps - 1 {
                        result = PromptEngine().generate(from: answers)
                        withAnimation { currentStep = totalSteps }
                    } else {
                        withAnimation { currentStep += 1 }
                    }
                } label: {
                    Text(currentStep == totalSteps - 1 ? "Generate" : "Next")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                }
            } else {
                Button {
                    showSaveSheet = true
                } label: {
                    Text("Save Prompt")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// MARK: - Save Prompt Sheet

struct SavePromptSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let promptBody: String
    let category: String
    let variants: [VariantResult]
    let onSave: () -> Void

    @State private var title = ""
    @State private var tagsText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Give your prompt a name", text: $title)
                        .accessibilityLabel("Prompt title")
                }

                Section("Tags") {
                    TextField("Comma-separated tags", text: $tagsText)
                        .accessibilityLabel("Tags")
                    Text("e.g., work, email, weekly")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Section("Preview") {
                    Text(promptBody)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Save Prompt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePrompt()
                    }
                    .disabled(title.trimmed.isEmpty)
                }
            }
        }
    }

    private func savePrompt() {
        let tags = tagsText.split(separator: ",").map { String($0).trimmed }.filter { !$0.isEmpty }
        let variantModels = variants.map { PromptVariant(label: $0.label, body: $0.body) }

        let prompt = Prompt(
            title: title.trimmed,
            body: promptBody,
            category: category,
            tags: tags,
            variants: variantModels,
            source: "wizard"
        )
        modelContext.insert(prompt)
        try? modelContext.save()
        dismiss()
        onSave()
    }
}
