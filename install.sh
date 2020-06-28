#!/usr/bin/env bash

# "Alias" for ./script/setup, since some automated tools require a ./install.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

exec "$DIR/script/setup"