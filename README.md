---
title: My Neovim Config (lunavim)
author: Andy6
date: 2023-10-08
---

# My Neovim Config

use neovim pre-config lunavim

## introduction

### overview (use this config)

1. install neovim
    1. install nvim.appimage
    2. alias nvim.appimage to your bashrc/zshrc
    ```bash
    echo 'alias=~/nvim.appimag' >> ~/.bashrc
    echo 'alias=~/nvim.appimag' >> ~/.zshrc
    ```
    3. install pyenv for neovim (for plug of neovim)
    ```bash
    conda install pyenv
    ```
    3. install debugpy for neovim (for debug of neovim)
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

### some notice

some server install neovim will get below error:

```bash
/lib64/libc.so.6: version `GLIBC_2.14'
```

need to use `sudo compile glibc-2.14`  
if you are only a user, suggest ask `your admin` to help you install `glbc-2.14`


