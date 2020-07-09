if has gpg-agent && [ -f /usr/local/bin/pinentry ]; then
    echo "Launching gpg-agent"
    killall gpg-agent
    gpg-agent --daemon --pinentry-program /usr/local/bin/pinentry
fi

export GPG_TTY="$(tty)"