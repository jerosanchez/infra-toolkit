#!/bin/bash

get_log_file_path() {
    local role_name="$1"
    local script_name="$2"
    local log_file_name="${script_name%.sh}"
    echo "/var/log/${role_name}-${log_file_name}.log"
}

schedule() {
    local role_name="$1"
    local script_name="$2"
    local cron_time="$3"
    local script_path="/opt/${role_name}/${script_name}"

    local log_file
    log_file="$(get_log_file_path "$role_name" "$script_name")"
    local cron_line="${cron_time} ${script_path} >${log_file} 2>&1"
    
    log INFO "Scheduling cron job for $script_name..."

    # Remove any existing cron job for this script, then add the new one
    (sudo crontab -l 2>/dev/null | grep -v "${script_path}" || true; echo "$cron_line") | sudo crontab -
}

unschedule() {
    local role_name="$1"
    local script_name="$2"
    local script_path="/opt/${role_name}/${script_name}"

    log INFO "Removing cron job for $script_name..."

    # Remove any existing cron job for this script
    (sudo crontab -l 2>/dev/null | grep -v "${script_path}" || true; echo "") | sudo crontab -
}