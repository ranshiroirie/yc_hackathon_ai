## Coding Conventions
- Use TypeScript with async/await and zod for input validation.
- Prefer functional helpers for Firestore access; avoid `any` when possible but permitted for quick hacks.
- Use `firebase-functions/v2` APIs (`onCall`, `onDocumentCreated`).
- Keep responses minimal JSON objects; log user-facing errors with friendly messages.
