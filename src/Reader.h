/* -*- objc -*- */

#import <Foundation/NSObject.h>

@class KeyMaster, Chain, Song, Patch, Connection, Trigger, NSData,
    InputInstrument, OutputInstrument;

@interface Reader : NSObject {
    KeyMaster *km;
    Chain *chain;
    Song *song;
    Patch *patch;
    Connection *connection;
    Trigger *trigger;
    BOOL readingNotes;
    BOOL readingChain;
    NSString *notes;
}

- (id)read:(NSString *)file;

@end
