/* -*- objc -*- */

#import <Foundation/NSArray.h>
#import <curses.h>

@class Chain, Song, Cursor, PYMIDIManager, ListWindow, PatchWindow,
    TriggerWindow, InfoWindow, InputInstrument, OutputInstrument,
    PYMIDIEndpoint;

@interface KeyMaster : NSObject {
    Chain *allSongs;
    NSMutableArray *chains;
    Cursor *cursor;
    PYMIDIManager *manager;
    NSMutableArray *inputs;
    NSMutableArray *outputs;

    ListWindow *songListsWin;
    ListWindow *songListWin;
    ListWindow *songWin;
    PatchWindow *patchWin;
    WINDOW *messageWin;
    TriggerWindow *triggerWin;
    InfoWindow *infoWin;

    BOOL done;
    BOOL testingKeySent;
}

+ (KeyMaster *)instance;

- (id)printSourcesAndDestinations;

- (id)run;

- (PYMIDIManager *)manager;

- (PYMIDIEndpoint *)inputNamed:(NSString *)name;
- (InputInstrument *)inputWithShortName:(NSString *)name;
- (NSArray *)inputs;
- (id)addInput:(InputInstrument *)input;

- (PYMIDIEndpoint *)outputNamed:(NSString *)name;
- (OutputInstrument *)outputWithShortName:(NSString *)name;
- (NSArray *)outputs;
- (id)addOutput:(OutputInstrument *)output;

- (Chain *)allSongs;
- (NSArray *)chains;
- (Cursor *)cursor;

- (id)addChain:(Chain *)chain;
- (id)addSong:(Song *)song;

- (Chain *)findChainWithNameMatching:(NSString *)regexString;

- (id)executeKeyPress:(int)key;

- (id)panicSendIndividualNotes:(BOOL)individual;

@end

@interface KeyMaster (testing)
- (id)start;
- (id)stop;

- (int)testingKey;
- (BOOL)testingKeySent;
- (id)testingKeySent:(BOOL)value;
@end
