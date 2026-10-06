#!/usr/bin/env bash
# Batch 1 executor (commits 1-5) for the arranged commits preview.
# - per-command commit.gpgsign=false (user-approved; local config untouched)
# - messages delivered via -F files (git-commit-message-delivery)
# - every commit verified: exact file set + status snapshot
set -u

R=/workspaces/account-ledger-cli-kotlin
S="$R/scratch/ef21faca8ffelvH86vMqzpckSh"
LOG="$S/batch-1-execution.log"

gitc() { git -c commit.gpgsign=false -C "$R" "$@"; }

: > "$LOG"
exec >> "$LOG" 2>&1

cat > "$S/msg-1.txt" <<'EOF'
chore: ignore scratch directory

- Keep session-scoped scratch artifacts out of version control.
- The scratch tree holds commit previews and command output captured
  during agent sessions.
EOF

cat > "$S/msg-2.txt" <<'EOF'
ci(security): add CodeQL code scanning workflow

- Run the security-extended and security-and-quality query suites for
  Java/Kotlin on pushes, pull requests, and a weekly schedule.
- Build the cli-app classes with the Gradle wrapper on Temurin 21, the
  compatibility level declared by the build, so extraction sees
  compiled sources.
- Keep the advanced workflow as the only CodeQL setup; default setup
  stays disabled to avoid conflicting analyses.
EOF

cat > "$S/msg-3.txt" <<'EOF'
ci(security): add Semgrep OSS scanning workflow

- Scan with the auto, security-audit, owasp-top-ten, and secrets
  rulesets using the pinned Semgrep container.
- Upload SARIF findings to code scanning and keep the job advisory so
  new findings never block merges.
EOF

cat > "$S/msg-4.txt" <<'EOF'
ci(security): add Trivy vulnerability and secret scanning workflow

- Scan the filesystem for vulnerabilities, secrets, misconfiguration,
  and license issues with the pinned Trivy action.
- Publish SARIF results to code scanning and retain a CycloneDX SBOM
  artifact for supply chain review.
EOF

cat > "$S/msg-5.txt" <<'EOF'
ci(security): add Checkov and KICS IaC scanning workflows

- Analyze Dockerfiles, workflow files, and devcontainer configuration
  for infrastructure-as-code weaknesses with Checkov and KICS.
- Keep both jobs advisory and publish SARIF results under distinct
  code scanning categories.
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

step "commit 1"
gitc add .gitignore
gitc commit -F "$S/msg-1.txt"
expect_files 1 .gitignore

step "commit 2"
gitc add .github/workflows/codeql.yml
gitc commit -F "$S/msg-2.txt"
expect_files 2 .github/workflows/codeql.yml

step "commit 3"
gitc add .github/workflows/semgrep.yml
gitc commit -F "$S/msg-3.txt"
expect_files 3 .github/workflows/semgrep.yml

step "commit 4"
gitc add .github/workflows/trivy.yml
gitc commit -F "$S/msg-4.txt"
expect_files 4 .github/workflows/trivy.yml

step "commit 5"
gitc add .github/workflows/iac-security.yml
gitc commit -F "$S/msg-5.txt"
expect_files 5 .github/workflows/iac-security.yml

step "post-state"
gitc log --oneline -6
gitc status --porcelain

printf '\nBATCH-1-EXECUTION-COMPLETE\n'
