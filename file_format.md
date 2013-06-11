---
layout: default
title: File Format
---

# KeyMaster Files

    Source code in files. How quaint.
    -- Attributed to Kent Beck

KeyMaster files describe your MIDI setup and define named messages,
triggers, songs with their patches, and chains of songs.

For a sample KeyMaster file, see [examples/example.km](https://github.com/jimm/patchmaster/blob/master/examples/example.km).

For a more detailed discussion of the things that can be in a KeyMaster
file (how they work and what they're for), see [Components](components.html)
and [Running Patches](patches.html).

# Loading and Saving KeyMaster Files

When you start KeyMaster you can specify a file to load on the command
line.

# Editing KeyMaster Files

    Most editors are failed writers - but so are most writers.
    -- T. S. Eliot

You can create and edit KeyMaster files using any text editor you like.

[keymaster-mode.el](https://github.com/jimm/elisp/blob/master/progmodes/keymaster-mode.el)
is a simple Emacs mode for KeyMaster files.

# Anatomy of a KeyMaster File

## Comments

Comments and blank lines are ignored. A comment starts with "//" and may
appear anywhere on a line.

Indentation is ignored. It may be easier to read if you indent patches with
songs and connections within patches, for example.

## MIDI Byte Values

MIDI bytes can be written as decimal numbers, hex numbers ("0xff"), note
names ("C#3"), or the names specified in consts.m such as `NOTE_ON`,
`NOTE_OFF`, or `CC_BANK_SELECT`. For all names and hex numbers, upper/lower
case doesn't matter.

Note names start with a letter, optionally followed by '#' or 's' for sharp
or 'b' or 'f' for flat, then ending in an octave number. C4 is note
number 48.

To add a channel number to a status byte, add a colon (':') and the channel
number after the name. For example, "NOTE_OFF:4". Channels are one-based.

## MIDI Instruments

    input/output short_name Long Name

Describes MIDI inputs and outputs.

Short names must be unique within instrument type (input or output). For
example, you can have an input instrument with the short name "ws" and an
output instrument with the same short name "ws", but you can't have two
inputs or two outputs with the same short name.

Example:

    input  con Lystereen Breath Controller
    input  kbd FancyPants MegaKeybaord
    output kbd FancyPants MegaKeybaord
    output rack UnitMaker Rack Unit 42b

## Triggers

    trigger key input_inst_short_name bytes...

Input MIDI messages can cause KeyMaster to react as if you'd pressed a key.
When `bytes` are sent from the given input instrument then `key`'s action is
performed.

The key can be a single character, F1-F10, or any of the names SPACE, ESC,
UP, DOWN, LEFT, RIGHT, BACKSPACE, DELETE, ENTER, or RETURN. For all of
those names, upper/lower case doesn't matter.

Example:

    trigger n in1 CONTROLLER:4 CC_GEN_PURPOSE_5 0xff
    trigger p in1 CONTROLLER:4 CC_GEN_PURPOSE_6 0xff

## Songs

    song name

A song is a list of patches.

Example:

    song My First Song
      // patches...

### Song Notes

    song My First Song
      notes
      These are notes for the song.
      They will be displayed in the upper right window.
      end notes

### Patches

    patch name
      // connections

A patch contains connections and optional start and stop byte arrays.

* startBytes
* stopBytes
* connection

Example:

    song My First Song
      patch First Song, First Patch
        startBytes TUNE_REQUEST
        connection mb kz 2     // all chans from mb, out to ch 2 on kz
          // ...
  
        connection ws 6 sj 4  // only ch 6 from ws_kbd, out to ch 4 on sj
          // ...
  
        conn ws 6 d4 10
        stopBytes TUNE_REQUEST
      end
    end

#### Connections

    connection in_sym in_chan out_sym out_chan
      // ...
    connection in_sym out_sym out_chan
      // ...

Connects an input instrument to an output instrument. If `in_chan` is
skipped then any message coming from that instrument will be processed, else
only messages coming from the specified channel will be processed.

A connection can optionally contain bank/program changes, transposes, and a
zone.

* programChange
* zone
* transpose

All those values are optional; you don't have to specify them.

Example:

    song My First Song
      patch First Song First Patch
        connection ws 6 sj 4 do  // only chan 6 from ws out to ch 4 on sj
          programChange 100             // no bank, prog chg 100
          zone C4 B6
          transpose -12
          filter POLY_PRESSURE
          filterController VOLUME
        end
      end
    end

##### Program Changes

    programChange prog_number
    pc bank_number prog_number

"programChange", "progChg", and "pc" all send program changes. Sends
`prog_number` to the output instrument's channel. If `bank_number` is
specified, sends bank change then program change.

Only one program change per connection is allowed. If there is more than one
in a connection the last one is used.

Examples:

    progChg 42        // program change only
    pc 2 100          // bank change then program change

##### Zones

    zone low high

By default a connection accepts and processes notes (and poly pressure
messages) for all MIDI note numbers 0-127. You can use the zone command to
limit which notes are passed through. Notes outside the defined range are
ignored.

The `zone` command can take either two notes or a range. Notes can be
numbers or note names such as `C3`, `Ab3`, or `Df7` ("s" or "#" for sharp,
"f" or "b" for "flat").

Only one zone per connection is allowed. If there is more than one in a
connection the last one is used.

Example:

    zone C2 B4      // only allows notes from C2 to B4

##### Transpose

    transpose num

Specifies a note transposition that will be applied to all incoming note on,
note off, and polyphonic pressure messages.

Note that transposition occurs after a connection's zone has filtered out
incoming data, not before.

##### Filtering Messages

    filter status

`status` is a MIDI status byte name or number. You can use a decimal or
hex number or the name of a controller as specified in consts.h.

When filtering, channel is ignored.

##### Filtering Controllers

    filterController num
    fc num

`num` is a MIDI byte value (a controller number). You can use a decimal or
hex number or the name of a controller as specified in consts.h.

When filtering controllers, channel is ignored.

## Chains

    chain name
      song name
      another song name

Optional.

Example:

    chain Tonight's Song List
      First Song
      Second Song

# Aliases

Many of the keywords in KeyMaster files have short versions.

<table>
<tr>
  <th>Full Name</th>
  <th>Aliases</th>
</tr>
<tr>
  <td>connection</td><td>conn, c</td>
</tr>
<tr>
  <td>filter</td><td>f</td>
</tr>
<tr>
  <td>filterController</td><td>fc</td>
</tr>
<tr>
  <td>input</td><td>in</td>
</tr>
<tr>
  <td>message</td><td>msg</td>
</tr>
<tr>
  <td>messageKey</td><td>msgKey</td>
</tr>
<tr>
  <td>output</td><td>out</td>
</tr>
<tr>
  <td>programChange</td><td>pc, progChg</td>
</tr>
<tr>
  <td>transpose</td><td>xpose, x</td>
</tr>
<tr>
  <td>zone</td><td>z</td>
</tr>
</table>
