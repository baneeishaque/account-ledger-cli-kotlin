#!/usr/bin/env bash
# Generates the full Arranged Commits Preview artifact for the session that
# added the free security-scanning stack to account-ledger-cli-kotlin.
#
# Read-only with respect to the repository: every embedded diff comes from a
# `git diff` invocation. The only file written is the preview path passed as $1.
#
# Usage: generate-preview.sh <output-file>
set -u

R=/workspaces/account-ledger-cli-kotlin
OUT="${1:?usage: generate-preview.sh <output-file>}"

new_file_diff() {
  local f="$1"
  git -C "$R" diff --no-index -- /dev/null "$f" \
    | sed -e "1s|^diff --git a/dev/null b/${f}\$|diff --git a/${f} b/${f}|"
}

section() {
  printf '\n### Commit %s: %s\n' "$1" "$2"
  printf -- '- **Files**: %s\n' "$3"
  printf -- '- **Staging**: %s\n' "$4"
  printf -- '- **Message**:\n\n```\n'
}

end_message() {
  printf '```\n'
}

hunks() {
  printf -- '- **Hunks/Preview**:\n\n'
}

diff_new() {
  printf '~~~diff\n'
  new_file_diff "$1"
  printf '~~~\n'
}

diff_tracked() {
  printf '~~~diff\n'
  git -C "$R" diff --unified=3 -- "$1"
  printf '~~~\n'
}

