#import <MockOutputInstrument.h>

@implementation MockOutputInstrument

+ (id)withShortName:(NSString *)sn longName:(NSString *)ln {
    return [[MockOutputInstrument alloc] initWithShortName:sn longName:ln];
}

- (id)initWithShortName:(NSString *)sn longName:(NSString *)ln {
    buffer = [NSMutableData dataWithCapacity:16];
    return [super initWithShortName:sn longName:ln endpoint:nil];
}

- (id)sendPacketList:(MIDIPacketList *)packetList {
    int i;
    MIDIPacket *packet = &packetList->packet[0];
    for (i = 0; i < packetList->numPackets; ++i) {
        [buffer appendBytes:(Byte *)packet->data length:(NSUInteger)packet->length];
        packet = MIDIPacketNext(packet);
    }
    return self;
}

- (NSData *)buffer {
    return buffer;
}

- (id)reset {
    buffer = [NSMutableData dataWithCapacity:16];
    return self;
}

@end
