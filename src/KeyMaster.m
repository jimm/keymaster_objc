#import <stdio.h>
#import <curses.h>
#import <PYMIDI/PYMIDI.h>
#import <KeyMaster.h>
#import <Chain.h>
#import <Song.h>
#import <Patch.h>
#import <Cursor.h>
#import <InputInstrument.h>
#import <OutputInstrument.h>
#import <curses/Geometry.h>
#import <curses/ListWindow.h>
#import <curses/PatchWindow.h>
#import <curses/TriggerWindow.h>
#import <curses/InfoWindow.h>
#import <curses/PromptWindow.h>

@interface KeyMaster (Private)
- ncursesInit;
- ncursesShutdown;
- createWindows;
- resizeWindows;
- refreshAll;
- setWindowData;
- (int)nextKeyPress;
@end

KeyMaster *km = nil;

@implementation KeyMaster

+ (KeyMaster *)instance {
    if (km == nil)
        km = [[KeyMaster alloc] init];
    return km;
}

- init {
    self = [super init];

    manager = [PYMIDIManager sharedInstance];
    allSongs = [Chain withName:@"All Songs"];
    chains = [[NSMutableArray alloc] init];
    [chains addObject:allSongs];
    cursor = [[Cursor alloc] init];
    inputs = [[NSMutableArray alloc] init];
    outputs = [[NSMutableArray alloc] init];

    songListsWin = nil;
    songListWin = nil;
    songWin = nil;
    patchWin = nil;
    triggerWin = nil;
    infoWin = nil;

    running = NO;

    return self;
}

- (id)printSourcesAndDestinations {
    printf("sources:\n");
    NSEnumerator *enumerator = [[manager realSources] objectEnumerator];
    PYMIDIEndpoint *ep;
    PYMIDIEndpointDescriptor *desc;
    while (ep = [enumerator nextObject]) {
        printf("\t%s\n", [[ep displayName] cStringUsingEncoding:NSASCIIStringEncoding]);

        desc = [ep descriptor];
        printf("\tdesc name \"%s\", desc id %08x\n", [[desc name] cStringUsingEncoding:NSASCIIStringEncoding], [desc uniqueID]);
    }

    printf("destinations:\n");
    enumerator = [[manager realDestinations] objectEnumerator];
    while (ep = [enumerator nextObject]) {
        printf("\t%s\n", [[ep displayName] cStringUsingEncoding:NSASCIIStringEncoding]);

        desc = [ep descriptor];
        printf("\tdesc name \"%s\", desc id %08x\n", [[desc name] cStringUsingEncoding:NSASCIIStringEncoding], [desc uniqueID]);
    }

    return self;
}

- (id)start {
    [cursor cursorInitialize];
    [[cursor patch] start];
    for (InputInstrument *input in inputs)
        [input start];
    running = YES;
    return self;
}

- (id)stop {
    [[cursor patch] stop];
    for (InputInstrument *input in inputs)
        [input stop];
    running = NO;
    return self;
}

- (id)run {
    NSString *regex;

    [self start];
    [self ncursesInit];
    [self createWindows];

    queuedKey = 0;
    BOOL done = NO;
    while (!done) {
        [self refreshAll];
        int ch = [self nextKeyPress];
        switch (ch) {
        case KEY_RESIZE:
            [self resizeWindows];
            break;
        case 'j': case KEY_DOWN:
            [cursor nextPatch];
            break;
        case 'k': case KEY_UP:
            [cursor prevPatch];
            break;
        case 'n': case KEY_RIGHT:
            [cursor nextSong];
            break;
        case 'p': case KEY_LEFT:
            [cursor prevSong];
            break;
        case 'g':
            regex = [[PromptWindow withTitle:@"Go To Song" prompt:@"Go To Song:"] gets];
            if ([regex length] > 0)
                [cursor gotoSongWithNameMatching:regex];
            break;
        case 't':
            regex = [[PromptWindow withTitle:@"Go To Chain" prompt:@"Go To Chain:"] gets];
            if ([regex length] > 0)
                [cursor gotoChainWithNameMatching:regex];
            break;
        case 'h': case '?':
            // help
            break;
        case 27:                // ESC
            // panic
            break;
        case 'q':
            done = YES;
            break;
        }
    }

    [self ncursesShutdown];
    [self stop];
    return self;
}

- (PYMIDIManager *)manager {
    return manager;
}

- (PYMIDIEndpoint *)inputNamed:(NSString *)name {
    for (id endpoint in [manager realSources])
        if ([[endpoint displayName] isEqualToString:name])
            return endpoint;
    return nil;
}

- (InputInstrument *)inputWithShortName:(NSString *)name {
    for (id input in inputs)
        if ([[input shortName] isEqualToString:name])
            return input;
    NSLog(@"Can not find output instrument named %@", name);
    return nil;
}

- (NSArray *)inputs {
    return inputs;
}

