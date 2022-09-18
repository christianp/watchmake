# WatchMake

This is a tool which runs `make` when a file in the current directory is changed.

You can configure it with a file called `.watchmakerc` in the directory you're running it from.

The file should contain some YAML in the following format:

```
default_make:  # A list ofmake targets to run
extensions:    # A list of file extensions that should trigger make. If not given, all files trigger make.
path:          # A list of subdirectories to watch. If not given, all subdirectories under this one are watched.
```

I wrote this to learn Elixir, and to replace my existing Python script which is quite fiddly.

## How to run it
Build a release by running ``mix release``.

Then the folder `_build/dev/rel/watchmake` contains everything needed to run the program.

Run `_build/dev/rel/watchmake/bin/watchmake start` to start it.

Press <kbd>Ctrl+C</kbd> twice to end it.
