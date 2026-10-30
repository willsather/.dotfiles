# scope work credentials to the invoked process, not the whole shell
fx() {
    local api_key
    api_key="$(op read --account vercel.1password.com "op://Employee/Vercel Labs AI Gateway Token/credential")" || return
    [[ -n "$api_key" ]] || return 1
    AI_GATEWAY_API_KEY="$api_key" command fx "$@"
}

codex() {
    local api_key
    api_key="$(op read --account vercel.1password.com "op://Employee/Vercel Labs AI Gateway Token/credential")" || return
    [[ -n "$api_key" ]] || return 1
    AI_GATEWAY_API_KEY="$api_key" command codex "$@"
}

typeset -g _DOTFILES_WORK_FX="${functions[fx]}"
typeset -g _DOTFILES_WORK_CODEX="${functions[codex]}"

# managed laptops can already initialize socket in their local .zshrc
if [[ "${DOTFILES_SOCKET_MANAGED_LOCALLY:-0}" != 1 && -f "$HOME/.config/socket-firewall/env.sh" ]]; then
    source "$HOME/.config/socket-firewall/env.sh"
fi
