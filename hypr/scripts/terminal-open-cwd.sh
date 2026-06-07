#!/bin/bash

terminal_pid=$(hyprctl activewindow | awk '/pid:/ {print $2}')
echo "$terminal_pid" \
  -P $terminal_pid" >&2" >&2"
echo "pgrep

shell_pid=$(
  pgrep -P "$terminal_pid" | while read -r pid; do
    exe=$(readlink -f "/proc/$pid/exe" 2>/dev/null) || continue
    echo "Checking PID $pid with exe $exe" >&2
    grep -qsF "$exe" /etc/shells && echo "$pid" && break
    echo "PID $pid is not a shell" >&2
  done
)
echo "Found shell PID: $shell_pid" >&2

if [[ -n $shell_pid ]]; then
  cwd=$(readlink -f "/proc/$shell_pid/cwd" 2>/dev/null)
  echo "Shell CWD: $cwd" >&2
  [[ -d $cwd ]] && echo "$cwd" || echo "$HOME"
else
  echo "$HOME"
fi

##!/bin/bash
#
#terminal_pid=$(hyprctl activewindow | awk '/pid:/ {print $2}')
#
#is_shell() {
#  local exe
#  exe=$(readlink -f "/proc/$1/exe" 2>/dev/null) || return 1
#  grep -qsF "$exe" /etc/shells
#}
#
#get_cwd() {
#  local cwd
#  cwd=$(readlink -f "/proc/$1/cwd" 2>/dev/null) || return 1
#  [[ -d "$cwd" ]] && echo "$cwd"
#}
#
#find_shell_cwd() {
#  local parent=$1 depth=${2:-0}
#  [[ $depth -gt 4 || -z $parent ]] && return 1
#
#  local child cwd
#  while read -r child; do
#    [[ -z $child ]] && continue
#
#    if is_shell "$child"; then
#      cwd=$(get_cwd "$child") && {
#        echo "$cwd"
#        return 0
#      }
#    fi
#
#    # recurse into non-shell children (kitty workers, sh -c wrappers, etc.)
#    find_shell_cwd "$child" $((depth + 1)) && return 0
#  done < <(pgrep -P "$parent" 2>/dev/null)
#
#  return 1
#}
#
#if [[ -z $terminal_pid ]]; then
#  echo "$HOME"
#  exit 0
#fi
#
#cwd=$(find_shell_cwd "$terminal_pid")
#echo "${cwd:-$HOME}"
