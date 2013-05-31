---
layout: default
title: Tutorial
---

# Tutorial

This tutorial walks you through creating a KeyMaster file from scratch.

KeyMaster files are text files, typically named with a ".km" extension.

The KeyMaster file we'll be creating in this tutorial is verbose. There are
short forms of most of the commands and some of the things we include are
optional.

# Defining Your Instruments

## Find your instruments

In a terminal window, type

    ./keymaster -l

This command lists all the input and output instruments that are attached to
your Mac, whether physical or virtual. You'll need to remember the names
output instrument numbers listed by `keymaster`.

## Add them to your KeyMaster file

Open a file in your text editor. For each MIDI input output you want to use,
add a line like this:

    input keys Long Name

The Long Name is the name you got from the `./keymaster -l` command.
"shorty" is any short name; it's what you will use to refer to that MIDI
input in the rest of the file. That short name must be one word; it can't
contain any spaces.

The name for each input instrument must be different.

Likewise, for each MIDI output add a line like this:

    output module, Long Name

Output names must be unique, but can be the same as input names. For a MIDI
instrument that uses both its input and its output you will probably want to
use the same name.

# Your First Song

After the instrument inputs and outputs, add an empty song:

    song My First Song

## A Patch

Let's add a patch that connects the input from any channel that `keys` sends
to the output `another` on channel 1.

    song My First Song
      patch First Patch
        connection keys another 1

Because we don't specify a channel for `keys`, any channel message that
comes from it will be used. The 1 tells KeyMaster to translate all messages
from `keys` to channel 1 before sending it to `another`.

Now let's connect `keys` to the same synth on a different channel but
modify the MIDI a bit as it goes through.

    song My First Song
      patch First Patch
        connection keys another 1
        connection keys another 2
          prog_chg 42
          transpose 12
          zone C4, B6

Here we've connected `keys` to channel 2 of `another`, sent it a program
change command, transposed all notes (and polyphonic pressure messages) up
an octave, and limited the notes passed through to those in the two octaves
from C4 to B6.

# Creating Triggers

Triggers make things happen. Let's make a trigger that moves to the next
patch and one that sends a tune request message.

(_TODO: finish this section_)

Bonus exercise: Write triggers that move to the next song, the previous
patch and the previous song.

# A Song List

(_TODO: write this section_)

# The Whole File

The whole file should look something like this. Blank lines don't matter.

    input keys Long Name
  
    output keys Long Name
    output another Another Long Name
    output third Rack Mount Synth
  
    song My First Song
      patch First Patch
        connection keys nil another 1
        connection keys nil another 2
          prog_chg 42
          transpose 12
          zone C4 B6
        connection keys nil third 1
