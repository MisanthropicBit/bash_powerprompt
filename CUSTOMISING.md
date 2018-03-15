# Selecting a preexisting theme

To change the theme, execute `export BASH_POWERLINE_THEME=<theme_name>`, where `<theme_name>` is the
name of one the [predefined themes](/THEMES.md) or the name of your own theme, both without the
`.theme` extension.

# Creating a new theme

Start by creating a new file called `<your_theme_name>.theme` in the `themes/` directory. You can
use one of the [predefined themes](/THEMES.md) as a starting point (the default theme contains
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

As for separators, you can use the thick, powerline arrow symbol like the
[default theme](/themes/default.theme) or the thin versions like the [gemish
theme](/themes/gemish.theme).  You can also "fake" thicker versions of the thin
arrow using the `__empty_section` function, see the [impact
theme](/themes/impact.theme). Lastly, you can use any other text for the
separators.

Actually, the script was designed to be very flexible, so you don't have to
stick with the "powerline" look if you don't want to. See the [simplistic
theme](/themes/simplistic.theme) for an example.

You can use [this](http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html) color table for
256-color terminals (use colors 0 to 15 for 16-color terminals).

Also, the themes for the [`vim-airline`](https://github.com/vim-airline/vim-airline/wiki/Screenshots)
plugin is a good source of inspiration.

# Configuration variables

For a complete list of configuration variables, see [this](/ENV_VARIABLES.md).
