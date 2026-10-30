# personal fx uses the gateway; claude and codex remain work-only
fx() {
    local api_key
    api_key="$(op read --account vercel.1password.com "op://Employee/Vercel Labs AI Gateway Token/credential")" || return
    [[ -n "$api_key" ]] || return 1
    AI_GATEWAY_API_KEY="$api_key" command fx "$@"
}

typeset -g _DOTFILES_PERSONAL_FX="${functions[fx]}"
