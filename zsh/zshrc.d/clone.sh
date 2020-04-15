clone() {
    repo=$1

    if [ -z "$1" ]; then
        echo "Usage: clone <REPO URL>" 1>&2
        echo "Usage: clone <OWNER>/<REPONAME>" 1>&2
        return 1
    fi

    # Detect input types.
    if [[ $repo =~ "^(ssh://)?git@ssh.dev.azure.com:v3/([a-zA-Z0-9\-_]+)/[a-zA-Z0-9\-_]+/([a-zA-Z0-9\-_\.]+)/?$" ]]; then
        owner=$match[2]
        repoName=$match[3]
    elif [[ $repo =~ "^(ssh://)?[A-Za-z]@vs-ssh.visualstudio.com:v3/([a-zA-Z0-9\-_]+)/[a-zA-Z0-9\-_]+/([a-zA-Z0-9\-_]+)/?$" ]]; then
        owner=$match[2]
        repoName=$match[3]
    elif [[ $repo =~ "^([a-zA-Z0-9\-_]+)/([a-zA-Z0-9\-_]+)$" ]]; then
        owner=$match[1]
        repoName=$match[2]
        repo="git@github.com:$owner/$repoName.git"
    elif [[ $repo =~ "^(ssh://)git@github.com/([a-zA-Z0-9\-_]+)/([a-zA-Z0-9\-_\.]+)\.git/?$" ]]; then
        owner=$match[2]
        repoName=$match[3]
    elif [[ $repo =~ "^(ssh://)git@github.com/([a-zA-Z0-9\-_]+)/([a-zA-Z0-9\-_\.]+)/?$" ]]; then
        owner=$match[2]
        repoName=$match[3]
    elif [[ $repo =~ "^https://(www\.)?github.com/([a-zA-Z0-9\-_]+)/([a-zA-Z0-9\-_\.]+)\.git/?$" ]]; then
        owner=$match[2]
        repoName=$match[3]
    elif [[ $repo =~ "^https://(www\.)?github.com/([a-zA-Z0-9\-_]+)/([a-zA-Z0-9\-_\.]+)/?$" ]]; then
        owner=$match[2]
        repoName=$match[3]
    else
        echo "This script can only be used with 'ssh://' URLs or GitHub owner/repo references" 1>&2
        exit 1
    fi

    dest=~/code/$owner/$repoName

    if [ ! -d $dest ]; then
        echo "Cloning $repo into $dest"
        git clone $repo $dest
    fi

    cd "$dest"
}
