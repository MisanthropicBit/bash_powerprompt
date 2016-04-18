Customising the prompt
======================

There are a couple of configuration variables at the top of the script in the `USER CONFIGURABLE VARIABLES` section:

* `IGNORE_EMPTY_SECTIONS`: If enabled, do not display sections that return an empty string
* `COMMAND_SYMBOL`='$': Command symbol at the end of the prompt
* `SOLID_ARROW_SYMBOL`="\xee\x82\xb0": Powerline symbol (U+e0b0)
* `THIN_ARROW_SYMBOL`="\xee\x82\xb1": Powerline symbol (U+e0b1)
* `USER_CXT_SEPARATOR_SYMBOL`='@': Separator between user- and hostnames
* `PROMPT_END_SPACING`=' ': Spacing at the end of the prompt
* `GIT_BRANCH_SYMBOL`="\xee\x82\xa0": Powerline symbol that looks like a git branch
* `GIT_CLEAN_SYMBOL`="\xe2\x9c\x93": A checkmark (U+2713)
* `GIT_DIRTY_SYMBOL`="\xe2\x9c\x97": A ballot x (U+2717)
* `SEPARATOR_FG_COLOR`=15: Only used when the separator is not `SOLID_ARROW_SYMBOL`
* `GIT_BRANCH_COLOR`= : The color of the current git branch (if any). Empty by default
* `GIT_FG_CLEAN_COLOR`=76: The color for a git branch with uncommitted files
* `GIT_FG_DIRTY_COLOR`=160: The color for a git branch with a clean working directory

Introducing a new section
-------------------------

Suppose you want to add another separate section that displays your current group. Let us create a
convenience function for getting the current group:

```bash
__get_group() {
    printf "$(id -gn)"
}
```

Then define a function to format and construct the section.

```bash
__current_group() {
    printf "$(__format_color $fg $bg)$(__get_group) "
}
```

Here, `fg` and `bg` are the fore- and background colors. `__format_color` makes sure that what
follows it, will have those colors. Notice that a space was added after calling the group function.

Now go to the definition of `SECTIONS` and add the new section wherever you want, as well as the
desired fore- and background colors and separator symbols (Note that if you have `n` sections, you
will have to add `n + 1` separators to ensure that one will be inserted after the last section).

```bash
FG_COLORS=(... 15 ...)
BG_COLORS=(... 34 ...)
SECTIONS=(... __current_group ...)
SEPARATORS=(... $SOLID_ARROW_SYMBOL ...)
```

Source the script again and voilà!

Extending an existing section
-----------------------------

To extend an existing function, modify the function accordingly. For example, suppose you would
rather have the current group name as part of the default \<username>@\<hostname> section, like this
'user@host:group'.

```bash
__user_context() {
    local result="$(__get_username)$USER_CXT_SEPARATOR_SYMBOL$(__get_hostname):$(__get_group)"

    ...

    printf ...
}
```

Using `__empty_section`
-----------------------

You can use the `__empty_section` function to create thick versions of the thin arrow separator symbol.

![Thick separators](https://raw.githubusercontent.com/MisanthropicBit/bash_powerline/master/screenshots/thick_separators.png)

Here is the layout:

```bash
local BG_COLORS=(162 27 205 27 24 27 202 27 129)
local SECTIONS=(__exit_status __empty_section __user_context __empty_section __cwd_context __empty_section __git_context __empty_section __prompt_end)
local SEPARATORS=($SOLID_ARROW_SYMBOL $SOLID_ARROW_SYMBOL $SOLID_ARROW_SYMBOL $SOLID_ARROW_SYMBOL $SOLID_ARROW_SYMBOL $SOLID_ARROW_SYMBOL $SOLID_ARROW_SYMBOL $SOLID_ARROW_SYMBOL $SOLID_ARROW_SYMBOL)
```
