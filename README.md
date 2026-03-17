# ARIA App

Flutter (Web + Mobile) AI assistant with local DB (Drift) + Auth.

## Run (Groq AI enabled)

This app reads the Groq key from a compile-time define:

```bash
flutter run --dart-define=GROQ_API_KEY=YOUR_GROQ_KEY
```

If you run from VS Code, edit `.vscode/launch.json` and paste your key in:

`--dart-define=GROQ_API_KEY=PASTE_YOUR_GROQ_KEY_HERE`

## Notes

- Never hardcode API keys inside `lib/` files.
