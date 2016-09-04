# ![Title](/bash_powerprompt_title.png)

<!--![Build status](https://travis-ci.org/MisanthropicBit/bash_powerprompt.svg?branch=master)-->
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/MisanthropicBit/bash_powerprompt/master/LICENSE)

A `bash` script that gives you a visually pleasing, informative and customisable command line prompt.

![The default prompt](/screenshots/default_prompt.png)

* Written in pure `bash` with no dependencies
* Multiple predefined [themes](/themes.md)
* [Customisable](/CUSTOMISING.md)

## Requirements

* A `bash` shell

However, the [powerline themes](/themes.md#power-line-style-prompts) require a [powerline
font](https://github.com/powerline/fonts) to be installed, while some other themes use utf-8
symbols. If you use `git` or `svn`, you need that installed too.

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

## Customisation

You can switch the theme of the prompt to any of the [predefined
themes](/themes.md) by changing the environment variable `BASH_POWERPROMPT_THEME`
to a theme name in the `themes/` directory (without the extension). For more
information about customisation and creating your own themes, see
[CUSTOMISING.md](/CUSTOMISING.md).
