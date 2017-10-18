# Contributing

Contributing is pretty straightforward:

1. Fork/clone this project and make your modifications
2. Submit a pull request

However, **please** ensure that you have done the following before submitting:

1. [Your commit messages do not suck](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).
2. All commits have been squashed into one commit.
3. You report which version of `bash` you are using.
4. You stick to the existing coding style.

# Contributing a theme

You can also contribute a new theme via a pull request, but **please** ensure the following:

1. You abide by the requirements for normal pull requests as given above.
2. All theme names are in snake case, e.g.\ 'my_awesome_theme'.
3. You list an (optional) description of the theme and its requirements. See the
   [default theme](/themes/default.theme) for an example. You can use the
   [theme_template](/theme_template.theme) as a starting point.
4. Your pull request includes a screenshot using the same [layout](/themes.md) as the
   predefined themes for section names. Only PNGs are currently accepted and the
   image's size should be X x Y.
5. Test that your themes works in different settings, e.g. does it work when the
   working tree of a version control system are in different states? Does it
   work when you `cd` to root? Try and hit as many corner cases as possible.
