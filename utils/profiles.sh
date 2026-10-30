#!/bin/bash
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/utils/profile.sh"
command_name="${1:-}"
shift
requested=""
dry_run=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile) [[ $# -ge 2 ]] || { echo 'missing --profile value' >&2; exit 1; }; requested="$2"; shift 2 ;;
        --dry-run) dry_run=true; shift ;;
        *) echo "unknown option: $1" >&2; exit 1 ;;
    esac
done
case "$command_name" in init|apply|doctor) ;; *) echo 'expected init, apply, or doctor' >&2; exit 1 ;; esac

fail() { echo "dotfiles: $*" >&2; exit 1; }
check_parents() {
    local parent="${1%/*}"
    while [[ "$parent" != "$HOME" ]]; do
        [[ "$parent" != / && -n "$parent" ]] || fail 'destination outside home'
        [[ ! -L "$parent" ]] || fail "symlinked parent: $parent"
        [[ ! -e "$parent" || -d "$parent" ]] || fail "not a directory: $parent"
        parent="${parent%/*}"
    done
}
fingerprint() {
    if [[ -L "$1" ]]; then printf 'link:'; readlink "$1"
    elif [[ -f "$1" ]]; then stat -f '%i:%p:%m:%c' "$1"; cksum < "$1"
    elif [[ -e "$1" ]]; then fail "not a regular file: $1"
    else printf 'missing\n'
    fi
}
paths=() kinds=() originals=()
queue() {
    check_parents "$1"
    originals[${#originals[@]}]="$(fingerprint "$1")"
    paths[${#paths[@]}]="$1"
    kinds[${#kinds[@]}]="$2"
}

check_parents "$HOME/.config/dotfiles/profile"
profile="$(dotfiles_profile "$requested")"
[[ -n "$profile" ]] || fail 'unknown hostname; select --profile work or --profile personal'
echo "Profile: $profile"
profile_file="$HOME/.config/dotfiles/profile"
if [[ ! -f "$profile_file" ]] || ! printf '%s\n' "$profile" | cmp -s - "$profile_file"; then
    queue "$profile_file" profile
fi

loader='# begin dotfiles loader
DOTFILES_SOCKET_MANAGED_LOCALLY=0
source "$HOME/.dotfiles/shell/init.zsh"
# end dotfiles loader'
local_socket_loader="${loader/DOTFILES_SOCKET_MANAGED_LOCALLY=0/DOTFILES_SOCKET_MANAGED_LOCALLY=1}"
shell_file="$HOME/.zshrc"
check_parents "$shell_file"
[[ ! -L "$shell_file" ]] || fail 'keep ~/.zshrc local; migrate its symlink manually first'
if [[ ! -e "$shell_file" || ( -f "$shell_file" && ! -s "$shell_file" ) ]]; then
    queue "$shell_file" shell
else
    [[ -f "$shell_file" ]] || fail 'not a regular file: ~/.zshrc'
    [[ "$(grep -Fxc '# begin dotfiles loader' "$shell_file" || true)" == 1 &&
       "$(grep -Fxc '# end dotfiles loader' "$shell_file" || true)" == 1 ]] ||
        fail 'unfamiliar ~/.zshrc; add the documented loader manually, preserving local/MDM settings'
    header="$(head -n 4 "$shell_file")"
    [[ "$header" == "$loader" || "$header" == "$local_socket_loader" ]] || fail 'expected the documented loader at the top of ~/.zshrc'
fi
if [[ "$profile" == personal ]]; then
    [[ ! -e "$HOME/.config/socket-firewall/env.sh" ]] || fail 'work security configuration detected'
    if [[ -f "$shell_file" ]] && grep -Eq 'socket-firewall|op://Employee/' "$shell_file"; then
        fail 'work shell configuration detected'
    fi
fi

for name in .claude/settings.json .codex/config.toml; do
    target="$HOME/$name"
    source="$ROOT/profiles/work/home/$name"
    check_parents "$target"
    [[ -f "$source" ]] || fail "missing profile config: $source"
    [[ ! -e "$target" || -f "$target" ]] || fail "not a regular config file: $target"
    if [[ "$profile" == personal ]]; then
        if [[ "$target" -ef "$source" ]] || cmp -s "$target" "$source" || [[ -L "$target" && ! -e "$target" ]]; then
            fail "work or dangling tool configuration requires manual migration: $target"
        fi
    elif [[ -L "$target" ]]; then
        [[ "$target" -ef "$source" ]] || fail "unexpected symlink; migrate manually: $target"
    elif [[ -e "$target" ]]; then
        [[ -f "$target" ]] && cmp -s "$target" "$source" || fail "conflicting config: $target"
        queue "$target" link
    else
        queue "$target" link
    fi
done

count=${#paths[@]}
if [[ "$count" -gt 0 ]]; then
    check_parents "$HOME/.local/state/dotfiles/backups/placeholder"
fi
for target in "${paths[@]}"; do echo "Needs update: $target"; done
if [[ "$command_name" == doctor ]]; then
    [[ "$count" == 0 ]] || exit 1
    echo 'OK: profile, local shell loader, and tool config links. Credentials not tested.'
    exit 0
fi
if "$dry_run"; then echo "Dry run: $count change(s); nothing written."; exit 0; fi
if [[ "$count" == 0 ]]; then echo 'No changes needed.'; exit 0; fi

umask 077
backup_root="$HOME/.local/state/dotfiles/backups"
mkdir -p "$backup_root"
backup="$(mktemp -d "$backup_root/$(date +%Y%m%d-%H%M%S)-XXXXXX")"
echo "Backup: $backup"
for ((i=0; i<count; i++)); do
    target="${paths[i]}"
    check_parents "$target"
    [[ "$(fingerprint "$target")" == "${originals[i]}" ]] || fail "changed since preview: $target"
    if [[ -f "$target" ]]; then
        relative="${target#"$HOME/"}"
        backup_file="$backup/files/$relative"
        mkdir -p "${backup_file%/*}"
        cp -p "$target" "$backup_file"
    else
        printf '%s\n' "$target" >> "$backup/previously-absent"
    fi
done

temporary=""
trap '[[ -z "$temporary" ]] || rm -f -- "$temporary"' EXIT
for ((i=0; i<count; i++)); do
    target="${paths[i]}"
    check_parents "$target"
    [[ "$(fingerprint "$target")" == "${originals[i]}" ]] || fail "concurrent change; left untouched: $target; backup: $backup"
    mkdir -p "${target%/*}"
    temporary="$(mktemp "${target%/*}/.dotfiles-XXXXXX")"
    case "${kinds[i]}" in
        profile) printf '%s\n' "$profile" > "$temporary" ;;
        shell)
            printf '%s\n' "$loader" > "$temporary"
            chmod 644 "$temporary"
            ;;
        link)
            rm "$temporary"
            ln -s "$ROOT/profiles/work/home/${target#"$HOME/"}" "$temporary"
            ;;
    esac
    mv -f "$temporary" "$target"
    temporary=""
done
echo "Applied $count change(s). No packages or system settings changed."
