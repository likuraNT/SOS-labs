#!/bin/bash

function __users__
{
	echo "Users list:"
	awk -F: '$3 >= 1000 {print $1,"\t" $6 }' /etc/passwd | sort
}

function __processes__
{
	echo "Processes list:"
	ps -eo pid,comm --sort=pid
}
DEFAULT_LOG_PATH="default.log"
LOG_PATH="log.log"
ERR_PATH="err.log"

function __log_check__
{
	if [[ -n $LOG_PATH ]]; then
    		if ! touch "$LOG_PATH" &> /dev/null; then
        		echo "Have no permissions to: $LOG_PATH" >&2
        		exit 1
    		fi
    		touch "$LOG_PATH"
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
    		touch "$ERR_PATH"
    		echo "Have no errors." > "$ERR_PATH"
    		exit 1
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


while getopts ":uphl:e:-:" opt; do
	case $opt in
	u) __users__; __users__ > "$DEFAULT_LOG_PATH" ;;
	p) __processes__; __processes__ > "$DEFAULT_LOG_PATH" ;;
	h) __help__; exit 0 ;;
	l) LOG_PATH="$OPTARG" ;;
	e) ERR_PATH="$OPTARG" ;;
	-)
		case "${OPTARG}" in
			users) __users__   ;;
			processes) __processes__;;
			help) __help__; exit 0 ;;
			log) LOG_PATH=${!OPTIND}"; OPTIND=$(( $OPTIND + 1)) ;;
			errors) ERR_PATH=${!OPTIND}"; OPTIND=$(( $OPTIND +1)) ;;
			*) echo "Unknown option --${OPTARG}" >&2; exit 1 ;;
		esac ;;
	\?) echo "Invalid option: -${OPTARG}" >&2; exit 1 ;;
	:) echo "Option -${OPTARG} needs an argument." >&2; exit 1 ;;
	esac
done
__errors_check__ "ERR_PATH"
__log_check__ "LOG_PATH"
