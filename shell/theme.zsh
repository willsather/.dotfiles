[[ -o interactive ]] || return 0

_vercel_prompt() {
    local last_status=$? branch="" branch_color=8 ahead=0 triangle='▲'
    branch="$(GIT_OPTIONAL_LOCKS=0 command git symbolic-ref --quiet --short HEAD 2>/dev/null)" ||
        branch="$(GIT_OPTIONAL_LOCKS=0 command git rev-parse --short HEAD 2>/dev/null)" || branch=""
    if [[ -n "$branch" ]]; then
        branch="${branch//\%/%%}"
        if [[ -n "$(GIT_OPTIONAL_LOCKS=0 command git status --porcelain --ignore-submodules=dirty 2>/dev/null)" ]]; then
            branch_color=3
        else
            ahead="$(GIT_OPTIONAL_LOCKS=0 command git rev-list --count '@{upstream}..HEAD' 2>/dev/null)" || ahead=0
            (( ahead > 0 )) && branch_color=2
        fi
        branch=" %F{${branch_color}}(${branch})%f"
    fi
    (( last_status == 0 )) || triangle='%B%F{1}▲%f%b'
    PROMPT="%B%F{6}%1~%f%b${branch} ${triangle} "
    _vercel_cursor
    return 0
}

# apps can reset cursor colors; restore white when returning to the prompt
_vercel_cursor() {
    [[ ! -t 1 ]] || printf '\033]12;#ffffff\007\033[?12h'
}

_vercel_terminal_colors() {
    [[ -t 1 ]] || return 0
    local root="${${(%):-%x}:A:h:h}" mode=dark key value index color
    printf '\033]110\007\033]111\007'
    if [[ "$OSTYPE" == darwin* && "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" != Dark ]]; then
        mode=light
    fi
    while IFS='=' read -r key value; do
        key="${key//[[:space:]]/}"
        value="${value//[[:space:]]/}"
        case "$key" in
            palette)
                index="${value%%=*}"
                color="${value#*=}"
                printf '\033]4;%s;%s\007' "$index" "$color"
                ;;
        esac
    done < "$root/config/.config/ghostty/themes/vercel-$mode.ghostty"
    _vercel_cursor
}

# build the prompt directly so git branch text is never evaluated as shell code
unsetopt prompt_subst
RPROMPT=''
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
autoload -Uz add-zsh-hook add-zle-hook-widget
add-zsh-hook -d precmd _vercel_prompt
add-zsh-hook precmd _vercel_prompt
add-zle-hook-widget -d line-init _vercel_cursor
add-zle-hook-widget line-init _vercel_cursor
_vercel_terminal_colors
_vercel_prompt
