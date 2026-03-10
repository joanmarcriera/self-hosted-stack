# Record interactive SSH sessions with tlog (non-interactive automation is excluded).
if [ -n "${SSH_TTY:-}" ] && [ -n "${PS1:-}" ] && [ -t 0 ] && [ -t 1 ] \
   && [ -z "${TLOG_REC_SESSION:-}" ] && command -v tlog-rec-session >/dev/null 2>&1; then
  export TLOG_REC_SESSION=1
  exec tlog-rec-session
fi
