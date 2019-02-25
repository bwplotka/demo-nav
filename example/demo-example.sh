#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Import our bash library.
. "${DIR}/../demo-nav.sh"

clear

# `r` registers command to be invoked.
#
# First argument specifies what should be printed.
# Second argument specifies what will be actually executed.
#
# NOTE: Use `'` to quote strings inside command.
r "This will be printed" "echo 'This is executed... Press enter to invoke me. After this is printed, press enter to reveal next command'"

# You can register with single argument - what is printed will be executed.
r "echo 'This will be executed'"

# 'rc' is like r but does not leave executed command printed.
rc "echo 'Does not show the command AFTER execution'"

VAR="hello word!"

# Feel free to use variables.
r "echo 'please replace this on register time: ${VAR}'"

# Use `\${VAR}' to substitute the variables on invoke time.
r "echo 'please replace this on invoke time: \${VAR}'"

# Sub evaluate now.
r "echo 'please eval this on register time: $(echo "${VAR}")'"
r "echo 'please eval this on register time as well: `echo ${VAR}`'"

# Put `\` to sub evaluate on invoke time.
r "echo 'please eval this on invoke time '\$(echo \"${VAR}\")"

VAR="changed"

# Last entry to run navigation mode.
navigate