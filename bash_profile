# If this is NOT an interactive shell (such as script or scp)
if ! [[ $- = *i* ]]; then
  # Don't bother. At all.
  return 1;
fi

# Enable terminal colors
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
export HISTSIZE="GOTCHA"

# Other useful commands
alias ll="ls -la"
alias s="source ~/.bash_profile"

source ~/.bashrc

# Get terminal emulator info
# See: https://unix.stackexchange.com/questions/264329/get-the-terminal-emulator-name-inside-the-shell-script<Paste>
sid=$(ps -o sid= -p "$$")
sid_as_integer=$((sid)) # strips blanks if any
session_leader_parent=$(ps -o ppid= -p "$sid_as_integer")
session_leader_parent_as_integer=$((session_leader_parent))
emulator=$(ps -o comm= -p "$session_leader_parent_as_integer")

BASH_COMPLETION_PATH=

setupNeovim () {
  if [ -x "$(command -v nvim)" ]; then
    # So long and thanks for all the fish
    alias vim="nvim"

    if [ "$emulator" == "lxterminal" ]; then
      # Fix broken characters in lxterminal + neovim
      # See: https://github.com/neovim/neovim/issues/5990
      export VTE_VERSION="100"
    fi
  else
    echo "Neovim NOT installed! You should install neovim!"
  fi
}

setupDocker () {
  if [ -x "$(command -v docker)" ]; then
    alias dcu="docker-compose up -d"
    alias dcs="docker-compose stop"
  fi
}

setupDarwin () {
  # I decided it doesn't make sense to reinstall this SDK outside of Android studio
  export ANDROID_HOME="/Applications/Android Studio.app/Contents/jre/jdk/Contents/Home"

  if [ -x "$(command -v brew)" ]; then
    BASH_COMPLETION_PATH=$(brew --prefix)/etc/bash_completion
  else
    echo "brew is not installed"
  fi
}

setupBashCompletion () {
  if [[ -f "$BASH_COMPLETION_PATH" ]]; then
    . "$BASH_COMPLETION_PATH"

    # Add GIT autocompletion in bash
    source ~/.git-completion.bash
  else
    echo "Bash completion is not installed"
  fi
}

setComputerTag () {
  # Map my computer names to super cool emoji
  case `hostname` in
    MBLPPXNG8WL.local)
      export COMPUTER_TAG="🌶  ";;
    avocado)
      export COMPUTER_TAG="🥑  ";;
    *)
      export COMPUTER_TAG="`hostname` ";;
  esac

  # Backup prompt in case I want to run `prompt_off` and disable liquid prompt
  export PS1="${COMPUTER_TAG}"
}

setupLiquidPrompt () {
  local COMPUTER_TAG=$1

  if [[ -d ~/liquidprompt/ ]]; then
    # Liquid prompt: Hide the username unless I'm another user
    export LP_USER_ALWAYS=0

    # Liquid prompt: Special variables
    LP_PS1_PREFIX="\n"
    LP_PS1_POSTFIX="\n${COMPUTER_TAG}"

    source ~/liquidprompt/liquidprompt
  else
    INSTALL_LIQUIDPROMPT="git clone https://github.com/nojhan/liquidprompt.git ~/liquidprompt/"
    alias liquidprompt-install="$INSTALL_LIQUIDPROMPT; s"
    echo "Some features are disabled because liquidprompt is not installed"
    echo "Install liquidprompt with the following command: "
    echo $INSTALL_LIQUIDPROMPT
    echo ""
    echo "Or type liquidprompt-install"
    echo ""
  fi
}

fixLocale () {
  # Fix strange errors that pop up when our locale is not set
  # See: https://stackoverflow.com/questions/7165108/in-os-x-lion-lang-is-not-set-to-utf-8-how-to-fix-it
  export LANG="en_US.UTF-8"
  export LC_ALL="$LANG"
}

setupNeovim
setupDocker
fixLocale
if [[ "$OSTYPE" == "darwin"* ]]; then
  setupDarwin
else
  BASH_COMPLETION_PATH=/usr/share/bash-completion/bash_completion
fi
setupBashCompletion
setComputerTag
setupLiquidPrompt "$COMPUTER_TAG"
