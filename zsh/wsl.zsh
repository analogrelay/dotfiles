if [[ $WSL != "1" ]]; then
    # We are sourced, so DON'T use exit
    return 0
fi

# Use the Docker for Windows host
export DOCKER_HOST=tcp://0.0.0.0:2375
