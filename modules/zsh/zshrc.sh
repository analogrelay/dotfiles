# Options to configure the rest
export USE_NVIM=0

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

if [ -d "$HOME/dotfiles" ]; then
    export DOTFILES_ROOT="$HOME/dotfiles"
elif [ -d "$HOME/.dotfiles" ]; then
    export DOTFILES_ROOT="$HOME/.dotfiles"
fi

source "$DOTFILES_ROOT/modules/zsh/_utils.sh"

# Custom custom dir ;)
export ZSH_CUSTOM="$DOTFILES_ROOT/modules/zsh/oh-my-zsh"

# Add 'bin' to PATH and 'functions' to FPATH
export PATH="$HOME/bin:$DOTFILES_ROOT/bin:$PATH"
export FPATH="$DOTFILES_ROOT/functions:$FPATH"

#export PROMPT_USE_STARSHIP=no
export PROMPT_USE_PURE=no

# Ditto for private dotfiles if present
if [ -d "$PRIVATE_DOTFILES_ROOT" ]; then
    export PATH="$PRIVATE_DOTFILES_ROOT/bin:$PATH"
    export FPATH="$PRIVATE_DOTFILES_ROOT/functions:$FPATH"
fi

if type direnv >/dev/null 2>&1; then
	eval "$(direnv hook zsh)"
fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="vibrantcode"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git fzf-tab)

# Start an ssh-agent if there isn't one already
if [ -z "$SSH_AUTH_SOCK" ]; then
    plugins+=ssh-agent
elif [ -f "$HOME/.ssh/id_ed25519" ]; then
fi

ensure_key() {
    local file="$1"

    # Make sure our key is registered
    fingerprint=$(ssh-keygen -l -f "$file" | cut -f 2 -d " ")
    if ! ssh-add -l | grep "$fingerprint" >/dev/null 2>&1; then
        ssh-add "$file"
    fi
}

ensure_key "$HOME/.ssh/id_ed25519"

if [ -f "$HOME/.ssh/id_rsa" ]; then
    if [ ! -f "$HOME/.ssh/id_rsa.override" ]; then
        echo "warning: you still have an RSA key, you should upgrade it to ED25519 unless you can't" 1>&2
        echo "create the file '$HOME/.ssh/id_rsa.override' to suppress this warning" 1>&2
    fi
    ensure_key "$HOME/.ssh/id_rsa"
fi

source $ZSH/oh-my-zsh.sh

unsetopt autocd

# Preferred editor for local and remote sessions
export EDITOR='vim'

# Mark all files with no extension in there as autoload
FUNCS_TO_AUTOLOAD=("${(@f)$(find "$DOTFILES_ROOT/functions" -type f \! -name "*.*")}")
for func in $FUNCS_TO_AUTOLOAD; do
    autoload $func
done

# If we're in WSL, source the wsl script
if uname -r | grep Microsoft >/dev/null; then
    source "$DOTFILES_ROOT/modules/zsh/wsl.zshrc"
fi

# Run other ZSH scripts
for file in `find "$DOTFILES_ROOT/modules/zsh/zshrc.d" -type f -name "*.sh"`; do
    source $file
done

