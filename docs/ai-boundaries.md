# AI Boundaries

Writeler treats AI as an assistant, not a ghostwriter.

## Allowed

- scene ideas
- goals, conflicts, and outcomes
- character, location, and object structuring
- consistency checks
- timeline checks
- storyline variants
- style analysis of existing text
- author questions
- research structuring
- plot gap review
- dialogue intent analysis

## Not Allowed

- no "write my chapter" command
- no hidden manuscript edits
- no automatic replacement of long manuscript passages
- no unmarked mixing of author text and AI output
- no automatic publication

## Technical Boundary

AI responses are stored as `AISuggestion`. A suggestion has:

- target entity
- provider and model metadata
- prompt text
- response text
- optional structured response
- user decision
- optional accepted patch

The current `RequestAISuggestion` service proves the boundary: it reads scene context, asks a provider, stores a suggestion, and never writes to `Scene.manuscriptText`.

## Provider Strategy

Provider adapters must implement `LanguageModelProvider`. Planned adapters:

- OpenAI-compatible API with configurable base URL
- Anthropic
- Google Gemini
- OpenRouter
- Ollama or equivalent local runtime
- Mock provider for tests
