# Dotfiles

One repo for work and personal Macs. Bash installs configs; your interactive shell stays Zsh. No Python dependency.

## Setup

Clone to `~/.dotfiles`, then preview before applying:

```sh
./dot init --dry-run
./dot init
./dot doctor
```

`init` and `apply` only configure the profile selection, shell loader, and selected AI settings links. They do not install packages, change macOS defaults, invoke credential helpers, or modify company-managed software.

## Profiles

Selection uses an explicit `--profile`, then the saved `~/.config/dotfiles/profile`, then these hostname defaults:

| Hostname pattern | Profile |
|---|---|
| `Wills-Work-MacBook-Pro*` | `work` |
| `Wills-MacBook-Pro*` | `personal` |

Matching ignores case. The two patterns live in `utils/profile.sh`, shared by the Bash installer and Zsh loader. Applying saves the selection locally; a hostname change will not switch a saved profile. Invalid selections fail closed. Unknown hosts require `--profile work` or `--profile personal` to install, and load only common shell settings without a saved selection.

```sh
dot init --profile personal --dry-run
dot apply --dry-run
dot apply
dot doctor
```

Work uses Claude/Codex settings and credential wrappers under `profiles/work/`. Personal does not install those settings or inject work credentials. Automatic work-to-personal switching is refused.

## Files

- `config/`: shared home-directory preferences for Git, editors, pnpm, and general Claude instructions. Linked separately with Stow.
- `shell/common.zsh`: shared aliases, paths, plugins, and helpers.
- `shell/init.zsh`: loads common settings, the selected profile, and optional `~/.config/dotfiles/local.zsh`.
- `profiles/work/` and `profiles/personal/`: profile-specific shell and application settings.
- `utils/profile.sh`: profile selection, compatible with Bash and Zsh.
- `utils/profiles.sh`: small installer, compatible with macOS system Bash 3.2.

Only the individual Claude/Codex config files are linked. Auth, sessions, caches, plugins, skills, and local tool settings are left alone. Secrets stay outside Git and are fetched only when invoking a work tool.

## Local shell and existing configs

`~/.zshrc` stays a local regular file so MDM can edit it. Already-configured shell files are never rewritten. A new or empty file gets this block at the top:

```sh
# begin dotfiles loader
DOTFILES_SOCKET_MANAGED_LOCALLY=0
source "$HOME/.dotfiles/shell/init.zsh"
# end dotfiles loader
```

Unfamiliar existing shell files and conflicting tool configs are refused, not automatically migrated. For an older setup, back it up and manually replace its old shared configuration with this block, preserving machine-specific additions below it. If those additions already source Socket Firewall, set `DOTFILES_SOCKET_MANAGED_LOCALLY=1` so the work profile does not initialize it twice. Do not remove or disable company-managed security configuration.

Open a new terminal or run `source ~/.zshrc` after setup.

## Safety and backups

Dry-run and `doctor` write nothing. All destinations are checked before applying. Only absent tool configs or identical regular-file copies can become work-profile links; unexpected symlinks and differing files are refused. Existing correct links stay untouched.

Each nonempty apply backs up affected regular files with their original modes under `~/.local/state/dotfiles/backups/<timestamp>/files/`. `previously-absent` lists newly created destinations. Original files are checked again before replacement. Each replacement is atomic, but the entire run is not a transaction. There is no automatic rollback: on failure, inspect the printed backup and any completed changes before restoring manually. Preserve newer MDM edits. Existing backups from the earlier installer remain usable and may also contain `manifest.json`.

## Shared configs and full bootstrap

Shared config linking is separate, requires GNU Stow, and refuses conflicts:

```sh
dot link-shared --dry-run
dot link-shared
```

It excludes `.zshrc` and work AI settings and does not link whole directories. It was not run during the work-profile migration.

`dot bootstrap --profile personal` is the explicit full setup: Homebrew/packages, Oh My Zsh, shared linking, and macOS defaults. Review `Brewfile` and `macos/defaults.sh` first; do not use it for small changes on a managed work machine. Its `--dry-run` option is rejected because it cannot preview every system effect.

Existing package commands remain available: `dot add`, `dot remove`, `dot list`, `dot dump`, and `dot upgrade`. The Brewfile is not split by profile. Avoid `dot cleanup` on managed Macs: it can remove installed packages outside the Brewfile without distinguishing company-owned software.
