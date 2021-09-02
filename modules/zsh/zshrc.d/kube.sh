if type kubectl >/dev/null 2>&1; then
    alias k="kubectl"
    alias k-who="kubectl config current-context"
    alias k-ls="kubectl config get-contexts"
    alias k-use="kubectl config use-context"
    alias k-ns="kubectl config set-context --current --namespace"

    source <(kubectl completion zsh)
fi