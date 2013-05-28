/* -*- objc */

#import <Foundation/NSObject.h>
#import <CoreMIDI/CoreMIDI.h>

@interface PacketMessageIterator : NSObject {
    MIDIPacket *packet;
    NSUInteger messageLength;
    NSUInteger i;
}

- (id)initWithPacket:(MIDIPacket *)packet;

- (Byte *)message;
- (NSUInteger)messageLength;
- (Byte *)nextMessage;

@end
