# Project Working Memory

## App Summary
- Reusable GitHub Actions repo for client website repos.
- Primary workflow sends client-facing commit summary emails on pushes to `main` or `master`.
- Uses OpenAI to summarize commit messages and SMTP to send the email.

## Current Focus
- Finish migration from personal-account reusable workflow usage to org-owned `Serbyte-Development/actions`.

## In-Flight Work
- Reusable workflow updated to org-owned action reference in `.github/workflows/send_commit_email.yaml`.
- Docs updated in `README.MD` to use `Serbyte-Development/actions` and `secrets: inherit`.
- Bulk update helper added at `scripts/update-client-workflow-references.sh`.
- Local `git-init-org` shell helper in `~/.zshrc` hardened to slugify repo names and rewire `origin`.
- Pilot workflow test from a separate org repo still needs to be run.

## Latest Decisions
- Keep shared credentials as org Actions secrets: `OPENAI_API_KEY`, `SMTP_USERNAME`, `SMTP_PASSWORD`.
- Keep `CLIENT_EMAIL` as a repo secret to avoid adding `workflow_call` inputs and `with:` plumbing.
- Caller repos should use `uses: Serbyte-Development/actions/.github/workflows/send_commit_email.yaml@v1`.
- Do not rely on GitHub redirects from `Austin1serb/Serbyte-Actions`.
- Prefer `@v1` over `@main`; move the floating `v1` tag when releasing new action changes.

## Blockers / Risks
- Org secrets still need to be configured and granted to target repos before end-to-end testing.
- A moved local `v1` tag can break `git pull --tags` / VS Code sync until the local tag is refreshed.
- Reusable workflow access must be allowed across org repos if `Serbyte-Development/actions` is private.

## Next Actions
- Add org secrets in `Serbyte-Development` and scope them to a pilot repo.
- Add repo secret `CLIENT_EMAIL` in one pilot client repo.
- Add the minimal caller workflow in the pilot repo and push a test commit.
- Verify that `@v1` exists and points to the intended release commit before rollout.
- After pilot success, run the bulk updater against remaining repos.

## Open Questions
- Whether `Serbyte-Development/actions` is private and needs org Actions policy adjustments.
- Whether to add a release helper for bumping `v1.x.y` and moving `v1` in one command.

## Resume Fast
- Start by configuring org secrets, then test the reusable workflow from one separate org repo using `secrets: inherit`.
- If VS Code sync fails again in this repo, refresh moved tags with `git fetch origin --tags --force`.

## Updated
- 2026-03-06 16:42 MST

## Project End Goals (future reference)
- New client repos require only `CLIENT_EMAIL` setup while shared credentials are managed once at the org level.
- All client repos consume the org-owned reusable workflow from `Serbyte-Development/actions`.
