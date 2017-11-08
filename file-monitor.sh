#!/bin/bash

#set -x


SCRIPTNAME=`basename "$0"`
MONITOR_DIR=~/file-monitor-repo


print_help() {
cat << EOF
Usage: $SCRIPTNAME [-f|--file] <absolute-file-path> [-m|--monitor|-h|--history]
       $SCRIPTNAME --help

This script monitors all the changes done on a specific file, whiel keeping 
the history of all the changes.
 -f,--file <absolute-file-path>	Adding a file to the monitored files List. The <absolute-file-path>
				is the absolute file path of the file we need to action.
				PLEASE NOTE: Relative file path could cause issues in the script,
				please make sure to use the abolute path of the file. also try to 
				avoid sym links, as it has not been tested.
				example: $SCRIPTNAME -f /absolute/path/to/file/test.txt -m
 -m, --monitor			Monitoring all the changes on the file. the monitoring will keep
				happening as long as the script is running; you may need to run it
				in the background.
				example: $SCRIPTNAME -f /absolute/path/to/file/test.txt -m
 -h, --history			showing the full history of the file.
				To exit, press "q"
				example: $SCRIPTNAME -f /absolute/path/to/file/test.txt -h
 --uninstall			uninstalls the script from the bin direcotry,
				and removes the monitoring history.
 --install			Adds the script to the bin directory, and creates
				the directories and files needed for monitoring.
 --help				Prints this help message.
EOF
}


init_monitor_dir() {
  mkdir -p $MONITOR_DIR
  cd $MONITOR_DIR
  git -c $MONITOR_DIR rev-parse
  if [ $? -ne 0 ]; then
    git init
  fi
}

dependencies_check() {
  #check running as a super user
  #if [ "$EUID" -ne 0 ]
  #  then echo "Please run with sude or as root"
  #  exit 1
  #fi

  # check inotify-tools dependency
  if ! type inotifywait &>/dev/null ; then
    echo "You are missing the inotifywait dependency. Install the package inotify-tools (sudo yum install inotify-tools)"
    exit 1
  fi

  #check git dependency
  if ! type git &>/dev/null ; then
    echo "You are missing the git dependency. Install the package git (sudo yum install git)"
    exit 1
  fi

  #check if realpath or readlink exist
  if ! type realpath &>/dev/null ; then
    if ! type readlink &>/dev/null ; then
      echo "Either realpath or readlink should exist in your system. please install the missing realpath or readlink package"
      exit 1
    fi
  fi
}


validate_params() {
  if [[ ! -z "$HELP" ]]; then
    print_help
    exit 0
  fi

  if [[ -z "$MONITOR_FILE" ]]; then
    print_help
    exit 1
  fi

  if [[ (-z "$MONITOR" && -z "$HISTORY") || (! -z "$MONITOR" && ! -z "$HISTORY") ]]; then
    print_help
    exit 1
  fi
}

monitor_file() {
  if [ ! -f $MONITOR_FILE ]; then
    echo "Unable to find file: $MONITOR_FILE\n"
    print_help
  else
    init_monitor_dir
    if ! type realpath &>/dev/null ; then
      PARENT_DIR="$(dirname -- "$(realpath -- "$MONITOR_FILE")")"
    else
      PARENT_DIR="$(dirname -- "$(readlink -f -- "$MONITOR_FILE")")"
    fi
    MONITOR_FILE_NAME=`basename "$MONITOR_FILE"`
    inotifywait -e close_write,moved_to,create -m $PARENT_DIR |
    while read -r directory events filename; do
      if [ "$filename" = "$MONITOR_FILE_NAME" ]; then
        cp $MONITOR_FILE $MONITOR_DIR/
        cd $MONITOR_DIR
	pwd
        if ! git diff-index --quiet HEAD --; then
          LAST_ACCESSED=`stat test.py | grep "Access: ("`
          git add .
          git commit -m "file changed - Last Access Details: $LAST_ACCESSED"
        fi
      fi
    done
  fi
}

show_file_history() {
  MONITOR_FILE_NAME=`basename "$MONITOR_FILE"`
  cd $MONITOR_DIR
  git log --full-diff -p $MONITOR_FILE_NAME
}



dependencies_check

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -f|--file)
    MONITOR_FILE="$2"
    shift # past argument
    shift # past value
    ;;
    -m|--monitor)
    MONITOR=YES
    shift # past argument
    ;;
    -h|--history)
    HISTORY=YES
    shift # past argument
    ;;
    --help)
    HELP=YES
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

validate_params

if [[ ! -z $MONITOR ]]; then
  monitor_file
  else
    if [[ ! -z $HISTORY ]]; then
      show_file_history
    fi
fi

