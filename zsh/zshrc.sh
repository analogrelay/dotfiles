# Options to configure the rest
export USE_NVIM=0

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export DOTFILES_ROOT="$HOME/.dotfiles"
export PRIVATE_DOTFILES_ROOT="$HOME/.dotfiles-private"

# Custom custom dir ;)
export ZSH_CUSTOM="$DOTFILES_ROOT/zsh/oh-my-zsh"

# Add 'bin' to PATH and 'functions' to FPATH
export PATH="$DOTFILES_ROOT/bin:$PATH"
export FPATH="$DOTFILES_ROOT/functions:$FPATH"

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
plugins=(git ssh-agent)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
export EDITOR='vim'

# Mark all files with no extension in there as autoload
FUNCS_TO_AUTOLOAD=("${(@f)$(find "$DOTFILES_ROOT/functions" -type f \! -name "*.*" | xargs basename)}")
for func in $FUNCS_TO_AUTOLOAD; do
    autoload $func
done

# Repeat for private, if present
if [ -d "$HOME/.dotfiles-private/functions" ]; then
    FUNCS_TO_AUTOLOAD=("${(@f)$(find "$PRIVATE_DOTFILES_ROOT/functions" -type f \! -name "*.*" | xargs basename)}")
    for func in $FUNCS_TO_AUTOLOAD; do
        autoload $func
    done
fi

# If we're in WSL, source the wsl script
if uname -r | grep Microsoft >/dev/null; then
    source "$DOTFILES_ROOT/zsh/wsl.zshrc"
fi

# Run other ZSH scripts
for file in `find "$DOTFILES_ROOT/zsh/zshrc.d" -type f -name "*.sh"`; do
    source $file
done

# Run private dotfiles scripts
if [ -d "$HOME/.dotfiles-private/zsh/zshrc.d" ]; then
    for file in `find "$HOME/.dotfiles-private/zsh/zshrc.d" -type f -name "*.sh"`; do
        source $file
    done
fi
