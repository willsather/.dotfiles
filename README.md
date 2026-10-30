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

On work, `fx` runs the native CLI with its own authentication, while `fxg` runs it with the Vercel AI Gateway credential. On personal, `fx` uses that gateway wrapper directly; no `fxg` alias is added. Both gateway wrappers read the same 1Password item from the `vercel.1password.com` account and scope the credential to the invoked process. The personal Mac therefore needs access to that account/item. Claude/Codex settings and the `codex` credential wrapper remain work-only; personal does not install them. Automatic installer work-to-personal switching is refused.

## Files

- `config/`: shared home-directory preferences for Ghostty, Git, editors, and pnpm. Linked separately with Stow; Claude instructions are linked only for work.
- `shell/common.zsh`: shared aliases, paths, plugins, and helpers.
- `shell/theme.zsh`: shared Vercel palette and single-line directory/Git/triangle prompt.
- `shell/init.zsh`: loads common settings, the selected profile, and optional `~/.config/dotfiles/local.zsh`.
- `profiles/work/` and `profiles/personal/`: profile-specific shell and application settings.
- `utils/profile.sh`: profile selection, compatible with Bash and Zsh.
- `utils/profiles.sh`: small installer, compatible with macOS system Bash 3.2.

Only the individual Claude/Codex config files are linked. Auth, sessions, caches, plugins, skills, and local tool settings are left alone. Secrets stay outside Git and are fetched only when invoking a work tool.

## Terminal appearance

Both work and personal use the same Vercel-inspired setup, based on the [Geist terminal guide](https://vercel.com/geist/terminal). No demo or experiment helpers are loaded or retained.

There is no extra blank separator before the prompt. The prompt stays on one line and shows only the current directory name in bold teal and the Git branch in parentheses: `project (main) ▲`. The entire `(branch)` is amber for staged, unstaged, or untracked changes; otherwise green when local commits are ahead of the configured upstream, and gray when not ahead or no upstream is configured. Uncommitted changes take priority over unpushed commits. There is no asterisk. Ahead status uses the locally known upstream without fetching on each prompt; it does not separately flag a branch that is only behind. Outside Git, the branch is omitted. Detached HEAD shows its short commit instead. The triangle turns red after a failed command. Autosuggestions use the quiet palette color.

Shared Zsh applies the 16 Geist ANSI accent colors to interactive terminals, including Rex, at startup. It leaves base foreground/background colors to the terminal app and resets earlier shell overrides to app defaults. It selects the light or dark accent palette from macOS appearance. The white blinking cursor is reasserted at every prompt and line-edit entry because programs can reset cursor settings. Font, padding, selection colors, and app chrome are terminal-app settings rather than Zsh settings.

Ghostty's shared config uses the installed Geist Mono at 13pt with 5% extra line height across all terminal rows, 8pt horizontal padding with no vertical padding or automatic padding balancing, Geist light/dark accent palettes with app-default base colors, and a white blinking cursor. Shared Zsh also requests a white blinking cursor in other supporting terminals. Link it on each Mac with `dot link-shared --dry-run`, then `dot link-shared` after reviewing any conflicts. The existing macOS Application Support config remains separate for local keybindings and other overrides. Ghostty reloads with `Cmd+Shift+,`; open a new tab for the new shell prompt. In other apps, open a new Zsh tab or run `exec zsh` to pick up the shared prompt and colors. Rex's native UI theme/font preferences are not changed by the shell palette.

This uses native Zsh and the existing Geist Mono font, not Starship or the Nerd Font variant. No extra packages are required.

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

It excludes `.zshrc` and work AI settings and does not link whole directories. Personal also excludes all Claude/Codex configs so linking cannot recreate their home directories. It was not run during the work-profile migration.

`dot bootstrap --profile personal` is the explicit full setup: Homebrew/packages, Oh My Zsh, shared linking, and macOS defaults. Review `Brewfile` and `macos/defaults.sh` first; do not use it for small changes on a managed work machine. Its `--dry-run` option is rejected because it cannot preview every system effect.

Existing package commands remain available: `dot add`, `dot remove`, `dot list`, `dot dump`, and `dot upgrade`. The root `Brewfile` contains shared packages. Bootstrap also installs `profiles/<profile>/Brewfile` when present; Claude Code is work-only in `profiles/work/Brewfile`. Personal does not install Claude or Codex. A direct `brew bundle` in the repo installs only shared packages. Avoid `dot cleanup` on managed Macs: it can remove installed packages outside the Brewfile without distinguishing company-owned software.
