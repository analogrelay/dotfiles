#add each topic folder to fpath so that they can add functions and completion scripts
for topic_folder ($ZSH/*); do
    if [ -d $topic_folder ] && [ $(basename $topic_folder) != "vim.symlink" ]; then
        fpath=($topic_folder $fpath)
    fi
done
