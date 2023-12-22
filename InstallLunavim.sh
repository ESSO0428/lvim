#!/usr/bin/env bash

# NOTE: Foolproofing
echo "This script will install Neovim Release and LunaVim core."
echo "Your current LunaVim configuration will be backed up to ~/.config/lvim_stage/"
echo "In case of failure, manually restore it by running:"
echo "mv ~/.config/lvim_stage/ ~/.config/lvim/"

# NOTE: Install NeovimRelease
cd ~
rm -rf ~/nvim.appimage
unlink ~/.config/lvim/snapshots/default.json > /dev/null 2>&1
mv ~/.config/lvim/ ~/.config/lvim_stage/

# Function to display required dependency notice
required_notice() {
  local dependency_name="$1"
  echo "$dependency_name is not installed."
  echo "$dependency_name is a necessary dependency for LunarVim."
  echo "If you choose not to install it, the installation will stop, and your previous LunarVim setup will be restored using:"
  echo "mv ~/.config/lvim_stage/ ~/.config/lvim/"
  echo "exit 1"
  echo "------------------------------------------"
}

# Function to restore the original LunarVim configuration and exit
restore_my_lvim_config() {
  cd ~
  if [ -d "$HOME/.config/lvim_stage" ]; then
    echo "Restoring the LunarVim (Andy6) configuration..."
    rm -rf "$HOME/.config/lvim/"
    mv "$HOME/.config/lvim_stage/" "$HOME/.config/lvim/"
  fi
}

rm -rf nvim.appimage
wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
chmod u+x nvim.appimage

# Test if the release version works
echo "Downloading Neovim Release ..."
if ./nvim.appimage --version; then
  echo "Neovim Release is executable."
else
  echo "Neovim can't use in this system. Please check your system."
  mv ~/.config/lvim_stage/ ~/.config/lvim/
  rm -rf nvim.appimage
  exit 1
fi

# NOTE: Create symbolic link in ~/.local/bin for lunavim
cd ~
mkdir -p ~/bin
mkdir -p ~/.local/bin
cd ~/.local/bin
ln -s ~/nvim.appimage nvim
cd ~

# NOTE: nvim and lunarvim (lvim)
# Initialize variables
path1="$HOME/.local/bin"
path2="$HOME/bin"
update_needed=false
update_commands=""

# Check if ~/.local/bin needs to be added
if ! grep -q "PATH=$path1" ~/.bashrc ; then
  update_commands="PATH=$path1:\$PATH"
  update_needed=true
fi

# Check if ~/bin needs to be added
if ! grep -q "PATH=$path2" ~/.bashrc ; then
  update_commands="${update_commands:+$update_commands\n}PATH=$path2:\$PATH"
  update_needed=true
fi

# Show the commands to the user and ask for confirmation
if [ "$update_needed" = true ]; then
  echo "The following lines will be added to .bashrc:"
  echo -e $update_commands
  read -p "Continue? (y/n) " -n 1 -r
  echo    # Move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    # Add the commands to .bashrc
    echo -e "$update_commands" >> ~/.bashrc
    echo "Updated .bashrc file."
  else
    echo "Update cancelled."
  fi
else
  echo "No updates needed for .bashrc."
fi


# NOTE: Install My LunaVim dependencies
# NOTE: install nvm v0.39.3 (if not installed)
# Check if nvm is installed
cd ~
# 初始化 NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" > /dev/null 2>&1  # 加載 nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" > /dev/null 2>&1  # 加載 nvm bash_completion
if ! command -v nvm > /dev/null 2>&1; then
  required_notice "NVM"
  read -p "Do you want to install NVM v0.39.3? (y/n) " answer
  if [ "$answer" != "${answer#[Yy]}" ]; then
    echo "Installing NVM v0.39.3..."
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    
    # Source the NVM script to make it available in the current session
    # export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    # Install and use Node.js version 16.9.0
    nvm install 19.8.1
    nvm use 19.8.1
    echo "nvm use 19.8.1" >> ~/.bashrc
  else
    echo "NVM installation skipped."
    restore_my_lvim_config
    exit 1
  fi
else
  echo "NVM is already installed."
fi

# install cargo (if not installed)
# Check if cargo is installed
cd ~
if ! command -v cargo > /dev/null 2>&1; then
  required_notice "cargo"
  read -p "Do you want to install cargo? (y/n) " answer
  if [ "$answer" != "${answer#[Yy]}" ]; then
    echo "When install finished, will write $HOME/.cargo/env to ~/.bashrc"
    curl https://sh.rustup.rs -sSf | sh
    source "$HOME/.cargo/env"
    echo ". "$HOME/.cargo/env"" >> ~/.bashrc
  else
    echo "cargo installation skipped."
    restore_my_lvim_config
  fi
fi

# NOTE: install git (if not installed)
# Check if git is installed
# Function to install Git 2.31.1
install_git_2_31_1() {
  echo "Installing Git 2.31.1... in ~/bin/git-2.31.1/"
  cd ~/bin
  wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.31.1.tar.gz --no-check-certificate
  tar -xvf git-2.31.1.tar.gz && cd git-2.31.1
  ./configure --prefix=$HOME
  make && make install
  cd ~
}

# Check if Git is installed and whether the version is 2.31.1 or higher
git_version_ok() {
  git --version | awk '{print $3}' | grep -q '^[2-9]\.[3-9][1-9]\.[1-9]' && return 0 || return 1
}

