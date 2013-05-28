#import <OutputInstrument.h>
#import <string.h>
#import <consts.h>

@implementation OutputInstrument

+ (id)withShortName:(NSString *)sn longName:(NSString *)ln endpoint:(PYMIDIEndpoint *)e {
    return [[OutputInstrument alloc] initWithShortName:sn longName:ln endpoint:e];
}

- (id)sendPacketList:(MIDIPacketList *)packetList {
    [endpoint processMIDIPacketList:packetList sender:self];
    return self;
}

- (id)sendPacket:(MIDIPacket *)packet {
    MIDIPacketList *packetList = (MIDIPacketList *)malloc(sizeof(UInt32) + sizeof(MIDIPacket) + (packet->length > 256 ? packet->length - 256 : 0));
    packetList->numPackets = 1;
    memcpy((void *)packetList->packet, (const void *)packet, sizeof(MIDITimeStamp) + sizeof(UInt16) + packet->length);
    [self sendPacketList:packetList];
    free(packetList);

    return self;
}

- (id)sendData:(NSData *)data {
    MIDIPacket *packet = (MIDIPacket *)malloc(sizeof(MIDITimeStamp) + sizeof(UInt16) + [data length]);
    packet->timeStamp = 0;
    packet->length = [data length];
    memcpy((void *)packet->data, (const void *)[data bytes], [data length]);
    [self sendPacket:packet];
    free(packet);
    return self;
}

- (id)panicSendIndividualNotes:(BOOL)individual {
    NSMutableData *data = [NSMutableData dataWithCapacity:(MIDI_CHANNELS * 3 + (individual ? MIDI_CHANNELS * 128 * 3 : 0))];

    Byte bytes[3];
    int chan, note;

    bytes[2] = 0;               // last data byte always 0
    for (chan = 0; chan < MIDI_CHANNELS; ++chan) {
        bytes[0] = CONTROLLER + chan;
        bytes[1] = CM_ALL_NOTES_OFF;
        [data appendBytes:bytes length:3];
    }

    if (individual) {
        for (chan = 0; chan < MIDI_CHANNELS; ++chan) {
            bytes[0] = NOTE_OFF + chan;
            for (note = 0; note < 128; ++note) {
                bytes[1] = note;
                [data appendBytes:bytes length:3];
            }
        }
    }
    [self sendData:data];
    return self;
}

@end
