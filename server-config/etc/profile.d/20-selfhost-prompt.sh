# Show time, host, cwd, last exit code, and git branch when available.
__selfhost_prompt() {
  local exit_code="$?"
  local status=""
  local git_branch=""

  if [[ "$exit_code" -ne 0 ]]; then
    status="[exit:${exit_code}] "
  fi

  if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git_branch="$(git branch --show-current 2>/dev/null || true)"
    [[ -n "$git_branch" ]] && git_branch=" [git:${git_branch}]"
  fi

  PS1="${debian_chroot:+($debian_chroot)}${status}[\D{%F %T}] \u@\h:\w${git_branch}\n\\$ "
}

case ";${PROMPT_COMMAND:-};" in
  *";__selfhost_prompt;"*) ;;
  *) PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND}; }__selfhost_prompt" ;;
esac
