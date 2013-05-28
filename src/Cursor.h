/* -*- objc -*- */

#import <Foundation/NSObject.h>

@class Chain, Song, Patch;

@interface Cursor : NSObject {
    Chain *chain;
    Song *song;
    NSUInteger songIndex;
    Patch *patch;
    NSUInteger patchIndex;
}

- (id)init;

- (id)cursorInitialize;

- (Patch *)patch;
- (id)patch:(Patch *)patch;
- (Patch *)nextPatch;
- (Patch *)prevPatch;

- (BOOL)firstPatchInSong;
- (BOOL)lastPatchInSong;

- (Song *)song;
- (Song *)nextSong;
- (Song *)prevSong;

- (BOOL)firstSongInChain;
- (BOOL)lastSongInChain;

- (Song *)gotoSongWithNameMatching:(NSString *)regexString;
- (Chain *)gotoChainWithNameMatching:(NSString *)regexString;

- (Chain *)chain;
- (id)chain:(Chain *)chain;

@end
