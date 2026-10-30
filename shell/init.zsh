# profile selection is data, never executable shell code
_dotfiles_init() {
    local root="${${(%):-%x}:A:h:h}"
    local profile=""

    # remove only wrappers this loader installed, preserving later user overrides
    if [[ -n "${_DOTFILES_WORK_FX:-}" && "${functions[fx]-}" == "$_DOTFILES_WORK_FX" ]]; then
        unfunction fx
    fi
    if [[ -n "${_DOTFILES_PERSONAL_FX:-}" && "${functions[fx]-}" == "$_DOTFILES_PERSONAL_FX" ]]; then
        unfunction fx
    fi
    if [[ -n "${_DOTFILES_WORK_FXG:-}" && "${functions[fxg]-}" == "$_DOTFILES_WORK_FXG" ]]; then
        unfunction fxg
    fi
    if [[ -n "${_DOTFILES_WORK_CODEX:-}" && "${functions[codex]-}" == "$_DOTFILES_WORK_CODEX" ]]; then
        unfunction codex
    fi
    unset _DOTFILES_WORK_FX _DOTFILES_WORK_FXG _DOTFILES_WORK_CODEX _DOTFILES_PERSONAL_FX

    source "$root/utils/profile.sh" || return
    profile="$(dotfiles_profile)" || return
    unfunction dotfiles_profile

    source "$root/shell/common.zsh" || return
    if [[ -n "$profile" ]]; then
        source "$root/profiles/$profile/shell.zsh" || return
    fi
    if [[ -f "$HOME/.config/dotfiles/local.zsh" ]]; then
        source "$HOME/.config/dotfiles/local.zsh" || return
    fi
    return 0
}

_dotfiles_init
_dotfiles_status=$?
unfunction _dotfiles_init
return $_dotfiles_status
