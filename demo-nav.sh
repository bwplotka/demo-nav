#!/usr/bin/env bash

# Source & docs: https://github.com/bwplotka/demo-nav

# Script options (define those variables before registering commands):
#
# The speed to "type" the text (Default: 0 so no typing view).
# TYPE_SPEED=40
#
# If empty next command will be shown only after enter (Default: false).
# IMMEDIATE_REVEAL=true
#
# If true prefix line with number; easier to navigate (Default: false).
# NUMS=true
#
# If NUMS = false this prefix will be used (Default: '').
# PREFIX="CustomPrefix"
#
# Color vars for pretty prompts.
# Feel free to use those colors in registered commands.
BLACK="\033[0;30m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
RED="\033[0;31m"
PURPLE="\033[0;35m"
BROWN="\033[0;33m"
WHITE="\033[1;37m"
COLOR_RESET="\033[0m"

# Shortcuts bindings.
NEXT_KEY=$'\x6E' # n
PREV_KEY=$'\x70' # p
BEGIN_KEY=$'\x62' # b
END_KEY=$'\x65' # e
QUIT_KEY=$'\x71' # q
INVOKE_KEY=$'\x0' # enter

# Variables.
PRINT=()
CMDS=()
CLEAN_AFTER=()
PRINT_BUFFER=""

# Strip ANSI escape codes/sequences [$1: input string, $2: target variable]
function strip_escape_codes_and_comments() {
    local _input="$1" _i _j _token _escape=0
    local -n _output="$2"; _output=""
    for (( _i=0; _i < ${#_input}; _i++ )); do
       if (( ${_escape} == 1 )); then
            if [[ "${_input:_i:1}" =~ [a-zA-Z] ]]; then
                _escape=0
            fi
            continue
       fi
       if [[ "${_input:_i:5}" == "\033[" ]]; then
            _escape=1
            continue
        fi

        if [[ "${_input:_i:1}" == '#' ]]; then
            break
        fi
        _output+="${_input:_i:1}"
    done
}

# Erase lines from terminal [$1: current command number]
function erase_lines_for_curr() {
    local _curr="$1"
    local _print=${PRINT[${_curr}]}
    if [[ ${_print} == "" ]]; then
        _print=${CMDS[${_curr}]}
    fi
    # Refer to https://shiroyasha.svbtle.com/escape-sequences-a-quick-guide-1.
     echo -ne "\033[2K\r"
    for (( _i=1; _i < $(wc -l <<< "${print}"); _i++ )); do
      echo -ne "\033[1A\033[2K\r"
    done
}

##
# Registers a command into navigable script. Order of registration matters.
# r: register.
#
# Takes 1 or 2 parameters:
# 1) The string command to show.
# 2) Optionally: The string command to run. If empty, parameter 1 is used.
#
# usage:
#
#   r "ls -l"
#   r "list me please" "ls -l"
##
function r() {
  PRINT_BUFFER+="${1}"
  PRINT+=("${PRINT_BUFFER}")
  PRINT_BUFFER=""

  TO_RUN="${2:-${1}}"

  # Sanitize.
  strip_escape_codes_and_comments "${TO_RUN}" TO_RUN_SANITIZED
  CMDS+=("${TO_RUN_SANITIZED}")
  CLEAN_AFTER+=(false)
}

##
# Same as 'r' but removes the command *AFTER* the execution.
# rc: register and clear.
##
function rc() {
  r "$1" "$2"

  CLEAN_AFTER[-1]=true
}

##
# p: print with next command.
##
function p() {
  PRINT_BUFFER+="${CYAN}${1}${YELLOW}"
  PRINT_BUFFER+=$'\n'
}

##
# Runs in a mode that enables easy navigation of the
# commands in the sequential manner.
#
# TODO(bwplotka): Add search (ctlr+r) functionality
##
function navigate() {
  CONTINUE=${1-false}

  curr=0
  if ${CONTINUE} && [[ -f ./.demo-last-step ]]; then
    curr=$(< ./.demo-last-step)
  fi

  while true
  do
    # Check boundaries.
    if (( ${curr} < 0 )); then
      curr=0
    fi
    if (( ${curr} >= ${#CMDS[@]} )); then
      let curr="${#CMDS[@]} - 1"
    fi

    print=${PRINT[${curr}]}
    if [[ ${print} == "" ]]; then
        print=${CMDS[${curr}]}
    fi

    prefix="${PREFIX}"
    if ${NUMS}; then
        prefix="${curr}) "
    fi
    # Make sure input will not break the print.
    stty -echo
    if [[ -z $TYPE_SPEED ]]; then
      echo -en "${prefix}${YELLOW}$print${COLOR_RESET}"
    else
      echo -en "${prefix}${YELLOW}$print${COLOR_RESET}" | pv -qL $[$TYPE_SPEED+(-2 + RANDOM%5)];
    fi
    stty echo

    # Ignore accidentally buffered input (introduces 0.5 input lag).
    read -rst 0.3 -n 10000 discard

    # Allow for interactive navigation.
    read -rsn1 input
    case "${input}" in
    ${BEGIN_KEY})
      # Skip this command and move to beginning.
      erase_lines_for_curr ${curr}
      curr=0
      ;;
    ${END_KEY})
      # Skip this command and move to the end.
      erase_lines_for_curr ${curr}
      let curr="${#CMDS[@]} - 1"
      ;;
    ${NEXT_KEY})
      # Skip this command and move to next.
      erase_lines_for_curr ${curr}
      ((curr++))
      ;;
    ${PREV_KEY})
      # Skip this command and move to previous.
      erase_lines_for_curr ${curr}
      ((curr--))
      ;;
    ${INVOKE_KEY})
      # enter - Eval this and move to next.
      if ${CLEAN_AFTER[${curr}]}; then
        erase_lines_for_curr ${curr}
      else
        echo ""
      fi
      eval "${CMDS[${curr}]}"
      ((curr++))

      if ${IMMEDIATE_REVEAL}; then
         # Wait for enter at the end.
        read -rst 0.3 -n 10000 discard
        read -rsn1 input
        case ${input} in
        ${NEXT_KEY})
          erase_lines_for_curr ${curr}
          ((curr++))
          ;;
        ${PREV_KEY})
          erase_lines_for_curr ${curr}
          ((curr--))
          ;;
        ${QUIT_KEY})
          echo ""
          echo "Bye!"
          exit 0
          ;;
        esac
      fi
      ;;
    ${QUIT_KEY})
     # q - Quit.
      echo ""
      echo "Bye!"
      exit 0
      ;;
    *)
    # Not supported input, reprint.
     erase_lines_for_curr ${curr}
      ;;
    esac
    echo ${curr} > ./.demo-last-step
  done
}

# Internal function for checking pv tool that is used to simulate typing.
function _check_pv() {
  command -v pv >/dev/null 2>&1 || {
    echo ""
    echo "'pv' tool is required, but it's not installed. Aborting." >&2;
    echo ""
    echo -e "${COLOR_RESET}Installing pv:"
    echo ""
    echo -e "${BLUE}Mac:${COLOR_RESET} $ brew install pv"
    echo ""
    echo -e "${BLUE}Other:${COLOR_RESET} http://www.ivarch.com/programs/pv.shtml"
    echo -e "${COLOR_RESET}"
    exit 1;
  }
}

if ! [[ -z ${TYPE_SPEED} ]]; then
    _check_pv
fi
