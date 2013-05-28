/* -*- objc -*- */

#import <Foundation/NSArray.h>
#import <Instrument.h>

@class Connection, Trigger;

@interface InputInstrument : Instrument {
    NSMutableArray *connections;
    NSMutableArray *triggers;
}

+ (id)withShortName:(NSString *)sn
           longName:(NSString *)ln
           endpoint:(PYMIDIEndpoint *)endpoint;

- (id)initWithShortName:(NSString *)sn
               longName:(NSString *)ln
               endpoint:(PYMIDIEndpoint *)endpoint;

- (NSArray *)connections;
- (NSArray *)triggers;

- (id)addConnection:(Connection *)c;
- (id)removeConnection:(Connection *)c;

- (id)addTrigger:(Trigger *)t;

- (id)start;
- (id)stop;

- (void)processMIDIPacketList:(MIDIPacketList*)packetList sender:(id)sender;

@end