# Check if Git is installed in the user's directory
# Function to get Git's installation path if installed in the user's directory
git_installed_in_user_dir() {
  local git_path=$(which git)
  if [[ "$git_path" == "$HOME"* && "$git_path" != *"$HOME/"*conda* ]]; then
    echo "$git_path"
    return 0
  else
    if [[ "$git_path" == *"$HOME/"*conda* ]]; then
      echo "find git in conda env (not above 2.31.1 suggest to remove it)"
      echo "$git_path"
    fi

    return 1
  fi
}

cd ~
if ! command -v git > /dev/null 2>&1 || ! git_version_ok; then
  required_notice "git"
  git_path=$(git_installed_in_user_dir)
  if [ -n "$git_path" ]; then
    read -p "Git is installed in the user directory at $git_path. Do you want to remove it and install version 2.31.1? (y/n) " remove_answer
    if [ "$remove_answer" != "${remove_answer#[Yy]}" ]; then
      rm -rf "$git_path"
      install_git_2_31_1
    else
      echo "Kept the existing Git installation."
      restore_my_lvim_config
      exit 1
    fi
  else
    read -p "Do you want to install or update Git to version 2.31.1? (y/n) " install_answer
    if [ "$install_answer" != "${install_answer#[Yy]}" ]; then
      install_git_2_31_1
    else
      echo "Git installation or update skipped."
      restore_my_lvim_config
      exit 1
    fi
  fi
else
  echo "A suitable version of Git is already installed."
fi

# NOTE: install go
cd ~
PATH=$HOME/bin/go/bin/:$PATH
if ! command -v go > /dev/null 2>&1; then
  required_notice "go"
  read -p "Do you want to install go? (y/n) " answer
  if [ "$answer" != "${answer#[Yy]}" ]; then
    echo "Installing go... in ~/bin/go/"
    echo "When install finished, will write PATH=$HOME/bin/go/bin/:$PATH to ~/.bashrc"
    cd ~/bin/
    wget https://go.dev/dl/go1.19.3.linux-amd64.tar.gz
    tar zxvf go1.19.3.linux-amd64.tar.gz
    echo "PATH=$HOME/bin/go/bin/:$PATH" >> ~/.bashrc
  else
    echo "go installation skipped."
    restore_my_lvim_config
    exit 1
  fi
else
  cd ~
  echo "go is already installed."
fi
  

# NOTE: Install fd (fd-find) and rg (ripgrep)
# Check if fd and rg are installed
# install use cargo or conda
cd ~
declare -A hash_cargo_pkg
declare -A hash_conda_pkg
hash_cargo_pkg=(
  ["fd"]="fd-find"
  ["rg"]="ripgrep"
)
hash_conda_pkg=(
  ["fd"]="conda install -c conda-forge fd-find"
  ["rg"]="conda install -c conda-forge ripgrep"
)
# Function to install Anaconda3 version 2023.09-0
install_anaconda3_2023_09_0() {
  # Determine system architecture
  arch=$(uname -m)
  case "$arch" in
    "x86_64")
      anaconda_script="Anaconda3-2023.09-0-Linux-x86_64.sh"
      ;;
    "ppc64le")
      anaconda_script="Anaconda3-2023.09-0-Linux-ppc64le.sh"
      ;;
    "aarch64")
      anaconda_script="Anaconda3-2023.09-0-Linux-aarch64.sh"
      ;;
    "s390x")
      anaconda_script="Anaconda3-2023.09-0-Linux-s390x.sh"
      ;;
    *)
      echo "Unsupported architecture: $arch"
      exit 1
      ;;
  esac

  # Download and install Anaconda
  if [ -e "$anaconda_script" ]; then
    echo "Anaconda script '$anaconda_script' found in the current directory."
    echo "Installing existing package of Anaconda ($arch)"
  else
    echo "Downloading and installing Anaconda for $arch..."
    wget "https://repo.anaconda.com/archive/$anaconda_script" --no-check-certificate
  fi
  sh "$anaconda_script"
}

# Function to check if conda is installed and install it if not
check_conda_install_ok() {
  if ! command -v conda > /dev/null 2>&1; then
    echo "conda is not installed."
    read -p "Do you want to install conda? (y/n) " install_conda_answer
    if [[ "$install_conda_answer" =~ ^[Yy]$ ]]; then
      install_anaconda3_2023_09_0
    else
      echo "conda installation skipped."
      restore_my_lvim_config
      exit 1
    fi
  fi
}

for depd in "fd" "rg"; do
  if ! command -v "$depd" > /dev/null 2>&1; then
    required_notice "$depd"
    read -p "Do you want to install $depd using cargo? (y/n) " install_answer
    if [[ "$install_answer" =~ ^[Yy]$ ]]; then
      if cargo install "${hash_cargo_pkg[$depd]}"; then
        echo "$depd installed successfully using cargo."
      else
        echo "Failed to install $depd using cargo. Trying with conda..."
        check_conda_install_ok
        if eval "${hash_conda_pkg[$depd]}"; then
          echo "$depd installed successfully using conda."
        else
          echo "Failed to install $depd using conda as well."
          restore_my_lvim_config
          exit 1
        fi
      fi
    else
      echo "$depd installation skipped."
      restore_my_lvim_config
      exit 1
    fi
  fi
done

curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh | bash
echo "LunarVim installed successfully !!!"
restore_my_lvim_config

# NOTE: Install maybe sucessful, now notice below guide
echo "$ lvim ."
echo "init lvim (install plugins and install treesitter parsers)"
echo "Maybe restart lvim two times above (because solve plugin dependency)"
echo "----------------------------------------"
echo ":UpdateRemotePlugins"
echo "Some Python based plugins may need this command to be run after installation."

# NOTE: Remove the old lunarvim directory
rm -rf ~/.local/share/lunarvim.old/

