#!/usr/bin/env bash

# Detect architecture
ARCH=$(uname -m)

# NOTE: get current neovim version and backup current nvim
current_nvm_version=`~/nvim.appimage --version | head -2 | paste -sd "_" - | sed -e 's/^NVIM //;s/Build type: //;s/ /_/g'`
echo "Backup current nvim version: $current_nvm_version"
echo "mv ~/nvim.appimage ~/nvim.appimage.$current_nvm_version"
echo "(backup current nvim to ~/nvim.appimage.$current_nvm_version)"
mv ~/nvim.appimage ~/nvim.appimage.$current_nvm_version

echo "Downloading Neovim Release ..."
cd ~
rm -rf nvim.appimage
# NOTE: Install NeovimRelease
if [ "$ARCH" = "x86_64" ]; then
  wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage -O nvim.appimage
elif [ "$ARCH" = "aarch64" ]; then
  wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux-arm64.appimage -O nvim.appimage
else
  echo "Unsupported architecture: $ARCH"
  mv ~/nvim.appimage.$current_nvm_version ~/nvim.appimage
  echo "Reverted to the previous configuration and Neovim version."
  exit 1
fi
chmod u+x nvim.appimage

# Test if the release version works
if ./nvim.appimage --version; then
  echo "Neovim Release is executable."
else
  echo "Neovim Release can't execute. Try LOW_GLIBC."
  
  # NOTE: Changing the download URL to 'neovim-releases/releases/download'
  # , which is an official link provided by Neovim to accommodate machines with older glibc versions
  cd ~
  rm -rf nvim.appimage
  if [ "$ARCH" = "x86_64" ]; then
    wget https://github.com/neovim/neovim-releases/releases/download/stable/nvim-linux-x86_64.appimage -O nvim.appimage
  else
    echo "LOW_GLIBC version is only available for x86_64, reverting changes."
    mv ~/nvim.appimage.$current_nvm_version ~/nvim.appimage
    exit 1
  fi
  chmod u+x nvim.appimage
  # Test if the release version (LOW_GLIBC) works
  if ./nvim.appimage --version; then
    echo "Neovim Release (LOW_GLIBC) is executable."
  else
    echo "Neovim Release (LOW_GLIBC) can't execute. Reverting changes."
    mv ~/nvim.appimage.$current_nvm_version ~/nvim.appimage
    echo "Reverted to the previous configuration and Neovim version."
    exit 1
  fi
fi
