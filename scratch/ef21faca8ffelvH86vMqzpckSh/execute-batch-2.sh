#!/usr/bin/env bash
# Batch 2 executor (commits 6-10) for the arranged commits preview.
# - per-command commit.gpgsign=false (user-approved; local config untouched)
# - messages delivered via -F files (git-commit-message-delivery)
# - every commit verified: exact file set + status snapshot
set -u

R=/workspaces/account-ledger-cli-kotlin
S="$R/scratch/ef21faca8ffelvH86vMqzpckSh"
LOG="$S/batch-2-execution.log"

gitc() { git -c commit.gpgsign=false -C "$R" "$@"; }

: > "$LOG"
exec >> "$LOG" 2>&1

cat > "$S/msg-6.txt" <<'EOF'
ci(security): add Gitleaks secret scanning workflow

- Scan full history on pushes, pull requests, and a weekly schedule.
- The action runs without a license key for personal accounts and
  complements native secret scanning push protection.
EOF

cat > "$S/msg-7.txt" <<'EOF'
ci(security): add OpenSSF Scorecard workflow

- Analyze repository security practices on branch protection changes,
  pushes, and a weekly schedule.
- Publish the public score and upload SARIF results with the OIDC and
  security-events permissions the action requires.
EOF

cat > "$S/msg-8.txt" <<'EOF'
ci(security): add dependency review workflow

- Block pull requests that introduce dependencies with high or
  critical advisories; this is the only gating scanner in the stack.
- Disable the pull request summary comment so review threads stay
  clean, leaving the check result as the verdict.
EOF

cat > "$S/msg-9.txt" <<'EOF'
ci(security): add zizmor GitHub Actions audit workflow

- Audit every workflow file for supply chain and security weaknesses
  with the auditor persona and online audits enabled.
- Publish findings to code scanning through the advanced security
  integration.
EOF

cat > "$S/msg-10.txt" <<'EOF'
ci(security): add Snyk Code and open source scanning workflow

- Run Snyk Code and Snyk Open Source with SARIF output for code
  scanning.
- Skip both scans until a SNYK_TOKEN secret exists so the workflow is
  safe to merge before the free account is connected.
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

step "commit 6"
gitc add .github/workflows/gitleaks.yml
gitc commit -F "$S/msg-6.txt"
expect_files 6 .github/workflows/gitleaks.yml

step "commit 7"
gitc add .github/workflows/scorecard.yml
gitc commit -F "$S/msg-7.txt"
expect_files 7 .github/workflows/scorecard.yml

step "commit 8"
gitc add .github/workflows/dependency-review.yml
gitc commit -F "$S/msg-8.txt"
expect_files 8 .github/workflows/dependency-review.yml

step "commit 9"
gitc add .github/workflows/zizmor.yml
gitc commit -F "$S/msg-9.txt"
expect_files 9 .github/workflows/zizmor.yml

step "commit 10"
gitc add .github/workflows/snyk.yml
gitc commit -F "$S/msg-10.txt"
expect_files 10 .github/workflows/snyk.yml

step "post-state"
gitc log --oneline -11
gitc status --porcelain

printf '\nBATCH-2-EXECUTION-COMPLETE\n'
