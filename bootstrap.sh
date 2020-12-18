# Clone the dotfiles repo using HTTPS, but then switch it to SSH (the installer will configure SSH)
if [ -d ~/.dotfiles ] || [ -d ~/dotfiles ]; then
	echo "ERROR: There is already a '~/.dotfiles' directory. Remove it to install." 1>&2
	exit 1
fi

echo "Cloning dotfiles..."
cd ~
git clone https://github.com/anurse/dotfiles .dotfiles

echo "Changing dotfiles remote to SSH"
cd ~/.dotfiles
git remote set-url origin git@github.com:anurse/dotfiles.git

echo "Running installer..."
~/.dotfiles/install.sh
