Generating a Dart client from the OpenAPI spec

Overview

This project includes `backend/docs/openapi.yaml`. You can generate a full, production-ready Dart client (models + API wrappers) with OpenAPI Generator (openapi-generator-cli). The generated client is more feature-rich than the small hand-written client in `lib/src/core/api_client_generated` and can be regenerated when the spec changes.

Options

1) Using a local `openapi-generator-cli` installation (npm)

Prerequisites:
- Node.js installed
- `@openapitools/openapi-generator-cli` installed globally (or use npx)

Commands:

```powershell
cd e:\STUDY\Test_app\backend
npm install -g @openapitools/openapi-generator-cli
# generate Dart (Dio) client into Flutter project folder
openapi-generator-cli generate -i docs/openapi.yaml -g dart-dio -o ../lib/src/core/api_client_generated_full
```

2) Using Docker (no local Java/npm required)

```powershell
cd e:\STUDY\Test_app\backend
docker run --rm -v ${PWD}:/local openapitools/openapi-generator-cli generate -i /local/docs/openapi.yaml -g dart-dio -o /local/../lib/src/core/api_client_generated_full
```

Notes on generator options
- `-g dart-dio` generates a Dart client that uses Dio for HTTP. If you prefer `http` or another generator, change the generator name.
- You can pass additional configuration via `-c config.json` for package names, null-safety, etc.

Integrating into the Flutter app
1) After generation, the client will live in `lib/src/core/api_client_generated_full`.
2) You can either:
   - Use the generated `Api` classes directly (recommended), or
   - Wrap them with your existing `ApiClient` abstraction (to preserve app-level headers/auth behavior).

CI automation
- Add a CI job that runs the generator and fails if generated files are out of date (compare git diff). This prevents spec drift.

Example package.json script

This repo has npm scripts in `backend/package.json`:
- `npm run generate:dart-client` (requires `openapi-generator-cli` installed locally/globally)
- `npm run generate:dart-client:docker` (uses Docker image)

Run these from `backend/`.

If you want, I can:
- (A) Run the generation in this environment (requires the generator tool installed — I cannot install new global packages here), or
- (B) Add a CI configuration snippet (GitHub Actions) that generates the client and commits or fails when out-of-date.

Which would you like next?