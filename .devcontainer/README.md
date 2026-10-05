# Dev Container

Development container configuration for the Account Ledger CLI Kotlin project.

## Configuration

Defined in [`devcontainer.json`](devcontainer.json).

| Property | Value | Description |
|---|---|---|
| `image` | `mcr.microsoft.com/devcontainers/base:3.0.8-ubuntu26.04` | Base image for the dev container |
| `postCreateCommand` | `mise trust --yes && mise install` | Installs toolchain declared in `mise.toml` after container creation |

## Toolchain

Managed via [mise](https://mise.jdx.dev) (`ghcr.io/devcontainers-extra/features/mise:1`):

- Java 27.0.0 (see [`mise.toml`](../mise.toml))

## Features

| Feature | Purpose |
|---|---|
| `devcontainers-extra/features/mise:1` | Runtime/tool version manager |
| `devcontainers/features/git-lfs:1` | Git Large File Storage support |
| `skriptfabrik/devcontainer-features/gitlab-cli:1` | GitLab CLI |
| `stu-bell/devcontainer-features/open-code:0` | opencode AI CLI |

Additional features are commented out in `devcontainer.json` and can be re-enabled as needed.

## VS Code Extensions

The container pre-installs extensions under `customizations.vscode.extensions`, grouped by purpose:

- **Source control** — GitLens, Git Graph equivalent (`renanbs.git-context-menu`), SemanticDiff, GitHub Actions, local actions runner
- **Kotlin/Gradle** — `fwcd.kotlin`, `r0kuko.vscode-gradle-kotlin`, `vscjava.vscode-gradle`, `mathiasfrohlich.kotlin`, `elumine.kotlin-jump`, `legendaryredfox.run-kotlin-vscode`, `victorchen.kotlin-java-language-server`, `jetbrains.intellij-server`
- **Language support** — YAML, JSON, BAT, Shell, INI, log, search-result, references-view, merge-conflict, git-base
- **Productivity** — bookmarks, file tools, spell checker, text power tools, material icon theme, opencode, gistpad
- **AI/Copilot** — `github.copilot-chat`

Some extensions are commented out; enable them by uncommenting the entries in the array.

## Usage

1. Open the repository in VS Code.
2. Run **Dev Containers: Reopen in Container** from the command palette.
3. Wait for `postCreateCommand` to finish installing the Java toolchain via mise.

## CI Validation

The dev container definition is validated by the [`Test Dev Container`](../.github/workflows/devcontainer-test.yml) GitHub Actions workflow.

| Property | Value |
|---|---|
| Workflow | `.github/workflows/devcontainer-test.yml` |
| Triggers | `push` / `pull_request` touching `.devcontainer/devcontainer.json` |
| Runner | `ubuntu-latest` |
| Job | `test-devcontainer` |

The job installs the [Dev Containers CLI](https://github.com/devcontainers/cli) (`@devcontainers/cli`) and runs `devcontainer build --workspace-folder .`, which fails if the container image or features cannot be built.

A commented-out step is available for smoke-testing tools inside the built container via `devcontainer exec` (for example `sdkmanager`, `adb`, `chrome`, `chromedriver`); uncomment it in the workflow to enable those checks.

> Note: the workflow only watches `.devcontainer/devcontainer.json`. Changes to other devcontainer files or `mise.toml` will not trigger it.

## Customization

- Add tools by editing [`mise.toml`](../mise.toml) — they are installed automatically on container creation.
- Add container-level tools via entries in the `features` object.
- Add VS Code extensions via `customizations.vscode.extensions`.
