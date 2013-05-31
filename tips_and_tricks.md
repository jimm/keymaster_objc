---
layout: default
title: Tips and Tricks
---

# Tips and Tricks

    An invasion of armies can be resisted, but not an idea whose time has come.
    -- Victor Hugo

This section contains some ideas that will hopefully spur you to even more
interesting and creative uses of KeyMaster.

# Don't Panic!

Hitting ESCAPE sends all-notes-off messages to every output instrument on
all 16 MIDI channels. Hitting ESCAPE a second time sends individual note off
messages to every note on all 16 channels to every output instrument.

# From One, Many

You can turn one note into multiple notes by setting up two different
connections that connect the same input to the same output.

# This One Goes to 11

Use start bytes or messages to set initial volumes for instruments, for
example resetting all instrument's volumes to 127.

# Hands-Free

Use KeyMaster to play notes! A patch's start bytes can be used to play one
or more notes-on messages, and the stop bytes can be used to play the
corresponding note-off messages.

# Tuning

You might want to set up a song that helps you tune your instruments
by sending the proper program changes and entering note on and note
off commands that play the tuning note on different synths. (Yes,
you actually had to tune most older synths.) For example,

1. Patch One

   - Start message: program changes and note-ons for reference synth A and
     another synth (B).
   - Stop message: note-off for synth B.

2. Patch Two

   - Start message: program change and note-on for synth C.
   - Stop message: note-off for synth C.

3. Patch Three

   - Start message: program change and note-on for synth D.
   - Stop message: note-offs for synth D and reference synth A.

# Matching Names

When you enter the name of a chain, song, or patch on the screen, you need
not type the whole name. Just use the shortest unique prefix of the name.
Actually, you can type any regular expression, and the match need not be at
the beginning of the name. Also, you needn't worry about matching upper and
lower case; all name comparisons are case-insensitive (the regular
expression is automatically made to match case-insensitively).
