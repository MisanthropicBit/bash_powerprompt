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
if [ -e ~/.bash_powerline.sh ]; then
    source ~/.bash_powerline.sh
    export PROMPT_COMMAND=__bash_powerline_prompt
fi
```

## Customisation

You can change the appearance of the prompt using any of the [predefined
themes](https://raw.githubusercontent.com/MisanthropicBit/bash_powerline/master/themes.md). To
create your own theme, see
[CUSTOMISING.md](https://raw.githubusercontent.com/MisanthropicBit/bash_powerline/master/CUSTOMISING.md).
