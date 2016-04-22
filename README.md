# Bash Powerline Command Prompt

A `bash` script that gives you a visually pleasing and informative commandline prompt.

![The default prompt](https://raw.githubusercontent.com/MisanthropicBit/bash_powerline/master/screenshots/default_prompt.png)

* Written in pure `bash` with no dependencies
* Easily [customisable and extendable](https://raw.githubusercontent.com/MisanthropicBit/bash_powerline/master/CUSTOMISING.md)
* Multiple predefined sections
* Fancy Unicode and Powerline symbols

## Requirements

<!--* At least `bash` v?.-->

* A terminal capable of displaying utf-8
* A patched [powerline font](https://github.com/powerline/fonts) set up with your terminal

## Installation

You can **optionally** run `install.sh` to set up a symlink to your home directory.

Add the following to your `~/.bashrc` or `~/.profile` etc., substituting with the correct
path if necessary.

```
if [[ -e ~/.bash_powerline.sh ]]; then
    source ~/.bash_powerline.sh
    export PROMPT_COMMAND=__bash_powerline_prompt
fi
```

## Customisation

See [CUSTOMISING.md](https://raw.githubusercontent.com/MisanthropicBit/bash_powerline/master/CUSTOMISING.md) for configuration options and
the [list of predefined themes](https://raw.githubusercontent.com/MisanthropicBit/bash_powerline/master/themes.md).

For more inspiration, see [`vim-airline`](https://github.com/vim-airline/vim-airline/wiki/Screenshots) and [`CUSTOMISING.md`](https://github.com/MisanthropicBit/bash_powerline/master/CUSTOMISING.md). If you want to design your own theme, you can use [this](http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html) color table for a 256-color terminal (use colors 0 to 15 for 16-color terminals).