- (id)addInput:(InputInstrument *)input {
    [inputs addObject:input];
    return self;
}

- (PYMIDIEndpoint *)outputNamed:(NSString *)name {
    for (id endpoint in [manager realDestinations])
        if ([[endpoint displayName] isEqualToString:name])
            return endpoint;
    return nil;
}

- (OutputInstrument *)outputWithShortName:(NSString *)name {
    for (id output in outputs)
        if ([[output shortName] isEqualToString:name])
            return output;
    NSLog(@"Can not find output instrument named %@", name);
    return nil;
}

- (NSArray *)outputs {
    return outputs;
}

- (id)addOutput:(OutputInstrument *)output {
    [outputs addObject:output];
    return self;
}

- (id)addChain:(Chain *)chain {
    [chains addObject:chain];
    return self;
}

- (id)addSong:(Song *)song {
    [allSongs addSong:song];
    // FIXME
    // [allSongs sortBySongName];
    return self;
}

- (Chain *)findChainWithNameMatching:(NSString *)regexString {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error != nil) {
        NSLog(@"%@", error);
        return nil;
    }

    for (id c in chains) {
        NSTextCheckingResult *match = [regex firstMatchInString:[c name]
                                                        options:0
                                                          range:NSMakeRange(0, [[c name] length])];
        if (match != nil)
            return c;
    }
    return nil;
}

- (Chain *)allSongs {
    return allSongs;
}

- (NSArray *)chains {
    return chains;
}

- (Cursor *)cursor {
    return cursor;
}

- (id)queueKeyPress:(int)key {
    queuedKey = key;
    return self;
}

// For testing only.
- (int)queuedKey {
    return queuedKey;
}

- (int)nextKeyPress {
    int ch = 0;
    if (queuedKey > 0) {
        ch = queuedKey;
        queuedKey = 0;
    }
    else
        ch = getch();
    return ch;
}

- (id)ncursesInit {
    initscr();
    cbreak();
    noecho();
    nonl();
    intrflush(stdscr, FALSE);
    keypad(stdscr, TRUE);
    refresh();                  // first call clears screen
    return self;
}

- (id)ncursesShutdown {
    nl();
    echo();
    nocbreak();
    endwin();
    return self;
}

- (id)createWindows {
    Geometry *g = [[Geometry alloc] init];
    songListsWin = [ListWindow withRect:[g songListsRect] titlePrefix:nil];
    songListWin = [ListWindow withRect:[g songListRect] titlePrefix:@"Song List"];
    songWin = [ListWindow withRect:[g songRect] titlePrefix:@"Song"];
    patchWin = [PatchWindow withRect:[g patchRect] titlePrefix:@"Patch"];
    NSRect r = [g messageRect];
    messageWin = newwin((int)r.size.height, (int)r.size.width, (int)r.origin.y, (int)r.origin.x);
    triggerWin = [TriggerWindow withRect:[g triggerRect]];
    infoWin = [InfoWindow withRect:[g infoRect]];
    return self;
}

- (id)resizeWindows {
    Geometry *g = [[Geometry alloc] init];
    [songListsWin moveAndResizeTo:[g songListsRect]];
    [songListWin moveAndResizeTo:[g songListRect]];
    [songWin moveAndResizeTo:[g songRect]];
    [patchWin moveAndResizeTo:[g patchRect]];
    [triggerWin moveAndResizeTo:[g triggerRect]];
    [infoWin moveAndResizeTo:[g infoRect]];

    NSRect r = [g messageRect];
    wmove(messageWin, r.origin.y, r.origin.x);
    wresize(messageWin, r.size.height, r.size.width);

    return self;
}

- (id)refreshAll {
    [self setWindowData];
    [[songListsWin draw] noutrefresh];
    [[songListWin draw] noutrefresh];
    [[songWin draw] noutrefresh];
    [[patchWin draw] noutrefresh];
    [[infoWin draw] noutrefresh];
    [[triggerWin draw] noutrefresh];
    wnoutrefresh(stdscr);
    doupdate();
    return self;
}

- (id)chain { return [cursor chain]; }
- (id)song { return [cursor song]; }
- (id)patch { return [cursor patch]; }

- (id)setWindowData {
    [songListsWin list:chains title:@"Song Lists" currItemSel:@selector(chain)];

    Chain *chain = [self chain];
    [songListWin list:[chain songs] title:[chain name] currItemSel:@selector(song)];

    Song *song = [self song];
    if (song != nil) {
        [songWin list:[song patches] title:[song name] currItemSel:@selector(patch)];
        [infoWin text:[song notes]];

        Patch *patch = [self patch];
        [patchWin patch:patch];
    }
    else {
        [songWin list:nil title:nil currItemSel:@selector(patch)];
        [infoWin text:nil];
        [patchWin patch:nil];
    }
}

- (id)panicSendIndividualNotes:(BOOL)individual {
    for (OutputInstrument *output in outputs)
        [output panicSendIndividualNotes:individual];
}

@end
