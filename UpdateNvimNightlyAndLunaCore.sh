#!/usr/bin/env bash

# NOTE: Foolproofing
echo "This script will update Neovim Nightly and LunaVim core."
echo "Your current LunaVim configuration will be backed up to ~/.config/lvim_stage/"
echo "In case of failure, manually restore it by running:"
echo "mv ~/.config/lvim_stage/ ~/.config/lvim/"

# NOTE: get current neovim version and backup current nvim
current_nvm_version=`~/nvim.appimage --version | head -2 | paste -sd "_" - | sed -e 's/^NVIM //;s/Build type: //;s/ /_/g'`
echo "Backup current nvim version: $current_nvm_version"
echo "mv ~/nvim.appimage ~/nvim.appimage.$current_nvm_version"
echo "(backup current nvim to ~/nvim.appimage.$current_nvm_version)"
mv ~/nvim.appimage ~/nvim.appimage.$current_nvm_version

# NOTE: Use below command to update nvim nightly (and update lunavim core for nvim nightly)
cd ~
mv ~/.config/lvim/ ~/.config/lvim_stage/

wget https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
chmod u+x nvim.appimage

curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh | bash
mv ~/.config/lvim_stage/ ~/.config/lvim/

# NOTE: Install maybe sucessful, now notice below guide
echo "$ lvim ."
echo "init lvim (install plugins and install treesitter parsers)"
echo "Maybe restart lvim two times above (because solve plugin dependency)"
echo "----------------------------------------"
echo ":UpdateRemotePlugins"
echo "Some Python based plugins may need this command to be run after installation."

# NOTE: Ask user whether to remove the old lunarvim directory
read -p "Do you want to remove the old LunarVim directory at ~/.local/share/lunarvim.old/? (y/n) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    rm -rf ~/.local/share/lunarvim.old/
    echo "Old LunarVim directory removed."
else
    echo "Old LunarVim directory retained."
fi

