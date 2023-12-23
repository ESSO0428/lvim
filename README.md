---
title: My Neovim Config (lunavim)
author: Andy6
date: 2023-10-08
---

# My Neovim Config

use neovim pre-config lunavim

## Introduction

### Current support neovim version

NVIM v0.9.4 (release)

```bash
$ nvim --version
NVIM v0.9.4
Build type: Release
LuaJIT 2.1.1692716794

   system vimrc file: "$VIM/sysinit.vim"
  fall-back for $VIM: "/__w/neovim/neovim/build/nvim.AppDir/usr/share/nvim"

Run :checkhealth for more info
```

### Overview (use this config)

- Install `lunavim` and `neovim` use my script
    1. clone this repo to `~/.config/`
        ```bash
        # NOTE: Step1
        cd ~/.config/

        # NOTE: Step2 (Dev or Common user)
        # Dev (ex: myself)
        # Prerequisites:
        # 1. Ensure you have an SSH key: cat ~/.ssh/id_rsa.pub
        # 2. Add your SSH key to GitHub: go to https://github.com/settings/keys and add the key
        git clone git@github.com:ESSO0428/lvim.git
        
        # Common user
        git clone https://github.com/ESSO0428/lvim.git
        ```
    2. install `lunavim` and `neovim` use my script
        ```bash
        cd ~
        sh ~/.config/lvim/InstallLunavim.sh
        ```
    3. other [reference](#about-update-lunavim-and-neovim-core-to-latest-release) after step2
- Install `lunavim` and `neovim` manually
    1. install `neovim`
        1. install nvim.appimage
        2. alias nvim.appimage to your bashrc/zshrc
            ```bash
            echo 'alias nvim=~/nvim.appimag' >> ~/.bashrc
            echo 'alias nvim=~/nvim.appimag' >> ~/.zshrc
            ```
        3. install `pyenv` for neovim (for plug of neovim)
            ```bash
            conda install pyenv
            ```
        4. install `debugpy` for neovim (for debug of neovim)
            ```bash
            pip install debugpy
            ```
    2. install `lunavim environment`
        1. link ~/nvim.appimage to ~/.local/bin/
            ```bash
            ln -s ~/nvim.appimage ~/.local/bin/nvim
            ```
        2. install nodejs, npm for lunavim (suggest use nvm)
        3. install `cargo` for lunavim
        4. install `fd` and `rg` for lunavim (can use cargo, npm, conda)
    4. install `lunavim`
    5. git `clone this repo` to `~/.config/`
        - and sync the config for sync new update to your worker machine

### Some notice

some server install neovim will get below error:
```bash
/lib64/libc.so.6: version `GLIBC_2.14'
```

need to use `sudo compile glibc-2.14`  
if you are only a user, suggest ask `your admin` to help you install `glbc-2.14`

#### Copilot

- **Automatic Activation**: Copilot will automatically start when you open Neovim, regardless of whether you have registered it or not.
- **Version Requirements**:
  - **Node.js version 18.x or above is required**.
  - If your Node.js version is below 18.x:
    - A reminder message will be displayed when you open Neovim.
    - This will not affect other functionalities of Neovim.
    - If you use `NVM`, you can install and activate `Node.js 18.x or above` by following these steps:
      ```bash
      # NOTE: Execute the following commands in the terminal
      # Install Node.js version 18.x or above (example version 19.8.1)
      nvm install 19.8.1
      # Activate the environment for Node.js version 18.x or above
      nvm use 19.8.1
      # Don't forget to write this setting into .bashrc or .zshrc (for activating Node.js 18.x or above on next login)
      echo 'nvm use 19.8.1' >> ~/.bashrc
      ```
  - If your Node.js version is 18.x or above:
    - You can use the `:Copilot auth` command (in cmd of nvim) to register Copilot service on this Neovim server.
    - **Prerequisites**: You should have registered for Copilot service and successfully logged in on GitHub.


### About update lunavim and neovim core to Latest Release

1. Can use below command to update lunavim and neovim core to Latest Release
    ```bash
    sh ~/.config/lvim/UpdateNvimReleaseAndLunaCore.sh
    ```
2. If update (or install) success (can use below command to init lunavim)
    ```bash
    # NOTE: init lvim (install plugins and install treesitter parsers)
    # Maybe restart lvim two times above (because solve plugin dependency)
    $ lvim .
    ```

    ```vim
    " NOTE: Some Python based plugins may need this command to be run after installation.
    :UpdateRemotePlugins
    ```
3. below is some maybe error and how to solve
    - vim-hexokinase
        ```vim
        " erro
        vim-hexokinase needs updating. Run `make hexokinase` in project root. See `:h hexokinase-installation` for more info.
        " solve in vim cmd
        :!export PATH=$HOME/bin/go/bin/:$PATH && cd ~/.config/lvim/plugged/vim-hexokinase/ && git submodule init && git submodule update && cd hexokinase/ && go build
        ```
        ```bash
        # or solve in terminal
        export PATH=$HOME/bin/go/bin/:$PATH && cd ~/.config/lvim/plugged/vim-hexokinase/ && git submodule init && git submodule update && cd hexokinase/ && go build && cd ~
        ```
