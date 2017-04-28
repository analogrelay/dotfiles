if [[ $WSL != "1" ]]; then
    # We are sourced, so DON'T use exit
    return 0
fi

if [ -z $WSL_FIRSTRUN ]; then
    export WSL_FIRSTRUN=1

    cd $HOME
fi

# Use the Docker for Windows host
export DOCKER_HOST=tcp://0.0.0.0:2375

CMDLINE=$(</proc/self/cmdline)
export SHELL=$(type $CMDLINE | cut -d' ' -f 3)
