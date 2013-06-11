---
layout: default
title: Components
---

# Components

    "The time has come," the Walrus said,
    "To talk of many things:
    Of shoes - and ships - and sealing wax -
    Of cabbages - and kings -
    And why the sea is boiling hot -
    And whether pigs have wings."
    
    -- Lewis Carroll, Through the Looking-Glass

This section describes the things that make up a KeyMaster document:
instruments, songs, patches, connections, triggers, messages, and chains.
The [file format](file_format.html) page tells you how to put them all
together into a KeyMaster file.

# Instruments

An instrument represents either a MIDI input to a synth, drum machine, or
other device or a MIDI output from a controller. Run `./keymaster -l` to
list the instruments that are available.

Each instrument needs a short one-word name that you make up and a long name
that matches the name output by `keymaster -l`.

Both input and output instruments' short names must be unique. The same
short name can be used for an input and an output, however. You'd usually do
that if you have an instrument such as a keyboard that can act as both a
controller (an output instrument) and a sound module (an input instrument).

## Example

Let's say you have a keyboard controller that doesn't generate any sound on
port 0 of your MIDI interface, a typical keyboard synth (both controller and
sound generator) on purt 1, and a rack-mount sound generator on port 2.
Here's what that might look like in your KeyMaster file:

    input  con Lystereen Breath Controller
    input  kbd FancyPants MegaKeybaord
    output kbd FancyPants MegaKeybaord
    output rack UnitMaker Rack Unit 42b

# Songs

A song is a named list of patches that allow you to control your MIDI setup.
A song can have any number of patches. You can step forward and backward
through the patches in a song using the GUI movement keys or
[triggers](triggers.html).

When a song becomes the current song, its first patch is made the current
patch.

# Patches

A patch is a named collection of connections that can modify the MIDI data.
The simplest connection connects one MIDI input device directly to another
on a single channel.

## Start and Stop Bytes

A patch also has optional _start bytes_ and _stop bytes_. These are arrays
of MIDI bytes that can contain any MIDI data such as patch changes, volume
controller settings, note on or off messages (for those looong drones), and
System Exclusive messages.

# Connections

A connection connects an input instrument (all incoming channels or just
one) to a single output channel of an output instrument. All messages coming
from the input instruments are changed to be on the output instrument
channel.

When talking about the "notes" that a connection modifies, this means all
MIDI messages that have note values: note on, note off, and polyphonic
pressure.

## Program Changes

A connection can optionally send a bank number and program change to its
output instrument's channel. If a bank number is specified, first the bank
change is sent then the program change.

## Zones

A connection can optionally specify a zone: a range of keys outside of which
all MIDI data will be ignored. Since a patch can contain multiple
connections, this lets you split and layer your controllers, sending some
notes to some synths but not others.

## Transposes

A connection can transpose all notes by a fixed value. If a transposition
would cause a note number to be out of range (lower than 0 or higher than
127), then the value is wrapped around --- a note transposed up to 128
becomes 0, for example.

## Filters

A connection can optionally filter one or more MIDI messages. Any messages
coming from the input instrument that match a filtered status (channel is
ignored) are not passed through to the output.

If you just want to filter a particular controller (and not all controller
messages), see "Controller Filters" below.

## Controller Filters

A connection can optionally filter one or more controllers. Any controller
messages coming from the input instrument are not passed through to the
output. Channel is ignored.

# Chains

A chain is a list of songs. A song can appear in more than one chain. One
special chain called "All Songs" contains an alphabetically-sorted list of
all songs.

# Named Messages

_NOT YET IMPLEMENTED_.

A named message is an array of MIDI bytes with a name. Named messages can be
sent using message keys or via triggers.

Named messages are sent to all output instruments. The MIDI bytes are sent
from KeyMaster with channels unchanged. If a named message contains
channel messages then the receiver will of course ignore all except those on
the channels it's configured to receive.

Note: the word "message" as used in the previous sections on this page refer
to the MIDI bytes coming from your instruments or being sent to the output
instruments. The phrase "named message" refers to one of these things we're
talking about here.

## Message Keys

You can assign named messages to keys when using the KeyMaster GUI.
Whenever the assigned key is pressed, the corresponding message is sent. See
[KeyMaster Files](file:file_format.org) for how to assign a named message to a key.

# Triggers

A trigger looks for a particular incoming MIDI message from a paticular
input instrument and sends MIDI data when it is seen.
