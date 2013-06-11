# KeyMaster

KeyMaster similar to [PatchMaster](http://patchmaster.org/), but it's for
the Mac and it's written in Objective C.

I wrote a native Mac app because when playing through PatchMaster, I was
getting lag. KeyMaster uses the Mac's native MIDI framework as wrapped by
Pete Yandell's excellent [PYMIDI](https://github.com/notahat/pymidi)
library.

# Documentation

The [online documentation](http://jimm.github.io/keymaster) for KeyMaster
includes detailed explanations, a tutorial, tips and tricks, and more.

# Building

    make

# Testing

    make test

## Testing Setup

Before you run the test, you'll have to copy or link the SenTestingKit
framework to somewhere like /System/Library/Frameworks. I can't figure out
how to set `@rpath` at runtime. I've tried using `DYLD_LIBRARY_PATH` and a
few other things. For tests to run properly, I link the framework in to
`/System/Library/Frameworks`. You can do that, or copy the directory instead
of linking, or figure out how to set `@rpath` (and tell me, please).

To create a link:

    sudo ln -s \
        /Applications/Xcode.app/Contents/Developer/Library/Frameworks/SenTestingKit.framework \
        /System/Library/Frameworks/SenTestingKit.framework

# Running

    ./keymaster examples/example.km

# Bugs

No known bugs. _If that doesn't tempt fate, I don't know what will._

# To Do

* More documentation
* More complex filters
* Better example with better comments
* Aliases
* Named Messages and Message Keys

# Thanks

KeyMaster uses PYMIDI (http://github.com/notahat/pymidi) by Pete Yandell.
PYMIDI is released under the MIT license, a copy of which can be found in
`src/PYMIDI/MIT-LICENSE`.
