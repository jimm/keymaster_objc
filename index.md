---
layout: default
title: KeyMaster
---

# KeyMaster

    Welcome. Welcome. Welcome.
    -- The entire Ig Nobel awards ceremony welcoming speech

KeyMaster is a MIDI processing and patching system. It allows a musician to
reconfigure a MIDI setup instantaneously and modify the MIDI data in real
time.

With KeyMaster a performer can split controlling keyboards, layer MIDI
channels, transpose them, send program changes and System Exclusive
messages, limit controller and velocity values, and much more. At the stomp
of a foot switch (or any other MIDI event), an entire MIDI system can be
totally reconfigured.

KeyMaster lets you describe _songs_, which are lists of _patches_ that
connect _instruments_. Those _connections_ can send program changes, set
keyboard splits, transpose, filter messages and controllers, and send volume
or other controller changes.

_Chains_ let you organize songs into set lists for live performance or in
the studio.

Any incoming MIDI message can _trigger_ an action such as moving to the next
or previous patch or song. For example, you can tell KeyMaster to move
forward or backward based on controller values coming from foot switches or
an instrument's buttons.

Any array of MIDI bytes can be stored as a named _message_ which can be sent
via a trigger or a key press. _NOT YET IMPLEMENTED_

A software panic button turns off any stuck notes.

KeyMaster is by [Jim Menard](mailto:jim@jimmenard.com). It is a rewrite of
[PatchMaster](http://patchmaster.org), in Objective C for the Mac OS. The
Github repo is [here](https://github.com/jimm/keymaster).

# Requirements

Since there's no binary version of KeyMaster yet, you'll need to compile the
code. To do so, you'll need the command line developer tools that come with
XCode.

# Installation

Download the source code. Type "make".

## Testing

Type "make test".

# Running KeyMaster

    ./keymaster -l

Lists all of the "real" MIDI inputs and outputs on your system. You'll need
to do this to get the names of the instruments.

    ./keymaster keymaster_file

Starts KeyMaster and loads `keymaster_file`.

# More Information

* Descriptions of all the [components](components.html): songs, patches, connections, filters,
  and more
* All about [patches and connections](patches.html) --- what happens when they run
* The [KeyMaster file format](file_format.html)
* [Tips and tricks](tips_and_tricks.html)
* [Screen Shots](screenshots.html)
* [Changes](changes.html) between KeyMaster versions
* [To Do](todo.html) list, including bugs and new features
