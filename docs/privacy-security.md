# Privacy and Security

## Defaults

- All project data stays local by default.
- Metrics are local, transparent, and disableable.
- AI is optional.
- Cloud sync is optional.

## API Keys

Native platforms should use platform key storage where available. Web storage of API keys must show a clear warning because browser storage cannot offer the same guarantees.

## AI Requests

Project content must never be sent to a provider unless the user starts an AI action. The selected context should be visible or inspectable before the request.

## Sensitive Projects

A project can be marked `noAiNoCloud`. The domain policy blocks AI for that project; sync adapters must respect the same flag.
