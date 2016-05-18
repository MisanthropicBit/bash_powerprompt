# Bash Powerline Command Prompt

A `bash` script that gives you a visually pleasing, informative and customisable command line prompt.

![The default prompt](/screenshots/default_prompt.png)

* Written in pure `bash` with no dependencies
* Multiple predefined [themes](/themes.md)
* [Customisable](/CUSTOMISING.md)

## Requirements

* A `bash` shell

However, the [powerline themes](/themes.md#power-line-style-prompts) require a [powerline
font](https://github.com/powerline/fonts) to be installed, while some other themes use utf-8
symbols.

<!--* At least `bash` v?.-->
<!--* A terminal capable of displaying utf-8-->
<!--* A patched [powerline font](https://github.com/powerline/fonts) set up with your terminal-->

## Installation

You can **optionally** run `install.sh` to set up a symlink to your home directory.

Add the following to your `~/.bashrc` or `~/.profile` etc., substituting with the correct
path if necessary.

```bash
if [ -e ~/.bash_powerline.sh ]; then
    source ~/.bash_powerline.sh
    export BASH_POWERLINE_THEME=<whatever theme you like> # Optional
    export PROMPT_COMMAND=__bash_powerline_prompt
fi
```

## Customisation

You can switch the theme of the prompt to any of the [predefined
themes](/themes.md) by changing the environment variable `BASH_POWERLINE_THEME`
to a theme name in the `themes/` directory (without the extension). For more
information about customisation, see [CUSTOMISING.md](/CUSTOMISING.md).
