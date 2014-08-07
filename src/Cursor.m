#import <KeyMaster.h>
#import <Cursor.h>
#import <Chain.h>
#import <Song.h>
#import <Patch.h>

@interface Cursor (private)
- (BOOL)isChainEmpty;
- (BOOL)isSongEmpty;
- (BOOL)isPatchEmpty;
@end

/*
 * Cursor is not responsible for calling patch enter/exit methods.
 */
@implementation Cursor

- (id)init {
    self = [super init];
    chain = nil;
    song = nil;
    patch = nil;
    songIndex = patchIndex = 0;
    return self;
}

- (id)cursorInitialize {
    chain = [[KeyMaster instance] allSongs];
    song = [chain count] > 0 ? [[chain songs] objectAtIndex:0] : nil;
    if (song != nil)
        patch = ![self isSongEmpty] ? [[song patches] objectAtIndex:0] : nil;
    return self;
}

- (Patch *)patch {
    return patch;
}

- (id)patch:(Patch *)p {
    patch = p;
    song = [p song];
    return self;
}

- (Patch *)nextPatch {
    if ([self lastPatchInSong])
        [self nextSong];
    else {
        [patch stop];
        patch = [[song patches] objectAtIndex:++patchIndex];
        [patch start];
    }
    return patch;
}

- (Patch *)prevPatch {
    if ([self firstPatchInSong]) {
        [self prevSong];
    }
    else {
        [patch stop];
        patch = [[song patches] objectAtIndex:--patchIndex];
        [patch start];
    }
    return patch;
}

- (BOOL)firstPatchInSong {
    return [self isSongEmpty] || patchIndex == 0;
}

- (BOOL)lastPatchInSong {
    return [self isSongEmpty] || patchIndex == [[song patches] count] - 1;
}

- (Song *)song {
    return song;
}

- (Song *)nextSong {
    if ([self lastSongInChain])
        return song;

    [patch stop];
    song = [[chain songs] objectAtIndex:++songIndex];
    patchIndex = 0;
    if (![self isSongEmpty]) {
        patch = [[song patches] objectAtIndex:patchIndex];
        [patch start];
    }
    return song;
}

- (Song *)prevSong {
    if ([self firstSongInChain])
        return song;

    [patch stop];
    song = [[chain songs] objectAtIndex:--songIndex];
    patchIndex = 0;
    if (![self isSongEmpty]) {
        patch = [[song patches] objectAtIndex:patchIndex];
        [patch start];
    }
    return song;
}

- (BOOL)firstSongInChain {
    return [self isChainEmpty] || songIndex == 0;
}

- (BOOL)lastSongInChain {
    return [self isChainEmpty] || songIndex == [chain count] - 1;
}

- (Song *)gotoSongWithNameMatching:(NSString *)regexString {
    Song *s = [chain findSongWithNameMatching:regexString];
    if (s == nil)
        s = [[[KeyMaster instance] allSongs] findSongWithNameMatching:regexString];
    if (s == nil)
        return song;            // don't go anywhere
    
    song = s;
    NSUInteger index = [[chain songs] indexOfObject:s];
    if (index != NSNotFound)
        songIndex = index;

    [patch stop];
    patchIndex = 0;
    if (![self isSongEmpty]) {
        patch = [[song patches] objectAtIndex:patchIndex];
        [patch start];
    }
    return s;
}

- (Chain *)gotoChainWithNameMatching:(NSString *)regexString {
    Chain *c = [[KeyMaster instance] findChainWithNameMatching:regexString];
    if (c != nil) {
        [self chain:c];
        return c;
    }
    else
        return chain;           // don't go anywhere
}

- (BOOL)isChainEmpty {
    return [[chain songs] count] == 0;
}

- (BOOL)isSongEmpty {
    return [[song patches] count] == 0;
}

- (Chain *)chain {
    return chain;
}

- (id)chain:(Chain *)c {
    chain = c;
    [patch stop];
    songIndex = 0;
    if (![self isChainEmpty]) {
        song = [[chain songs] objectAtIndex:songIndex];
        patchIndex = 0;
        if (![self isSongEmpty]) {
            patch = [[song patches] objectAtIndex:patchIndex];
            [patch start];
        }
    }
            
    return self;
}

@end
