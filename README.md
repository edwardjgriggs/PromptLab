# PromptCoach

An iOS app that helps everyday users become better at prompting AI. Built with SwiftUI and SwiftData.

## Setup

### Requirements
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Getting Started
1. Clone the repository
2. Open `PromptCoach.xcodeproj` in Xcode
3. Select a simulator or device target (iPhone recommended)
4. Build and run (Cmd+R)

No external dependencies or package managers required. The app is fully self-contained.

## Architecture

### Pattern: MVVM with Services

```
PromptCoach/
├── App/                    # App entry point, root navigation
│   ├── PromptCoachApp.swift
│   ├── RootView.swift      # Onboarding vs main tab routing
│   └── MainTabView.swift
├── Models/                 # SwiftData models + value types
│   ├── UserProfile.swift
│   ├── Prompt.swift
│   ├── PromptVariant.swift
│   ├── LessonProgress.swift
│   └── GeneratorModels.swift
├── Services/               # Business logic (no UI)
│   ├── PromptEngine.swift  # Template assembly, variants, explanations
│   ├── CoachEngine.swift   # State machine for chat coaching
│   └── KeychainService.swift
├── Features/               # Feature modules (one folder per feature)
│   ├── Onboarding/
│   ├── Home/
│   ├── Generator/          # Step-by-step prompt wizard
│   ├── ChatCoach/          # Chat-based prompt assistant
│   ├── Learn/              # Mini-lessons on prompting
│   ├── Library/            # Saved prompts, favorites, tags
│   └── Settings/           # Profile, API keys, privacy
├── Shared/
│   ├── Components/         # Reusable UI: CopyButton, CardView, TagChip, etc.
│   └── Extensions/
└── Resources/
    └── Assets.xcassets
```

### Key Services

**PromptEngine** — Takes structured user answers and produces:
- A final prompt using the Role + Task + Context + Constraints + Output formula
- 3 variants (Concise, Detailed, Strict Format)
- A coaching explanation of why the prompt works

**CoachEngine** — A state machine (`ObservableObject`) that drives the chat assistant:
- States: `GatherGoal → GatherContext → GatherAudience → GatherConstraints → GeneratePrompt → Refine`
- Produces follow-up questions at each state
- Generates the final prompt using PromptEngine internally
- Supports refinement toggles (More Specific, More Creative, More Formal, etc.)

### Data Layer

All data is stored locally using **SwiftData** (iOS 17+):

| Entity | Purpose |
|--------|---------|
| `UserProfile` | Onboarding preferences (categories, verbosity, target model) |
| `Prompt` | Saved prompts with title, body, category, tags, variants |
| `PromptVariant` | Named variant of a prompt (e.g., "Concise") |
| `LessonProgress` | Tracks completed lessons |

## Privacy Model

PromptCoach is **offline-first** by design:

- **All data stored on device.** Prompts, preferences, and progress use SwiftData with local persistence only.
- **No analytics or tracking.** No third-party SDKs, no telemetry, no network calls by default.
- **API keys in Keychain.** If the user enables BYOK (Bring Your Own Key), keys are stored in the iOS Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`. Keys are never logged.
- **User control.** API keys can be deleted from Settings at any time. Uninstalling the app removes all data.
- **External calls only when explicit.** Network requests only happen if the user enables BYOK and initiates an AI-powered refinement.

## Features

### MVP (Implemented)
- [x] Onboarding flow (use case, verbosity, target model)
- [x] Home screen with 3 action tiles + recent prompts
- [x] Prompt Generator Wizard (6-step guided flow with live preview)
- [x] Prompt variants (Concise, Detailed, Strict Format)
- [x] "Why this works" coaching explanations
- [x] Save prompts with title, tags, and favorites
- [x] Library with search, tag filtering, and favorites
- [x] Coach Chat (offline Mode 1) with state-machine-driven conversation
- [x] Refinement toggles in chat (More Specific, Creative, Formal, etc.)
- [x] 5 Learn lessons with bad/good examples and "Try it" integration
- [x] Copy buttons with haptic feedback throughout
- [x] Settings with privacy page
- [x] BYOK API key management (Keychain storage, delete button)
- [x] Unit tests for PromptEngine and CoachEngine
- [x] UI tests for core flows

### Optional (TODO)
- [ ] iCloud sync via CloudKit
- [ ] Home screen widgets (generate shortcut, copy last prompt)
- [ ] Export as Markdown / JSON
- [ ] BYOK Mode 2: actual API calls for AI-powered refinement
- [ ] Prompt quality checklist / scoring
- [ ] Additional lesson content
- [ ] Prompt sharing via share sheet
- [ ] Dark mode customization

## Extending Templates and Lessons

### Adding a New Prompt Category

1. Add a case to `PromptCategory` in `GeneratorModels.swift`
2. Add subcategories, icon, and display name
3. Add a role mapping in `PromptEngine.roleSection(for:)`

### Adding a New Lesson

1. Create a new static property in `LessonCatalog` (in `LessonData.swift`)
2. Include: title, icon, sections, bad/good examples, and pre-filled `GeneratorAnswers` for "Try it"
3. Add it to `LessonCatalog.all`

### Adding a Refinement Option

1. Add a case to `RefinementOption` in `CoachEngine.swift`
2. Add label, icon, and handling logic in `regenerateWithRefinement(_:)`

## Testing

### Unit Tests
```bash
# Run from Xcode or command line:
xcodebuild test -scheme PromptCoach -destination 'platform=iOS Simulator,name=iPhone 15'
```

Tests cover:
- **PromptEngine**: All sections appear when provided, omitted when empty; variants generation; explanation content
- **CoachEngine**: State machine transitions; skip handling; prompt generation; refinement; reset; full conversation flow

### UI Tests
Tests cover:
- Onboarding appearance and navigation
- Home screen tile visibility
- Generator open/dismiss
- Chat coach launch
- Tab bar navigation

## License

This project is provided as-is for educational and personal use.
