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

_ssh_add_key ~/.ssh/id_rsa
_ssh_add_key ~/.ssh/anurse-docker
