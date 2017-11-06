if [[ -z "$SSH_AUTH_SOCK" ]]; then
    # FROM http://rocksolidwebdesign.com/notes-and-fixes/ubuntu-server-ssh-agent/
    # Check to see if SSH Agent is already running
    agent_pid="$(ps -ef | grep "ssh-agent" | grep -v "grep" | awk '{print($2)}')"

    # If the agent is not running (pid is zero length string)
    if [[ -z "$agent_pid" ]]; then
        # Start up SSH Agent
        # this seems to be the proper method as opposed to `exec ssh-agent bash`
        eval "$(ssh-agent)"

        # If the agent is running (pid is non zero)
    else
        # Connect to the currently running ssh-agent
        agent_ppid="$(($agent_pid - 1))"

        # and the actual auth socket file name is simply numerically one less than
        # the actual process id, regardless of what `ps -ef` reports as the ppid
        agent_sock="$(find /tmp -path "*ssh*" -type s -iname "agent.$agent_ppid")"

        echo "Agent pid $agent_pid"
        export SSH_AGENT_PID="$agent_pid"

        echo "Agent sock $agent_sock"
        export SSH_AUTH_SOCK="$agent_sock"
    fi
fi

_ssh_add_key()
{
    local KEYFILE=$1

    if [ ! -f $KEYFILE ]; then
        echo "$KEYFILE does not exist"
    else
        local FINGERPRINT=$(ssh-keygen -lf $KEYFILE | cut -d' ' -f 2)

        if ssh-add -l | grep $FINGERPRINT >/dev/null; then
            echo "$KEYFILE is already in the ssh agent"
        else
            ssh-add $KEYFILE
        fi
    fi
}

if [[ -z "$DOTFILES_SSH_KEYS_ADDED" ]]; then
    _ssh_add_key ~/.ssh/id_rsa
    _ssh_add_key ~/.ssh/anurse-docker
    _ssh_add_key ~/.ssh/anurse-benchmarking

    export DOTFILES_SSH_KEYS_ADDED=1
fi
