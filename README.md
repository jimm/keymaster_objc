# KeyMaster

KeyMaster similar to [PatchMaster](http://patchmaster.org/), but it's for
the Mac and it's written in Objective C.

# Building

    make

# Testing

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

To run the tests:

    make test

# To Do

* Documentation
* Filters
* Better example with better comments

# Thanks

KeyMaster uses PYMIDI (http://github.com/notahat/pymidi) by Pete Yandell.
PYMIDI is released under the MIT license, a copy of which can be found in
`src/PYMIDI/MIT-LICENSE`.
