## Structure
- `src/index.ts`: main entry exporting callable functions and Firestore triggers.
- `src/openaiClient.ts`: wrappers for embedding/reason generation requests.
- `lib/`: compiled JS outputs (tsc build target).
- `package.json`: scripts (`npm run build`, `npm run dev`) and dependencies (`firebase-admin`, `firebase-functions`, `openai`).
