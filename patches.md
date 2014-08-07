---
layout: default
title: Patches
---

# Running Patches

    A wandering minstrel I -
    A thing of threads and patches,
    Of ballads, songs and snatches,
    And dreamy lullaby!

    -- Sir William Gilbert, The Mikado

When a patch is started it becomes the _current patch_. Each connection is
started (see below) and passed the patch's start bytes to send to its output
instrument. When a patch is stopped, each connection is stopped and passed
the stop bytes to send to its output.

# Connections

Connections have an input instrument and (optional) input channel, output
instrument and channel, and the following optional values:

* Program bank number
* Program change number
* Keyboard zone (low/high keys)
* Transpose
* Message filter
* Controller filter

If the input instrument's channel is not specified then all input from that
instrument is run through the connection. If the channel is specified then
any incoming MIDI bytes on other channels are ignored.

## Start

When a connection is started:

* The start bytes from the patch, if any, are sent to the output instrument
  as-is (in particular, status bytes' channels are not changed)l

* The program change is sent to the output instrument (on the channel
  defined for the output instrument, of course).

* The connection adds itself to its input instrument's list of outgoing
  connections.

## Stop

When a connection is stopped:

* The stop bytes from the patch, if any, are sent to the output instrument
  as-is (in particular, status bytes' channels are not changed).

* The connection removes itself from its input instrument's list of outgoing
  connections.

# Processing Incoming MIDI Data

While the current patch is running, MIDI data that comes in from an
instrument causes two things happen:

* The data is sent to the instrument's triggers. Each trigger looks at the
  data and decides if it should act by executing its block of code.

* The data is then sent to each of the connections connected to the
  instrument.

An input instrument can be used by more than one connection. Each connection
can modify the data and send it to a different MIDI instrument.

* The data is ignored if it is not on the input instrument's selected
  channel for that connection. If no input channel is specified in a
  connection, then all incoming data is accepted.

* Note messages (note on, note off, and polyphonic pressure) are transposed.

* Channel messages (note on, note off, polyphonic pressure, controller,
  program change, channel pressure, and pitch bend) have their channel
  changed to the output instrument's selected channel.

* The resulting bytes, if any, are sent to the output instrument.