# shared by bash and zsh; print the selected profile without loading tool config
dotfiles_profile() {
    local requested="${1:-}" saved="" host profile_file="$HOME/.config/dotfiles/profile"
    if [ -L "$profile_file" ]; then
        printf '%s\n' 'dotfiles: profile must be a local regular file' >&2
        return 1
    fi
    if [ -e "$profile_file" ]; then
        if [ ! -f "$profile_file" ] || [ ! -r "$profile_file" ]; then
            printf '%s\n' 'dotfiles: profile must be a readable regular file' >&2
            return 1
        fi
        saved=$(cat "$profile_file") || return
        case "$saved" in
            work|personal) ;;
            *) printf '%s\n' 'dotfiles: invalid saved profile' >&2; return 1 ;;
        esac
    fi
    if [ "$saved" = work ] && [ -n "$requested" ] && [ "$requested" != work ]; then
        printf '%s\n' 'dotfiles: refusing automatic work-to-personal switching' >&2
        return 1
    fi
    if [ -n "$requested" ] || [ -n "$saved" ]; then
        case "${requested:-$saved}" in
            work|personal) printf '%s\n' "${requested:-$saved}" ;;
            *) printf '%s\n' 'dotfiles: expected work or personal' >&2; return 1 ;;
        esac
        return
    fi
    host=$(hostname | tr '[:upper:]' '[:lower:]') || return
    case "$host" in
        wills-work-macbook-pro*) printf '%s\n' work ;;
        wills-macbook-pro*) printf '%s\n' personal ;;
    esac
    return 0
}