{
  cat <<'HDR'
# Arranged Commits Preview

- Repository: /workspaces/account-ledger-cli-kotlin
- Branch: master (in sync with origin/master after fetch)
- Session: ef21faca8ffelvH86MqzpckSh
- Prepared: 2026-10-06
- Scope: only changes authored in this session. Pre-existing working-tree
  edits to build.gradle.kts, gradle.properties, gradle/libs.versions.toml,
  gradle/wrapper/gradle-wrapper.properties, mise.toml, settings.gradle.kts,
  and .github/workflows/gradle-build.yml are excluded from every commit.
- Execution: 4 batches, max 5 commits each; every batch needs its own
  "start". Before batch 1 executes, a safety stash is captured with
  `git stash push -u` + immediate `git stash apply` (never pop) per the
  git-pre-execution-safety-stash protocol.
- Note: the `scratch/` tree is ignored via commit 1; the preview file and
  the generator that produced it live under
  `scratch/ef21faca8ffelvH86vMqzpckSh/` and are never committed.

## Master Plan

| # | Commit | Files | Batch |
|---|--------|-------|-------|
| 1 | chore: ignore scratch directory | .gitignore | 1 |
| 2 | ci(security): add CodeQL code scanning workflow | .github/workflows/codeql.yml | 1 |
| 3 | ci(security): add Semgrep OSS scanning workflow | .github/workflows/semgrep.yml | 1 |
| 4 | ci(security): add Trivy vulnerability and secret scanning workflow | .github/workflows/trivy.yml | 1 |
| 5 | ci(security): add Checkov and KICS IaC scanning workflows | .github/workflows/iac-security.yml | 1 |
| 6 | ci(security): add Gitleaks secret scanning workflow | .github/workflows/gitleaks.yml | 2 |
| 7 | ci(security): add OpenSSF Scorecard workflow | .github/workflows/scorecard.yml | 2 |
| 8 | ci(security): add dependency review workflow | .github/workflows/dependency-review.yml | 2 |
| 9 | ci(security): add zizmor GitHub Actions audit workflow | .github/workflows/zizmor.yml | 2 |
| 10 | ci(security): add Snyk Code and open source scanning workflow | .github/workflows/snyk.yml | 2 |
| 11 | ci(security): add SonarCloud analysis workflow and configuration | .github/workflows/sonarcloud.yml, sonar-project.properties | 3 |
| 12 | ci(security): add repository-wide ShellCheck and Hadolint workflow | .github/workflows/static-analysis.yml | 3 |
| 13 | ci(ai): add PR-Agent review workflow | .github/workflows/pr-agent.yml | 3 |
| 14 | chore(coderabbit): add CodeRabbit review configuration | .coderabbit.yaml | 3 |
| 15 | chore(socket): add Socket.dev supply chain configuration | socket.yml | 3 |
| 16 | docs: correct stale CI workflow reference in GEMINI.md | GEMINI.md | 4 |
| 17 | docs(security): add security scanning documentation | SECURITY.md | 4 |
| 18 | docs(security): document security scanning stack in GEMINI.md | GEMINI.md | 4 |
HDR

  section 1 "chore: ignore scratch directory" ".gitignore" 'git add .gitignore'
  cat <<'MSG'
chore: ignore scratch directory

- Keep session-scoped scratch artifacts out of version control.
- The scratch tree holds commit previews and command output captured
  during agent sessions.
MSG
  end_message
  hunks
  diff_tracked .gitignore

  section 2 "ci(security): add CodeQL code scanning workflow" ".github/workflows/codeql.yml" 'git add .github/workflows/codeql.yml'
  cat <<'MSG'
ci(security): add CodeQL code scanning workflow

- Run the security-extended and security-and-quality query suites for
  Java/Kotlin on pushes, pull requests, and a weekly schedule.
- Build the cli-app classes with the Gradle wrapper on Temurin 21, the
  compatibility level declared by the build, so extraction sees
  compiled sources.
- Keep the advanced workflow as the only CodeQL setup; default setup
  stays disabled to avoid conflicting analyses.
MSG
  end_message
  hunks
  diff_new .github/workflows/codeql.yml

  section 3 "ci(security): add Semgrep OSS scanning workflow" ".github/workflows/semgrep.yml" 'git add .github/workflows/semgrep.yml'
  cat <<'MSG'
ci(security): add Semgrep OSS scanning workflow

- Scan with the auto, security-audit, owasp-top-ten, and secrets
  rulesets using the pinned Semgrep container.
- Upload SARIF findings to code scanning and keep the job advisory so
  new findings never block merges.
MSG
  end_message
  hunks
  diff_new .github/workflows/semgrep.yml

  section 4 "ci(security): add Trivy vulnerability and secret scanning workflow" ".github/workflows/trivy.yml" 'git add .github/workflows/trivy.yml'
  cat <<'MSG'
ci(security): add Trivy vulnerability and secret scanning workflow

- Scan the filesystem for vulnerabilities, secrets, misconfiguration,
  and license issues with the pinned Trivy action.
- Publish SARIF results to code scanning and retain a CycloneDX SBOM
  artifact for supply chain review.
MSG
  end_message
  hunks
  diff_new .github/workflows/trivy.yml

  section 5 "ci(security): add Checkov and KICS IaC scanning workflows" ".github/workflows/iac-security.yml" 'git add .github/workflows/iac-security.yml'
  cat <<'MSG'
ci(security): add Checkov and KICS IaC scanning workflows

- Analyze Dockerfiles, workflow files, and devcontainer configuration
  for infrastructure-as-code weaknesses with Checkov and KICS.
- Keep both jobs advisory and publish SARIF results under distinct
  code scanning categories.
MSG
  end_message
  hunks
  diff_new .github/workflows/iac-security.yml

  section 6 "ci(security): add Gitleaks secret scanning workflow" ".github/workflows/gitleaks.yml" 'git add .github/workflows/gitleaks.yml'
  cat <<'MSG'
ci(security): add Gitleaks secret scanning workflow

- Scan full history on pushes, pull requests, and a weekly schedule.
- The action runs without a license key for personal accounts and
  complements native secret scanning push protection.
MSG
  end_message
  hunks
  diff_new .github/workflows/gitleaks.yml

  section 7 "ci(security): add OpenSSF Scorecard workflow" ".github/workflows/scorecard.yml" 'git add .github/workflows/scorecard.yml'
  cat <<'MSG'
ci(security): add OpenSSF Scorecard workflow

- Analyze repository security practices on branch protection changes,
  pushes, and a weekly schedule.
- Publish the public score and upload SARIF results with the OIDC and
  security-events permissions the action requires.
MSG
  end_message
  hunks
  diff_new .github/workflows/scorecard.yml

  section 8 "ci(security): add dependency review workflow" ".github/workflows/dependency-review.yml" 'git add .github/workflows/dependency-review.yml'
  cat <<'MSG'
ci(security): add dependency review workflow

- Block pull requests that introduce dependencies with high or
  critical advisories; this is the only gating scanner in the stack.
- Disable the pull request summary comment so review threads stay
  clean, leaving the check result as the verdict.
MSG
  end_message
  hunks
  diff_new .github/workflows/dependency-review.yml

  section 9 "ci(security): add zizmor GitHub Actions audit workflow" ".github/workflows/zizmor.yml" 'git add .github/workflows/zizmor.yml'
  cat <<'MSG'
ci(security): add zizmor GitHub Actions audit workflow

- Audit every workflow file for supply chain and security weaknesses
  with the auditor persona and online audits enabled.
- Publish findings to code scanning through the advanced security
  integration.
MSG
  end_message
  hunks
  diff_new .github/workflows/zizmor.yml

  section 10 "ci(security): add Snyk Code and open source scanning workflow" ".github/workflows/snyk.yml" 'git add .github/workflows/snyk.yml'
  cat <<'MSG'
ci(security): add Snyk Code and open source scanning workflow

- Run Snyk Code and Snyk Open Source with SARIF output for code
  scanning.
- Skip both scans until a SNYK_TOKEN secret exists so the workflow is
  safe to merge before the free account is connected.
MSG
  end_message
  hunks
  diff_new .github/workflows/snyk.yml

  section 11 "ci(security): add SonarCloud analysis workflow and configuration" ".github/workflows/sonarcloud.yml, sonar-project.properties" 'git add .github/workflows/sonarcloud.yml sonar-project.properties'
  cat <<'MSG'
ci(security): add SonarCloud analysis workflow and configuration

- Analyze cli-app with JaCoCo coverage and publish to the
  baneeishaque SonarCloud organization.
- Skip the analysis until a SONAR_TOKEN secret exists; the coupled
  sonar-project.properties defines the project key, source exclusions,
  and coverage report path the scanner reads.
MSG
  end_message
  hunks
  diff_new .github/workflows/sonarcloud.yml
  diff_new sonar-project.properties

  section 12 "ci(security): add repository-wide ShellCheck and Hadolint workflow" ".github/workflows/static-analysis.yml" 'git add .github/workflows/static-analysis.yml'
  cat <<'MSG'
ci(security): add repository-wide ShellCheck and Hadolint workflow

- Extend shell linting beyond the scripts checked by the build
  workflow to every shell script in the repository.
- Lint .gitpod.Dockerfile with Hadolint; both jobs stay advisory.
MSG
  end_message
  hunks
  diff_new .github/workflows/static-analysis.yml

  section 13 "ci(ai): add PR-Agent review workflow" ".github/workflows/pr-agent.yml" 'git add .github/workflows/pr-agent.yml'
  cat <<'MSG'
ci(ai): add PR-Agent review workflow

- Review pull requests and answer commands with PR-Agent through
  GitHub Models using the workflow GITHUB_TOKEN and the models read
  permission, so no API key secret is required.
- Skip bot senders and keep the job advisory while the model endpoint
  integration proves stable.
MSG
  end_message
  hunks
  diff_new .github/workflows/pr-agent.yml

  section 14 "chore(coderabbit): add CodeRabbit review configuration" ".coderabbit.yaml" 'git add .coderabbit.yaml'
  cat <<'MSG'
chore(coderabbit): add CodeRabbit review configuration

- Enable free CodeRabbit reviews for master with the assertive profile
  and incremental reviews on updates.
- Turn on the bundled actionlint, checkov, detekt, gitleaks, hadolint,
  osvScanner, semgrep, shellcheck, trivy, zizmor, and github-checks
  tools so hosted reviews match the CI scanners.
MSG
  end_message
  hunks
  diff_new .coderabbit.yaml

  section 15 "chore(socket): add Socket.dev supply chain configuration" "socket.yml" 'git add socket.yml'
  cat <<'MSG'
chore(socket): add Socket.dev supply chain configuration

- Register the Gradle manifests as trigger paths and ignore build
  output directories.
- Enable pull request alerts and dependency overview reports for the
  free open source plan.
MSG
  end_message
  hunks
  diff_new socket.yml

  section 16 "docs: correct stale CI workflow reference in GEMINI.md" "GEMINI.md" 'scripted partial staging: stage-file-excluding-lines.py (excludes the Security Scanning block; see note below)'
  cat <<'MSG'
docs: correct stale CI workflow reference in GEMINI.md

- Point the CI/CD note at .github/workflows/gradle-build.yml, which
  runs actionlint, ShellCheck, and the Gradle build, instead of the
  removed gradle.yml path.
MSG
  end_message
  hunks
  diff_tracked GEMINI.md
  printf '\n> Split note: this single hunk carries both this commit and commit\n'
  printf '> 18. Commit 16 stages GEMINI.md with the Security Scanning block\n'
  printf '> excluded via stage-file-excluding-lines.py (excludes\n'
  printf '> "## Security Scanning" and the paragraph line, --blank-context 1);\n'
  printf '> commit 18 stages the remainder with a plain git add.\n'

  section 17 "docs(security): add security scanning documentation" "SECURITY.md" 'git add SECURITY.md'
  cat <<'MSG'
docs(security): add security scanning documentation

- Document each workflow, its findings destination, and whether it
  blocks merges so reviewers know where results appear.
- List the manual activations that remain: the CodeRabbit and Socket
  app installs and the optional Snyk and SonarCloud tokens.
MSG
  end_message
  hunks
  diff_new SECURITY.md

  section 18 "docs(security): document security scanning stack in GEMINI.md" "GEMINI.md" 'git add GEMINI.md (stages the block deferred by commit 16)'
  cat <<'MSG'
docs(security): document security scanning stack in GEMINI.md

- Add a Security Scanning section pointing to SECURITY.md for the
  inventory, required secrets, and manual activations so agents
  discover the stack from the repository guidance file.
MSG
  end_message
  hunks
  diff_tracked GEMINI.md
  printf '\n> Split note: after commit 16, the staged delta for this commit is\n'
  printf '> exactly the +## Security Scanning block shown above.\n'

  printf '\n---\nPlease say "start" to begin the sequential execution of batch 1.\n'
} > "$OUT"
