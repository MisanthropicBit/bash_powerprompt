# Selecting a preexisting theme

To change the theme, execute `export BASH_POWERLINE_THEME=<theme_name>`, where `<theme_name>` is the
name of one the [predefined themes](/themes.md) or the name of your own theme, both without the
`.theme` extension.

# Creating a new theme

Start by creating a new file called `<your_theme_name>.theme` in the `themes/` directory. You can
use one of the [predefined themes](/themes.md) as a starting point (the default theme contains
comments to explain what each variable does).

The default theme is always loaded before any custom themes, so you only need to override the parts
you want to change (like the [hybrid theme](/themes/hybrid.theme)). Below is an example theme that
displays the group and time, with explanatory comments.

```bash
__get_group() {
    printf "$(id -gn)"
}

# All themes must include this function, which is called by the main script
# The default theme is always loaded first, so we only need to override the
# parts we want to change
__set_theme() {
    # The list of foreground colors for each section from left to right
    BASH_POWERLINE_FG_COLORS=(15 15 15 15)

    # The list of background colors for each section from left to right
    BASH_POWERLINE_BG_COLORS=(6 25 90 72)

    # The list of functions that format and return the string for each section
    BASH_POWERLINE_SECTIONS=(__user_context __get_group __cwd_context __prompt_end)
}
```

Here is what the theme would look like:

![Example theme](/screenshots/example_theme.png)

As for separators, you can use the thick, powerline arrow symbol like the [default
theme](/themes/default.theme) or the thin versions like the [gemish theme](/themes/gemish.theme).
You can also "fake" thicker versions of the thin arrow using the `__empty_section` function, see the
[imperial theme](/themes/imperial.theme). Lastly, you can use any other text for the separators. See
the [commander theme](/themes/commander.theme) for an example.

Actually, the script was designed to be very flexible, so you don't have to stick with the
"powerline" look if you don't want to. See the [simplistic theme](/themes/simplistic.theme) for
an example.

You can use [this](http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html) color table for
256-color terminals (use colors 0 to 15 for 16-color terminals).

Also, the themes for the [`vim-airline`](https://github.com/vim-airline/vim-airline/wiki/Screenshots)
plugin is a good source of inspiration.

# Predefined functions

![Default theme with annotations](/screenshots/default_theme_with_annotations.png)

# Configuration variables

There are some predefined symbols you can use when designing your own theme.

* `BASH_POWERLINE_SOLID_ARROW_SYMBOL="\xee\x82\xb0"`: Powerline symbol (U+e0b0)
* `BASH_POWERLINE_THIN_ARROW_SYMBOL="\xee\x82\xb1"`: Powerline symbol (U+e0b1)
* `BASH_POWERLINE_GIT_BRANCH_SYMBOL="\xee\x82\xa0"`: Powerline symbol that looks like a git branch
* `BASH_POWERLINE_GIT_CLEAN_SYMBOL="\xe2\x9c\x93"`: A checkmark (U+2713)
* `BASH_POWERLINE_GIT_DIRTY_SYMBOL="\xe2\x9c\x97"`: A ballot x (U+2717)

There are also some configuration variables for the predefined functions.

* `BASH_POWERLINE_IGNORE_EMPTY_SECTIONS`: If enabled, do not display sections that return an empty string
* `BASH_POWERLINE_COMMAND_SYMBOL='$'`: Command symbol at the end of the prompt
* `BASH_POWERLINE_PROMPT_END_SPACING=' '`: Spacing at the end of the prompt
* `BASH_POWERLINE_SEPARATOR_FG_COLOR=15`: Only used when the separator is not `SOLID_ARROW_SYMBOL`
* `BASH_POWERLINE_GIT_BRANCH_COLOR=` : The color of the current git branch (if any). Empty by default
* `BASH_POWERLINE_GIT_FG_CLEAN_COLOR=76`: The color for a git branch with uncommitted files
* `BASH_POWERLINE_GIT_FG_DIRTY_COLOR=160`: The color for a git branch with a clean working directory
* `BASH_POWERLINE_USER_CXT_SEPARATOR_SYMBOL='@'`: Separator between user- and hostnames
