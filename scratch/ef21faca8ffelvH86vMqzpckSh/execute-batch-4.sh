#!/usr/bin/env bash
# Batch 4 executor (commits 16-18) for the arranged commits preview.
# - commit 16: GEMINI.md partial staging via stage-file-excluding-lines.py
#   (runs in python:3.12 docker because the host has no python3)
# - per-command commit.gpgsign=false (user-approved; local config untouched)
# - messages delivered via -F files (git-commit-message-delivery)
# - every commit verified: exact file set + status snapshot
# - ends with the safety-stash no-op verification
set -u

R=/workspaces/account-ledger-cli-kotlin
S="$R/scratch/ef21faca8ffelvH86vMqzpckSh"
LOG="$S/batch-4-execution.log"
STAGER=/workspaces/ai-suite/.agents/skills/git-hunk-staging-primitives/scripts/stage-file-excluding-lines.py

gitc() { git -c commit.gpgsign=false -C "$R" "$@"; }

: > "$LOG"
exec >> "$LOG" 2>&1

cat > "$S/msg-16.txt" <<'EOF'
docs: correct stale CI workflow reference in GEMINI.md

- Point the CI/CD note at .github/workflows/gradle-build.yml, which
  runs actionlint, ShellCheck, and the Gradle build, instead of the
  removed gradle.yml path.
EOF

cat > "$S/msg-17.txt" <<'EOF'
docs(security): add security scanning documentation

- Document each workflow, its findings destination, and whether it
  blocks merges so reviewers know where results appear.
- List the manual activations that remain: the CodeRabbit and Socket
  app installs and the optional Snyk and SonarCloud tokens.
EOF

cat > "$S/msg-18.txt" <<'EOF'
docs(security): document security scanning stack in GEMINI.md

- Add a Security Scanning section pointing to SECURITY.md for the
  inventory, required secrets, and manual activations so agents
  discover the stack from the repository guidance file.
EOF

step() { printf '\n===== %s =====\n' "$*"; }

expect_files() {
  local n="$1"; shift
  local got want
  got=$(gitc show --name-only --format='' HEAD | sed '/^$/d' | sort | tr '\n' ' ')
  want=$(printf '%s\n' "$@" | sort | tr '\n' ' ')
  if [ "$got" = "$want" ]; then
    printf 'VERIFY commit %s: OK [%s]\n' "$n" "$got"
  else
    printf 'VERIFY commit %s: MISMATCH got=[%s] want=[%s]\n' "$n" "$got" "$want"
    exit 21
  fi
}

step "pre-state"
gitc status --porcelain
gitc rev-parse HEAD
gitc stash list

step "commit 16: stage GEMINI.md with the Security Scanning block excluded"
docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp -v /workspaces:/workspaces -w "$R" python:3.12 \
  python3 "$STAGER" \
    --file GEMINI.md \
    --exclude "## Security Scanning" \
    --exclude "A layered, zero-cost security stack" \
    --blank-context 1
staging_rc=$?
printf 'staging rc=%s\n' "$staging_rc"
if [ "$staging_rc" -ne 0 ]; then
  printf 'STAGING FAILED\n'
  exit 31
fi
printf '\n-- staged diff (what commit 16 will contain) --\n'
gitc diff --cached -- GEMINI.md
printf '\n-- working-tree diff (block must remain unstaged) --\n'
gitc diff -- GEMINI.md
gitc commit -F "$S/msg-16.txt"
expect_files 16 GEMINI.md

step "commit 17"
gitc add SECURITY.md
gitc commit -F "$S/msg-17.txt"
expect_files 17 SECURITY.md

step "commit 18"
gitc add GEMINI.md
gitc commit -F "$S/msg-18.txt"
expect_files 18 GEMINI.md

step "post-state"
gitc log --oneline -21
gitc status --porcelain
printf '\n-- final GEMINI.md commit diff --\n'
gitc show --format='%h %s' HEAD -- GEMINI.md

step "safety-stash no-op verification"
printf -- '-- tracked files in stash (stash blob vs HEAD blob vs working-tree blob) --\n'
for f in $(gitc stash show --name-only stash@{0}); do
  s=$(gitc rev-parse "stash@{0}:$f")
  h=$(gitc rev-parse "HEAD:$f" 2>/dev/null || printf 'none')
  w=$(gitc hash-object "$f" 2>/dev/null || printf 'none')
  printf '%s stash=%s head=%s work=%s\n' "$f" "$s" "$h" "$w"
done
printf -- '-- untracked files in stash (stash blob vs HEAD blob) --\n'
for f in $(gitc ls-tree -r --name-only stash@{0}^3); do
  s=$(gitc rev-parse "stash@{0}^3:$f")
  h=$(gitc rev-parse "HEAD:$f" 2>/dev/null || printf 'none')
  printf '%s stash=%s head=%s\n' "$f" "$s" "$h"
done

printf '\nBATCH-4-EXECUTION-COMPLETE\n'
