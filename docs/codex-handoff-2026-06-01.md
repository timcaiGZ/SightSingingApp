# Codex Handoff - 2026-06-01

## Repository

- GitHub: https://github.com/timcaiGZ/SightSingingApp
- Current branch: `main`
- Current HEAD: `4d5b7a4 feat: 和弦扩展引擎 — 斜杠和弦+借用和弦+副属和弦+和声小调`
- Repository is not shallow: full Git history has been fetched.
- Local working tree was clean before this handoff document was added.

## Session Context

This Codex session started from an empty generated workspace containing only `work/` and `outputs/`.

Actions completed:

1. Cloned `timcaiGZ/SightSingingApp` into `work/SightSingingApp`.
2. The initial clone was shallow because it was the fastest way to recover from sandbox DNS/network friction.
3. Fetched the full Git history with `git fetch --unshallow origin`.
4. Verified the repository is no longer shallow with `git rev-parse --is-shallow-repository`, which returned `false`.
5. Verified `git rev-list --count --all` returned `61` commits at that time.

No source code changes were made during this session before creating this handoff note.

## Project Shape

- Native iOS Swift app.
- Xcode project: `SightSingingApp.xcodeproj`
- XcodeGen config: `project.yml`
- App target: `SightSingingApp`
- Unit test target: `SightSingingAppTests`
- iOS deployment target: `17.0`
- Swift version: `5.9`
- Bundle identifier: `com.sightsinging.app`
- Display name: `视唱练耳`

Important directories:

- `SightSingingApp/App`: app entry and root content.
- `SightSingingApp/Components`: reusable SwiftUI components.
- `SightSingingApp/Models`: app models and settings.
- `SightSingingApp/Services`: audio, pitch, question, recommendation, and test services.
- `SightSingingApp/Utilities`: logging, theme, configuration, and music theory helpers.
- `SightSingingApp/ViewModels`: practice, profile, sight-singing, test, and theory view models.
- `SightSingingAppTests`: unit tests.
- `docs`: specs, plans, upgrade notes, and this handoff.
- `openspec`: OpenSpec change notes.
- `prototype`: Next.js prototype artifacts.

## Existing Reference Docs

- `docs/SRS.md`
- `docs/spec-v2.2.md`
- `docs/gap-analysis-v2.2.md`
- `docs/buitar-harmonycore-summary.md`
- `docs/phase1-music-runtime-tasks.md`
- `docs/AudioKitUpgradeGuide.md`
- `docs/plans/2026-05-18-implementation-plan.md`
- `docs/plans/2026-05-18-sight-singing-redesign-design.md`
- `SYNC.md`

## Continue On Another Machine

```bash
git clone https://github.com/timcaiGZ/SightSingingApp.git
cd SightSingingApp
git status --short --branch
git rev-parse --is-shallow-repository
```

Expected state after this handoff is pushed:

- Branch should be `main`.
- `git rev-parse --is-shallow-repository` should print `false`.
- `SYNC.md` should mention this 2026-06-01 handoff.
- `docs/codex-handoff-2026-06-01.md` should be present.

Open `SightSingingApp.xcodeproj` in Xcode to continue native iOS work. If regenerating the project from `project.yml`, use the repo's existing XcodeGen flow and then verify the generated project before committing.

## Notes For The Next Codex Session

- Preserve existing user changes; do not reset or overwrite local work without explicit instruction.
- Prefer the current project structure and docs before introducing new abstractions.
- For frontend/prototype work, inspect `prototype/` separately from the native iOS app.
- For app changes, run focused tests when possible through Xcode or `xcodebuild`.
