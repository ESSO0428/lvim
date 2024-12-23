---
title: My Neovim Config (lunarvim)
author: Andy6
date: Sunday, October, 08, 2023
---

# My Neovim Config

<!--toc:start-->
- [My Neovim Config](#my-neovim-config)
  - [Introduction](#introduction)
  - [Current support neovim version](#current-support-neovim-version)
  - [Overview (use this config)](#overview-use-this-config)
  - [Some notice](#some-notice)
    - [Copilot](#copilot)
      - [CopilotChat](#copilotchat)
  - [About update lunarvim and neovim core to Latest Release](#about-update-lunarvim-and-neovim-core-to-latest-release)
<!--toc:end-->

## Introduction

> [!NOTE]
> 
> This is my `lunarvim` config, use `lunarvim` and `neovim` to build my `neovim` environment.
>   - `lunarvim` is a `neovim` config framework, it's easy to use and easy to extend.
>   - What is `neoivm` ?
>     - Hyperextensible Vim-based text editor
>     - Project that seeks to aggressively refactor Vim


## Current support neovim version

NVIM v0.10.3 (release)
```bash
$ nvim --version
NVIM v0.10.3
Build type: Release
LuaJIT 2.1.1713484068
Run "nvim -V1 -v" for more info
```

## Overview (use this config)

- Install `lunarvim` and `neovim` use my script
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
  2. Install `lunarvim` and `neovim` use my script
     ```bash
     cd ~
     sh ~/.config/lvim/InstallLunarvim.sh
     ```
  3. Other [reference](#about-update-lunarvim-and-neovim-core-to-latest-release) after step2
- Install `lunarvim` and `neovim` manually
  1. Install `neovim`
     1. Install nvim.appimage
     2. Alias nvim.appimage to your .bashrc/.zshrc
        ```bash
        echo 'alias nvim=~/nvim.appimag' >> ~/.bashrc
        echo 'alias nvim=~/nvim.appimag' >> ~/.zshrc
        ```
     3. Install `pyenv` for neovim (for plug of neovim)
        ```bash
        conda install pyenv
        ```
     4. Install `debugpy` for neovim (for debug of neovim)
        ```bash
        pip install debugpy
        ```
  2. Install `lunarvim environment`
     1. Link ~/nvim.appimage to ~/.local/bin/
        ```bash
        ln -s ~/nvim.appimage ~/.local/bin/nvim
        ```
     2. Install nodejs, npm for lunarvim (suggest use nvm)
     3. Install `cargo` for lunarvim
     4. Install `fd` and `rg` for lunarvim (can use cargo, npm, conda)
  4. Install `lunarvim`
  5. git `clone this repo` to `~/.config/`
     - And sync the config for sync new update to your worker machine

## Some notice

Some server install neovim will get below error:
```bash
/lib64/libc.so.6: version `GLIBC_2.2X...' not found
```

Need to use `sudo compile glibc-2.31`  or `sudo compile glibc-2.27` (if you use low_glibc_support_version)
if you are only a user, suggest ask `your admin` to help you install `glbc-2.31` or `glibc-2.27`

### Copilot

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

#### CopilotChat

Through the [CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim) plugin, an interactive interface with Copilot is provided, allowing you to open a chat interface to interactively modify code.
- **Configuration**:
  - The main settings are located in the [lua/user/copilot.lua](./lua/user/copilot.lua) file, and the prompts are read from `.md` files in the `CopilotChatPrompts` directory.
  - The corresponding prompts are managed in `.md` files located in the [docs/CopilotChatPrompts](./docs/CopilotChatPrompts) directory.
    - Each prompt's corresponding file and its purpose can be found in [docs/CopilotChatPrompts/Index.md](./docs/CopilotChatPrompts/Index.md).
    - <details>
        <summary><b>Usage</b></summary>

        - Open the chat interface (use the following commands or set the commands in the keymap to activate)
          - `:CopilotChatOpen`
        - Open the **CopilotChat sub-command list** (activate in the same way as above)
          - `:lua CopilotChatPromptAction()`
        - **CopilotChat sub-command list**
          - Core commands:
            - `Explain`: Explain the selected code.
            - `Review`: Review the selected code.
            - `Fix`: Fix issues in the selected code.
            - `Optimize`: Optimize the selected code for better performance and readability.
            - `Docs`: Generate documentation comments for the selected code.
            - `Tests`: Generate tests for the selected code.
            - `FixDiagnostic`: Assist in fixing diagnostic issues in the file.
            - `Commit`: Generate a commit message for the changes, following the commitizen convention.
            - `CommitStaged`: Generate a commit message for the staged changes, following the commitizen convention.
          - Custom commands (For example):
            - `Ask`: Ask a question.
            - `ReviewClear`: Clear code review marks.
            - `OneLineComment`: Generate a one-line comment for the selected code.
            - `OneParagraphComment`: Generate a paragraph comment for the selected code.
          - As mentioned earlier:
            - The core commands are managed through `.md` files, based on the official templates with some adjustments.
            - Custom commands are also managed through `.md` files.
      </details> 


## About update lunarvim and neovim core to Latest Release

1. Can use below command to update `lunarvim` and `neovim` core to Latest Release
   ```bash
   # NOTE: Update lunarvim and neovim core to Latest Release
   sh ~/.config/lvim/UpdateNvimReleaseAndLunarCore.sh
   # NOTE: or you only want to update neovim to Latest Release
   # sh ~/.config/lvim/UpdateNvimReleaseOnly.sh
   ```
2. If update (or install) success (can use below command to init `lunarvim`)
   ```bash
   # NOTE: init lvim (install plugins and install treesitter parsers)
   # Maybe restart lvim two times above (because solve plugin dependency)
   $ lvim .
   ```
   ```vim
   " NOTE: Some Python based plugins may need this command to be run after installation.
   :UpdateRemotePlugins
   ```
