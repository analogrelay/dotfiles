#add each topic folder to fpath so that they can add functions and completion scripts

folders=$(find $ZSH/* -maxdepth 0 -type d ! -name vim.symlink)

for topic_folder ($folders); do
    fpath=($topic_folder $fpath)
done
