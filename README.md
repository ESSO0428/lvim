---
title: My Neovim Config (lunavim)
author: Andy6
date: 2023-10-08
---

# My Neovim Config

use neovim pre-config lunavim

## Introduction

### Current support neovim version

NVIM v0.9.2 (nightly)

```bash
$ nvim --version
NVIM v0.9.2
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
    3. other [reference](#about-update-lunavim-and-neovim-core-to-nightly) after step2
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

### About update lunavim and neovim core to nightly

1. Can use below command to update lunavim and neovim core to nightly
    ```bash
    sh ~/.config/lvim/UpdateNvimNightlyAndLunaCore.sh
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
    - session-error
        ```vim
        " erro
        Error executing vim.schedule lua callback: ...opt/neovim-session-manager/lua/session_manager/utils.lua:65: /nfs/ev02_sdb/home/Andy6/.local/share/lvim/sessions/__usr__local__dkdata__apache-django__website__mysite[48]..BufReadPost Autocom
        mands for "*": Vim(append):Error executing lua callback: /tmp/.mount_lvimq9BMmx/usr/share/nvim/runtime/filetype.lua:24: Error executing lua: /tmp/.mount_lvimq9BMmx/usr/share/nvim/runtime/filetype.lua:25: /nfs/ev02_sdb/home/Andy6/.local/
        share/lvim/sessions/__usr__local__dkdata__apache-django__website__mysite[48]..BufReadPost Autocommands for "*"..FileType Autocommands for "*"..function <SNR>1_LoadFTPlugin[19]..script /nfs/ev02_sdb/home/Andy6/.local/share/lunarvim/site/
        after/ftplugin/python.lua: Vim(runtime):E5113: Error while calling lua chunk: vim/shared.lua:0: t: expected table, got nil

        " notice above error display ftplugin/python.lua, it can be deduced filetype occur error
        
        " solve (above usually not isntall tree-sitter parser or LSP)
        " above example is python
        " tree-sitter parser
        :TSInstall python
        " LSP
        :LspInstall pyright
        ```
        ```
