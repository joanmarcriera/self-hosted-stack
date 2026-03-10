# Keep a long, timestamped history and merge commands from concurrent shells.
export HISTSIZE=50000
export HISTFILESIZE=200000
export HISTTIMEFORMAT="%F %T "
export HISTCONTROL=ignoredups:erasedups
export HISTIGNORE="ls:ll:la:pwd:clear:history:exit"

shopt -s histappend cmdhist checkwinsize

case ";${PROMPT_COMMAND:-};" in
  *";history -a;"*) ;;
  *) PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}" ;;
esac

case ";${PROMPT_COMMAND:-};" in
  *";history -n;"*) ;;
  *) PROMPT_COMMAND="history -n${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}" ;;
esac
