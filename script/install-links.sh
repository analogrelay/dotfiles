#!/usr/bin/env zsh

# Run simple linking tasks
if [ -z "$DOTFILES_ROOT" ]; then
  DOTFILES_ROOT=~/.dotfiles
fi

for link_file in $(find "$DOTFILES_ROOT" -type f -name ".links" -maxdepth 2); do
  base_dir=$(dirname $link_file)
  while IFS= read line; do
    src="$base_dir/$(echo "$line" | cut -f 1 -d "," | tr -d " ")"
    dest=$(echo "$line" | cut -f 2 -d "," | tr -d " ")

    # Resolve any use of ~
    eval "dest=$dest"
    eval "src=$src"

    echo "linking $dest => $src"

    if [ -n "$FORCE" ]; then
      if [ -e "$dest" ]; then
        rm -Rf "$dest"
      fi

      ln -s "$src" "$dest"
    else
      echo "not making links unless FORCE=1"
    fi
  done <<< $(< $link_file)
done