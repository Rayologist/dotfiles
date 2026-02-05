if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    return 0
fi

autoload -Uz add-zsh-hook 2>/dev/null

# this variable is only 1 when preexec has been run in this round
typeset -g _omp_cmd_seen=0

function _omp_preexec_flag() {
    _omp_cmd_seen=1
}

function _omp_precmd_flag() {
    if (( _omp_cmd_seen )); then
    export OMP_RENDER_STATUS=1
    else
    export OMP_RENDER_STATUS=0
    fi
    _omp_cmd_seen=0
}

add-zsh-hook preexec _omp_preexec_flag
add-zsh-hook precmd  _omp_precmd_flag
