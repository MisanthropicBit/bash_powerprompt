# Bash Powerprompt Variables

The following is a list of all the variables set by the default theme and their
purpose. The value in parentheses in each title is the variable's default value.

#### `BASH_POWERPROMPT_THEME` ('default')

The name of the current theme.

<a href="#bpp_random_themes"></a>
#### `BASH_POWERPROMPT_RANDOM_THEMES` (<empty string>)

Themes to select from when picking a random theme. By default, all themes are
candidates for selection. If we do `export BASH_POWERPROMPT_RANDOM_THEMES="mairu
paradox`, then setting the theme to 'random' would only attempt to pick one of
those themes.

#### `BASH_POWERPROMPT_IGNORE_EMPTY_SECTIONS` (1)

If `1`, skips any sections in [`BASH_POWERPROMPT_SECTIONS`](#bpp_sections) that are empty.

#### `BASH_POWERPROMPT_USE_TILDE_FOR_HOME` (1)

If `1`, use the `~` character to denote home directories.

#### `BASH_POWERPROMPT_END_SPACING` (' ')

The amount of space (or any other characters) to use after the prompt.

#### `BASH_POWERPROMPT_SOLID_ARROW_SYMBOL` (Unicode codepoint U+)

The hexadecimal encoding of the unicode codepoint of the solid arrow symbol of a
powerline font.

#### `BASH_POWERPROMPT_THIN_ARROW_SYMBOL` (Unicode codepoint U+)

The hexadecimal encoding of the unicode codepoint of the thin arrow symbol of a
powerline font.

#### `BASH_POWERPROMPT_GIT_BRANCH_SYMBOL` (Unicode codepoint U+)

The hexadecimal encoding of the unicode codepoint of the git branch symbol of a
powerline font.

<a href="#bpp_fg_colors"></a>
#### `BASH_POWERPROMPT_FG_COLORS` ((15 15 15))

An array of foreground colors for each section. Color formats depend on the
value of [`BASH_POWERPROMPT_COLOR_FORMAT`](#bpp_color_format).

<a href="#bpp_bg_colors"></a>
#### `BASH_POWERPROMPT_BG_COLORS` ((111 107 45))

An array of background colors for each section. Color formats depend on the
value of [`BASH_POWERPROMPT_COLOR_FORMAT`](#bpp_color_format).

#### `BASH_POWERPROMPT_LEFT_PADDING` ((' ' ' ' ' '))

Whitespace padding for each section's left side.

#### `BASH_POWERPROMPT_RIGHT_PADDING` ((' ' ' ' ' '))

Whitespace padding for each section's right side.

#### `BASH_POWERPROMPT_ONLY_PS1` (0)

Used in themes that set `PS1` directly. If `1`, skips building prompt sections.

<a href="#bpp_color_format"></a>
#### `BASH_POWERPROMPT_COLOR_FORMAT` (`BASH_POWERPROMPT_COLOR_FORMAT_256`)

The color format of a theme. Accepted values are:

* [`BASH_POWERPROMPT_COLOR_FORMAT_16`](#bpp_16_colors)
* [`BASH_POWERPROMPT_COLOR_FORMAT_256`](#bpp_256_colors)
* [`BASH_POWERPROMPT_COLOR_FORMAT_TRUE_COLOR`](#bpp_true_colors).

Decides the contents of [`BASH_POWERPROMPT_FG_COLORS`](#bpp_fg_colors) and [`BASH_POWERPROMPT_BG_COLORS`](#bpp_bg_colors).

<a href="#bpp_16_colors"></a>
#### `BASH_POWERPROMPT_COLOR_FORMAT_16`

The color format string used for terminals that support 16 colors. It is meant to be
used with `printf`.

```bash
local colored_text=$(printf "${BASH_POWERPROMPT_COLOR_FORMAT_16}This is colored" "33" "46")
```

The first argument is the foreground color, the second is the background color.

<a href="#bpp_256_colors"></a>
#### `BASH_POWERPROMPT_COLOR_FORMAT_256`

The color format string used for terminals that support 256 colors. It is meant to be
used with `printf`.

```bash
local colored_text=$(printf "${BASH_POWERPROMPT_COLOR_FORMAT_256}This is colored" "126" "208")
```

The first argument is the foreground color, the second is the background color.

<a href="#bpp_true_colors"></a>
#### `BASH_POWERPROMPT_COLOR_FORMAT_TRUE_COLOR`

The color format string used for terminals that support true-color. It is meant to be
used with `printf`. Argument strings to `printf` use RGB colors.

```bash
local colored_text=$(printf "${BASH_POWERPROMPT_COLOR_FORMAT_TRUE_COLOR}This is colored" "200;74;32" "150;150;200")
```

The first argument is the foreground color, the second is the background color.

<a href="#bpp_separators"></a>
#### `BASH_POWERPROMPT_SEPARATORS`

An array of strings for the separators between each prompt section.

#### `BASH_POWERPROMPT_SEPARATOR_FG_COLORS`

An array of foreground colors for each separator. Color formats depend on the
value of [`BASH_POWERPROMPT_COLOR_FORMAT`](#bpp_color_format). Also see
[`BASH_POWERPROMPT_SEPARATORS`](#bpp_separators).

#### `BASH_POWERPROMPT_SEPARATOR_BG_COLORS`

An array of background colors for each separator. Color formats depend on the
value of [`BASH_POWERPROMPT_COLOR_FORMAT`](#bpp_color_format). Also see
[`BASH_POWERPROMPT_SEPARATORS`](#bpp_separators).

<a href="#bpp_sections"></a>
#### `BASH_POWERPROMPT_SECTIONS`

An array of the string contents of each prompt section.

#### `BASH_POWERPROMPT_EXIT_STATUS`

The exit status of the last command.

#### `BASH_POWERPROMPT_DIRECTORY`

The directory where the bash powerprompt script resides. Meant to be set by the
user and avoids having to look it up every time `PROMPT_COMMAND` is called.
