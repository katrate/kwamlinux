#!/bin/bash
# Bash completion for Came Linux package manager (kwamlinux)

_kwamlinux_complete() {
    local cur prev words cword
    _init_completion || return

    local commands="install i remove r update upgrade search s info list orphans clean security windows harden audit mirror status logs version help"

    case $cword in
        1)
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
            return ;;
        2)
            case $prev in
                install|i|info|search|s)
                    COMPREPLY=($(compgen -W "$(pacman -Ssq 2>/dev/null | head -100)" -- "$cur"))
                    return ;;
                remove|r)
                    COMPREPLY=($(compgen -W "$(pacman -Qq 2>/dev/null)" -- "$cur"))
                    return ;;
                security|sec)
                    COMPREPLY=($(compgen -W "install list update" -- "$cur"))
                    return ;;
                windows|win)
                    COMPREPLY=($(compgen -W "install list run" -- "$cur"))
                    return ;;
            esac ;;
    esac
}

complete -F _kwamlinux_complete kwamlinux
