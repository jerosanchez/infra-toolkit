#!/bin/bash

log() {
    # Usage: log LEVEL MESSAGE
    # Example: log INFO "This is an info message"
    local level="$1"
    shift
    local msg="$*"
    local color_reset="\033[0m"
    local color=""

    # Define log level priorities
    declare -A LOG_LEVELS=([NONE]=0 [ERROR]=1 [WARN]=2 [INFO]=3 [DEBUG]=4)
    local LOG_LEVEL_ENV="${LOG_LEVEL:-INFO}"
    local LOG_LEVEL_PRIORITY=${LOG_LEVELS[$LOG_LEVEL_ENV]:-3}
    local MSG_LEVEL_PRIORITY=${LOG_LEVELS[$level]:-3}

    local caller_script="$(basename "${BASH_SOURCE[1]}")"

    # If LOG_LEVEL is NONE or message is lower priority, do not print
    if [ "$LOG_LEVEL_PRIORITY" -eq 0 ] || [ "$MSG_LEVEL_PRIORITY" -gt "$LOG_LEVEL_PRIORITY" ]; then
        return
    fi

    case "$level" in
        INFO)
            color="\033[1;34m" # Blue
            ;;
        DEBUG)
            color="\033[1;35m" # Magenta
            ;;
        WARN)
            color="\033[1;33m" # Yellow
            ;;
        ERROR)
            color="\033[1;31m" # Red
            ;;
        *)
            color=""
            ;;
    esac

    if [ "$LOG_LEVEL_ENV" = "DEBUG" ]; then
        echo -e "${color}[$level]${color_reset} [$caller_script] $msg"
    else
        echo -e "${color}[$level]${color_reset} $msg"
    fi
}