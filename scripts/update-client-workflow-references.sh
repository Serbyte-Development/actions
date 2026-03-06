#!/usr/bin/env bash
set -euo pipefail

ORG="${ORG:-Serbyte-Development}"
ACTION_REPO="${ACTION_REPO:-Serbyte-Actions}"
OLD_REF="${OLD_REF:-Austin1serb/Serbyte-Actions/.github/workflows/send_commit_email.yaml@main}"
NEW_REF="${NEW_REF:-Serbyte-Development/Serbyte-Actions/.github/workflows/send_commit_email.yaml@v1}"
BRANCH_NAME="${BRANCH_NAME:-codex/update-serbyte-actions-ref}"
MODE="${MODE:-dry-run}"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required." >&2
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep (rg) is required." >&2
  exit 1
fi

if ! command -v perl >/dev/null 2>&1; then
  echo "perl is required." >&2
  exit 1
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

echo "Mode: $MODE"
echo "Org: $ORG"
echo "Old ref: $OLD_REF"
echo "New ref: $NEW_REF"
echo

gh repo list "$ORG" --limit 500 --json nameWithOwner,isArchived,defaultBranchRef \
  --jq '.[] | select(.isArchived | not) | [.nameWithOwner, .defaultBranchRef.name] | @tsv' |
while IFS=$'\t' read -r repo default_branch; do
  if [[ "$repo" == "$ORG/$ACTION_REPO" ]]; then
    continue
  fi

  repo_dir="$tmp_root/${repo##*/}"
  echo "Checking $repo"
  gh repo clone "$repo" "$repo_dir" -- --depth=1 --branch "$default_branch" >/dev/null 2>&1

  matches="$(cd "$repo_dir" && rg -l --fixed-strings "$OLD_REF" .github/workflows || true)"
  if [[ -z "$matches" ]]; then
    echo "  No matching workflow reference found."
    continue
  fi

  echo "  Found old reference in:"
  printf '  %s\n' $matches

  if [[ "$MODE" != "apply" ]]; then
    continue
  fi

  (
    cd "$repo_dir"
    git checkout -b "$BRANCH_NAME" >/dev/null 2>&1

    while IFS= read -r file; do
      [[ -z "$file" ]] && continue
      perl -0pi -e "s|\Q$OLD_REF\E|$NEW_REF|g" "$file"
    done <<< "$matches"

    if git diff --quiet; then
      echo "  No diff after replacement, skipping."
      exit 0
    fi

    git add .github/workflows
    git commit -m "Update Serbyte-Actions reusable workflow reference" >/dev/null
    git push -u origin "$BRANCH_NAME" >/dev/null

    gh pr create \
      --repo "$repo" \
      --base "$default_branch" \
      --head "$BRANCH_NAME" \
      --title "Update Serbyte-Actions workflow reference" \
      --body "Updates the reusable workflow reference from the old personal-account path to the org-owned Serbyte-Actions repo."
  )

  echo "  PR opened."
done
