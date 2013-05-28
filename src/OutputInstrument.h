/* -*- objc -*- */

#import <Foundation/NSArray.h>
#import <CoreMidi/CoreMidi.h>
#import <Instrument.h>

@class NSData;

@interface OutputInstrument : Instrument

+ (id)withShortName:(NSString *)sn
           longName:(NSString *)ln
           endpoint:(PYMIDIEndpoint *)endpoint;

- (id)sendPacketList:(MIDIPacketList *)packetList;
- (id)sendPacket:(MIDIPacket *)packet;
- (id)sendData:(NSData *)message;
    
- (id)panicSendIndividualNotes:(BOOL)individual;

@end
