#!/bin/bash

DEFAULTLOGNAME=".log"

usage() {
  cat <<-ENDOFUSAGE

  $(basename $0) [-cCehst] [-f filename] [-d directory] [message]

  Appends a line to a log file with a timestamp.  Basically, searches up the
  directory tree until the first valid log file is found.
  Message can also be piped in from standard input.
  Remember to escape message for special characters like !, ", ', and *

    -f [filename] 
        Filename (without extension) of the log file.
        Default: ".log"

    -l
        Displays the log file, and doesn't write any messages.

    -e
        Opens log file for editing using the \$EDITOR environment variable.

    -c
        Creates the log file in the current directory if not already there.

    -d [directory]
        Overrides default searching mechanism and uses log from this directory.
        Default: Automatic

    -C
        Clears contents of found logfile.  Asks for confirmation.

    -t
        Inserts a "[ ]" check box before the log line, indicating a "todo".

    -s
        silent (does not display log file name and path)

    -h
        Displays this message

  Written by Justin Le (justin@jle0.com) 2013

ENDOFUSAGE
  exit 0
}

CALLINGDIR="$(pwd)"
LOGNAME="$DEFAULTLOGNAME"
CREATE=""
SHOW=""
EDIT=""
FOUND_LOG=""
CLEAR=""
SILENT=""
TODO=""

while getopts ":f:dlecCsth" Option
do
  case $Option in
    f)
      LOGNAME="$OPTARG";;
    d) 
      FOUND_LOG="$OPTARG";;
    l)
      SHOW=1;;
    e)
      EDIT=1;;
    c)
      CREATE=1;;
    C)
      CLEAR=1;;
    s)
      SILENT=1;;
    t)
      TODO="[ ] ";;
    h)
      usage
      exit 1;;
  esac
done
shift $(($OPTIND - 1))

RAWMSG="$*"

if [[ -z "$SHOW$CREATE$CLEAR$EDIT$RAWMSG" ]]; then
  stdin="$(ls -l /proc/self/fd/0)"
  stdin="${stdin/*-> /}"
  if [[ "$stdin" =~ ^/dev/pts/[0-9] ]]; then
    echo "Enter message here: (CTRL+D/EOF to end)"
  fi
  RAWMSG="$(cat /dev/stdin)"
fi

if [[ -z "$SHOW$CREATE$CLEAR$EDIT$RAWMSG" ]]; then
  echo "Cannot log blank message."
  echo "  $(basename $0) -h for help"
  exit 1
fi

if [[ -n "$CREATE" ]]; then
  LOGPATH="$LOGNAME.log"
  if [[ -n "$FOUND_LOG" ]]; then
    LOGPATH="$FOUND_LOG/$LOGPATH"
  fi
  touch "$LOGPATH"
  chmod 600 "$LOGPATH"
fi

while [[ -z "$FOUND_LOG" ]]; do
  if [[ -e "$LOGNAME.log" ]]; then
    FOUND_LOG="$(pwd)/$LOGNAME.log"
  elif [[ "$(pwd)" == "/" ]]; then
    echo "No writable log file $LOGNAME.log found in any parent directory."
    echo "Run $(basename $0) -c to create a log file in this directory,"
    echo " or $(basename $0) -cd [dir] to specify directory of log file."
    exit 1
  else
    cd ../
  fi
done

if [[ -n "$CLEAR" ]]; then
  read -p "Clear contents of $FOUND_LOG? (y/N) " -n 1 -r
  echo ""

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cat /dev/null > "$FOUND_LOG"
    echo "$FOUND_LOG cleared."
  else
    echo "Clearing aborted."
  fi
  exit 0
fi

CURRDIR=$(pwd)
RELPATH=${CALLINGDIR#$CURRDIR}
PATHSTR=""
if [[ -n "$RELPATH" ]]; then
  PATHSTR="(./${RELPATH:1}) "
fi

if [[ -z "$SHOW$EDIT" && -n "$RAWMSG" ]]; then
  echo -e "$RAWMSG" | while read line; do

    MESSAGE="[$( date )]\t$TODO$PATHSTR$line"
    echo -e "$MESSAGE" >> "$FOUND_LOG"
    echo -e "$MESSAGE"
  done
  if [[ -z "$SILENT" ]]; then
    echo "Logged in $FOUND_LOG"
  fi
  exit 0
fi

if [[ -n "$EDIT" ]]; then
  if [[ -z "$SILENT" ]]; then
    echo "Log file: $FOUND_LOG"
  fi
  $EDITOR "$FOUND_LOG"
fi

if [[ -n "$SHOW" ]]; then
  if [[ -z "$SILENT" ]]; then
    echo "Log file: $FOUND_LOG"
  fi
  cat "$FOUND_LOG"
fi

