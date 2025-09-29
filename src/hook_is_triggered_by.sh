#!/usr/bin/env bash
is_triggered_by() {
  git_subcommand="$1"
  local pid=$$ # start with parent process
  while [[ "$pid" -gt 1 ]]; do # check until we reach init process
    cmd=$(ps -o args= -p "$pid") # get command and arguments of process ID
    if echo "$cmd" | grep -q "git $git_subcommand"; then
      return 0 # we are running in `commit` context
    fi
    pid="$(ps -o ppid= -p "$pid" | tr -d ' ')" # get parent process ID
  done
  return 1
}
