#!/bin/bash

function list_users {
    echo "List of users"
    awk -F: '$3 >= 1000 { print $1, $6 }' /etc/passwd | sort
}

function list_processes {
    echo "List of processes"
    ps -eo pid,comm --sort=pid
}

function show_help {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -u, --users            List users and their home directories"
    echo "  -p, --processes        List running processes"
    echo "  -h, --help             Show this help message"
    echo "  -l PATH, --log PATH    Redirect output to a file at PATH"
    echo "  -e PATH, --errors PATH Redirect error output to a file at PATH"
}

log_path=""
error_path=""
action=""


log_error() {
    local message="$1"
    if [[ -n "$error_path" ]]; then
        echo "Error: $message" >> "$error_path"
    else
        echo "Error: $message" >&2
    fi
}

while getopts ":uphl:e:-:" opt; do
    case $opt in
        u)
            action="users"
            ;;
        p)
            action="processes"
            ;;
        h)
            show_help
            exit 0
            ;;
        l)
            if [[ -z "$OPTARG" ]]; then
                echo "Option -l requires an argument." >&2
                exit 1
            fi
            log_path="$OPTARG"
            ;;
        e)
            if [[ -z "$OPTARG" ]]; then
                log_error "Option -e requires an argument." >&2
                exit 1
            fi
            error_path="$OPTARG"
            ;;
        -)
            case "${OPTARG}" in
            users)
                action="users"
                ;;
            processes)
                action="processes"
                ;;
            help)
                show_help
                exit 0
                ;;
            log)
                log_path="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
                ;;
            errors)
                error_path="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
                ;;
             *)
                log_error "Invalid option: --${OPTARG}" >&2
                exit 1
                ;;
            esac
            ;;
        \?)
            log_error "Invalid option: -${OPTARG}" >&2
            exit 1
            ;;
        :)
            log_error "Option -$OPTARG requirs an argument." >&2
            exit 1
            ;;
    esac
done

check_and_create_file() {
    local path="$1"
    if [[ ! -d "$(dirname "$path")" ]]; then
        log_error "Error: The '$path' directory does not exist." >&2
        exit 1
    fi

    if [[ -f "$path" ]]; then
        echo "Warning: The file '$path' exists. Will be overwritten." >&2
    fi
    touch "$path"
    if [[ ! -w "$path" ]]; then
        log_error "Error: No write permission to '$path'" >&2
        exit 1
    fi
}

if [[ -n "$log_path" ]]; then
    check_and_create_file "$log_path"
    exec > "$log_path"
fi

if [[ -n "$error_path" ]]; then
    check_and_create_file "$error_path"
    exec > "$error_path"
fi


case $action in
    users)
        list_users
        ;;
    processes)
        list_processes
        ;;
    *)
        log_error "Error: no action specified." >&2
        show_help
        exit 1
        ;;
esac
