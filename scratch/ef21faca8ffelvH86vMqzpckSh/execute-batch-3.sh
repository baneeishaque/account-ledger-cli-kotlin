#!/usr/bin/env bash
# Batch 3 executor (commits 11-15) for the arranged commits preview.
# - per-command commit.gpgsign=false (user-approved; local config untouched)
# - messages delivered via -F files (git-commit-message-delivery)
# - every commit verified: exact file set + status snapshot
set -u

R=/workspaces/account-ledger-cli-kotlin
S="$R/scratch/ef21faca8ffelvH86vMqzpckSh"
LOG="$S/batch-3-execution.log"

gitc() { git -c commit.gpgsign=false -C "$R" "$@"; }

: > "$LOG"
exec >> "$LOG" 2>&1

cat > "$S/msg-11.txt" <<'EOF'
ci(security): add SonarCloud analysis workflow and configuration

- Analyze cli-app with JaCoCo coverage and publish to the
  baneeishaque SonarCloud organization.
- Skip the analysis until a SONAR_TOKEN secret exists; the coupled
  sonar-project.properties defines the project key, source exclusions,
  and coverage report path the scanner reads.
EOF

cat > "$S/msg-12.txt" <<'EOF'
ci(security): add repository-wide ShellCheck and Hadolint workflow

- Extend shell linting beyond the scripts checked by the build
  workflow to every shell script in the repository.
- Lint .gitpod.Dockerfile with Hadolint; both jobs stay advisory.
EOF

cat > "$S/msg-13.txt" <<'EOF'
ci(ai): add PR-Agent review workflow

- Review pull requests and answer commands with PR-Agent through
  GitHub Models using the workflow GITHUB_TOKEN and the models read
  permission, so no API key secret is required.
- Skip bot senders and keep the job advisory while the model endpoint
  integration proves stable.
EOF

cat > "$S/msg-14.txt" <<'EOF'
chore(coderabbit): add CodeRabbit review configuration

- Enable free CodeRabbit reviews for master with the assertive profile
  and incremental reviews on updates.
- Turn on the bundled actionlint, checkov, detekt, gitleaks, hadolint,
  osvScanner, semgrep, shellcheck, trivy, zizmor, and github-checks
  tools so hosted reviews match the CI scanners.
EOF

cat > "$S/msg-15.txt" <<'EOF'
chore(socket): add Socket.dev supply chain configuration

- Register the Gradle manifests as trigger paths and ignore build
  output directories.
- Enable pull request alerts and dependency overview reports for the
  free open source plan.
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

step "commit 11"
gitc add .github/workflows/sonarcloud.yml sonar-project.properties
gitc commit -F "$S/msg-11.txt"
expect_files 11 .github/workflows/sonarcloud.yml sonar-project.properties

step "commit 12"
gitc add .github/workflows/static-analysis.yml
gitc commit -F "$S/msg-12.txt"
expect_files 12 .github/workflows/static-analysis.yml

step "commit 13"
gitc add .github/workflows/pr-agent.yml
gitc commit -F "$S/msg-13.txt"
expect_files 13 .github/workflows/pr-agent.yml

step "commit 14"
gitc add .coderabbit.yaml
gitc commit -F "$S/msg-14.txt"
expect_files 14 .coderabbit.yaml

step "commit 15"
gitc add socket.yml
gitc commit -F "$S/msg-15.txt"
expect_files 15 socket.yml

step "post-state"
gitc log --oneline -16
gitc status --porcelain

printf '\nBATCH-3-EXECUTION-COMPLETE\n'
