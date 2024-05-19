#!/usr/bin/env bash

current_script_dir="$(dirname "$0")"
# NOTE: Foolproofing
echo "This script will update Neovim Release and LunaVim core."
echo "Your current LunaVim configuration will be backed up to ~/.config/lvim_stage/"
echo "In case of failure, manually restore it by running:"
echo "mv ~/.config/lvim_stage/ ~/.config/lvim/"

# NOTE: get current neovim version (if execute failed will backup current nvim)
if sh ${current_script_dir}/UpdateNvimReleaseOnly.sh; then
  :
else
  exit 1
fi

# NOTE: Use below command to update nvim release (and update lunavim core for nvim release)
cd ~
unlink ~/.config/lvim/snapshots/default.json > /dev/null 2>&1
mv ~/.config/lvim/ ~/.config/lvim_stage/

# Function to restore the original LunarVim configuration and exit
restore_my_lvim_config() {
  cd ~
  if [ -d "$HOME/.config/lvim_stage" ]; then
    echo "Restoring the LunarVim (Andy6) configuration..."
    rm -rf "$HOME/.config/lvim/"
    mv "$HOME/.config/lvim_stage/" "$HOME/.config/lvim/"
  fi
}
curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh | bash
echo "LunarVim updated successfully !!!"
restore_my_lvim_config

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

