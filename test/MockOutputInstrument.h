/* -*- objc -*- */

#import <Foundation/NSArray.h>
#import <CoreMidi/CoreMidi.h>
#import <OutputInstrument.h>

@interface MockOutputInstrument : OutputInstrument {
    NSMutableData *buffer;
}

+ (id)withShortName:(NSString *)sn
           longName:(NSString *)ln;

- (id)initWithShortName:(NSString *)sn longName:(NSString *)ln;

- (id)sendPacketList:(MIDIPacketList *)packetList;
- (NSData *)buffer;

- (id)reset;
    
@end
