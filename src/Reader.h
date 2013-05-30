/* -*- objc -*- */

#import <Foundation/NSObject.h>

@class KeyMaster, Chain, Song, Patch, Connection, Trigger, NSData,
    InputInstrument, OutputInstrument, NSRegularExpression;

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
    NSString *notesIndentation;
    NSRegularExpression *noteRegex;
}

- (id)read:(NSString *)file;

@end

@interface Reader (testing)
- (id)km:(KeyMaster *)kmInstance;
- (Byte)byteValue:(NSString *)str;
- (Byte)noteFromStr:(NSString *)str;
- (void)notesLine:(NSString *)line;
- (NSString *)notes;
@end
