# Security

## Reporting a vulnerability

Use the repository's **Security** tab to open a private vulnerability report
("Report a vulnerability"). Do not open a public issue for security problems.

## Automated security scanning

This repository runs a layered, zero-cost security stack built on capabilities
that are free for public repositories. Every scanner runs on pull requests, on
pushes to `master`, and on a weekly schedule unless noted otherwise.

| Workflow | Tool | Findings destination | Blocking |
| --- | --- | --- | --- |
| `codeql.yml` | CodeQL for Java/Kotlin (`security-extended` + `security-and-quality`) | Code scanning alerts | No |
| `semgrep.yml` | Semgrep OSS (`auto`, `security-audit`, `owasp-top-ten`, `secrets`) | Code scanning alerts | No |
| `trivy.yml` | Trivy (vulnerabilities, secrets, misconfiguration, licenses) + CycloneDX SBOM artifact | Code scanning alerts + artifact | No |
| `iac-security.yml` | Checkov + KICS | Code scanning alerts | No |
| `gitleaks.yml` | Gitleaks | PR comments + SARIF artifact | No |
| `dependency-review.yml` | GitHub Dependency Review | PR check | Yes, on new `high` or `critical` advisories |
| `scorecard.yml` | OpenSSF Scorecard | Code scanning alerts + public score | No |
| `zizmor.yml` | zizmor (GitHub Actions audit, `auditor` persona) | Code scanning alerts | No |
| `static-analysis.yml` | ShellCheck (repository-wide) + Hadolint | Workflow annotations | No |
| `pr-agent.yml` | PR-Agent AI review via GitHub Models | PR comments | No |
| `snyk.yml` | Snyk Code + Snyk Open Source (runs only when `SNYK_TOKEN` is set) | Code scanning alerts | No |
| `sonarcloud.yml` | SonarCloud (runs only when `SONAR_TOKEN` is set) | SonarCloud dashboard | No |
| `gradle-build.yml` | actionlint + ShellCheck for `.github/scripts` | Workflow annotations | Yes |

Dependabot alerts, security updates, secret scanning, and secret scanning push
protection are enabled for this repository. CodeQL uses the advanced workflow
above, so **do not enable CodeQL default setup** (the two are mutually
exclusive).

## Manual steps to complete the setup

The repository files are ready; these external activations are still required:

1. **CodeRabbit** (AI pull request review, free for public repositories):
   install the CodeRabbit GitHub App on this repository. Configuration is in
   `.coderabbit.yaml`.
2. **Socket.dev** (supply chain security, free for open source): install the
   Socket GitHub App on this repository. Configuration is in `socket.yml`.
3. **Snyk** (optional): create a free Snyk account and add a repository secret
   named `SNYK_TOKEN`.
4. **SonarCloud** (optional): create a project at <https://sonarcloud.io> for
   `Baneeishaque/account-ledger-cli-kotlin`, then add a repository secret named
   `SONAR_TOKEN`. Configuration is in `sonar-project.properties`.
5. **PR-Agent** works without extra secrets by using GitHub Models with the
   workflow `GITHUB_TOKEN` (`models: read` permission). To use a different
   provider, set the corresponding secret and update the environment variables
   in `.github/workflows/pr-agent.yml`.

## Notes

- SARIF uploads to code scanning are skipped for pull requests from forks and
  for Dependabot pull requests, because those runs receive a read-only
  `GITHUB_TOKEN`. The scans still run on `master` pushes and the weekly
  schedule.
- All scanners except Dependency Review are advisory and do not block merges.
- Only free-for-public-repository features are used. No GitHub Advanced
  Security, GitHub Code Security, GitHub Secret Protection, or Copilot license
  is required.
