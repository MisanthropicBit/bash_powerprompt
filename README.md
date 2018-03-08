# ![Title](/bash_powerprompt_title.png)

<!--![Build status](https://travis-ci.org/MisanthropicBit/bash_powerprompt.svg?branch=master)-->
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/MisanthropicBit/bash_powerprompt/master/LICENSE)

**This project is under active development**

A highly configurable, flexible prompt framework in `bash` with a focus on
reusability.

Below is the default prompt and several other [predefined themes](/THEMES.md)
are available.

<img src="/screenshots/default.png" width="30%" alt="The default prompt">

* Written in pure `bash` with no dependencies
* Multiple predefined [themes](/themes.md)
* Highly [customisable](/CUSTOMISING.md)

For more information about customisation and creating your own themes, see
[CUSTOMISING.md](/CUSTOMISING.md).

## Requirements

Only a `bash` shell is required for the most basic themes, but you may also want
the following installed depending on which themes you want to use.

* A [powerline font](https://github.com/powerline/fonts)
* A terminal capable of displaying unicode symbols
* A terminal capable of 88, 256 colors or true-color
* `git`, `hg` or `svn`

## Installation

You can **optionally** run `install.sh` to set up a symlink to your home directory.

Add the following to your `~/.bashrc` or `~/.profile` etc., substituting with the correct
path if necessary.

```bash
if [ -e ~/.bash_powerprompt.sh ]; then
    source ~/.bash_powerprompt.sh
    export BASH_POWERPROMPT_THEME=<your default theme> # Optional
    export PROMPT_COMMAND=__bash_powerprompt_prompt
fi
```

## Changing Themes

You can switch the theme of the prompt by changing the environment variable
`BASH_POWERPROMPT_THEME` to a theme name in the `themes/` directory (without the
`.theme` extension). For example, the following will switch to the 'paradox'
theme.

```bash
$ export BASH_POWERPROMPT_THEME=paradox
```

Alternatively, you can add [this](bin/bpp.sh) convenient function to one of your
bash config files. Source the configuration file then invoke it as follows.

```bash
$ bpp --list
arne
candy
colorful
...
$ bpp
Current theme is mairu
```
