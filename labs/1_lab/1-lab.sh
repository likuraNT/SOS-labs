#!/bin/bash

function __users__
{
	echo "Users list:"
	awk -F':' '{print $1, $6 }' /etc/passwd | sort
}

function __processes__
{
	echo "Processes list:"
	ps -eo pid,comm --sort=pid
}

function __log_check__
{
	if [[ -n $LOG_PATH ]]; then
    		if ! touch "$LOG_PATH" &> /dev/null; then
        		echo "Have no permissions to: $LOG_PATH" >&2
        		exit 1
    		fi
    		exec > "$LOG_PATH"
	fi
}

function __errors_check__
{
	if [[ -n $ERR_PATH ]]; then
    		if ! touch "$ERR_PATH" &> /dev/null; then
        		echo "Have no permissions to: $ERR_PATH" >&2
        		exit 1
    		fi
    		exec 2> "$ERR_PATH"
	fi
}

function __help__ 
{
	echo "Using: $0 [Options]"
	echo "Options:"
	echo " -u, --users			Output a list of users and their home directories."
	echo " -p, --processes          	Output a list of running processes, sorted by ID."
	echo " -h, --help			Display help menu."
	echo " -l PATH, --log PATH		Log output to the file."
	echo " -e PATH, --errors PATH		Log errors to the file."
}

LOG_PATH=""
ERR_PATH=""
while getopts ":uphl:e:-:" opt; do
	case $opt in
	u) __users__ ;;
	p) __processes__ ;;
	h) __help__; exit 0 ;;
	l) LOG_PATH="$OPTARG" ;;
	e) ERR_PATH="$OPTARG" ;;
	-)
		case "${OPTARG}" in
			users) __users__ ;;
			processes) __processes__ ;;
			help) __help__; exit 0 ;;
			log) LOG_PATH=${!OPTIND}"; OPTIND=$(( $OPTIND + 1)) ;;
			errors) ERR_PATH=${!OPTIND}"; OPTIND=$(( $OPTIND +1)) ;;
			*) echo "Unknown option --${OPTARG}" >&2; exit 1 ;;
		esac ;;
	\?) echo "Invalid option: -${OPTARG}" >&2; exit 1 ;;
	:) echo "Option -${OPTARG} needs an argument." >&2; exit 1 ;;
	esac
done

__log_check__ "$LOG_PATH"
__errors_check__ "$ERR_PATH"
