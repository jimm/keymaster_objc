#import <Foundation/NSData.h>
#import <Connection.h>
#import <InputInstrument.h>
#import <OutputInstrument.h>
#import <PacketMessageIterator.h>
#import <consts.h>

#define LIST_OVERHEAD 1024

@interface Connection (private)
- (BOOL)acceptInput:(Byte *)data;
- (BOOL)byte:(Byte)b isInData:(NSData *)data;
@end

@implementation Connection

- (id)init {
    self = [super init];
    input = nil;
    inputChan = UNDEFINED;
    output = nil;
    outputChan = UNDEFINED;
    bank = UNDEFINED;
    pcProg = UNDEFINED;
    zoneLow = 0;
    zoneHigh = 127;
    xpose = 0;
    filteredControllerNumbers = [NSMutableData dataWithCapacity:4];
    filteredStatuses = [NSMutableData dataWithCapacity:4];
    return self;
}

- (id)start:(NSData *)startData {
    int len =
        (startData == nil ? 0 : [startData length]) +
        (bank == UNDEFINED ? 0 : 3) +
        (pcProg == UNDEFINED ? 0 : 2);
    if (len > 0) {
        NSMutableData *data = [NSMutableData dataWithCapacity:len];
        if (startData != nil)
            [data appendData:startData];
        if (bank != UNDEFINED) {
            Byte bytes[3] = {CONTROLLER + outputChan, CC_BANK_SELECT+32, bank};
            [data appendBytes:bytes length:3];
        }
        if (pcProg != UNDEFINED) {
            Byte bytes[2] = {PROGRAM_CHANGE + outputChan, pcProg};
            [data appendBytes:bytes length:2];
        }

        [output sendData:data];
    }
    [input addConnection:self];
    return self;
}

- (id)stop:(NSData *)stopData {
    if (stopData != nil && [stopData length] > 0)
        [output sendData:stopData];
    [input removeConnection:self];
    return self;
}

- (InputInstrument *)input {
    return input;
}

- (id)input:(InputInstrument *)i {
    input = i;
    return self;
}

- (int)inputChan {
    return inputChan;
}

- (id)inputChan:(int)ch {
    inputChan = ch;
    return self;
}

- (OutputInstrument *)output {
    return output;
}

- (id)output:(OutputInstrument *)o {
    output = o;
    return self;
}

- (int)outputChan {
    return outputChan;
}

- (id)outputChan:(int)ch {
    outputChan = ch;
    return self;
}

- (int)bank {
    return bank;
}

- (id)bank:(int)b {
    bank = b;
    return self;
}

- (int)pcProg {
    return pcProg;
}

- (id)pcProg:(int)prog {
    pcProg = prog;
    return self;
}

- (int)zoneLow {
    return zoneLow;
}

- (id)zoneLow:(int)low {
    zoneLow = low;
    return self;
}

- (int)zoneHigh {
    return zoneHigh;
}

- (id)zoneHigh:(int)high {
    zoneHigh = high;
    return self;
}

- (BOOL)inZone:(Byte)note {
    return note >= zoneLow && note <= zoneHigh;
}

- (int)xpose {
    return xpose;
}

- (id)xpose:(int)val {
    xpose = val;
    return self;
}

- (NSData *)filteredControllerNumbers {
    return filteredControllerNumbers;
}

- (id)addFilteredControllerNumber:(Byte)cc {
    [filteredControllerNumbers appendBytes:&cc length:1];
    return self;
}

- (NSData *)filteredStatuses {
    return filteredStatuses;
}

- (id)addFilteredStatus:(Byte)b {
    if (is_channel(b))
        b &= 0xF0;
    [filteredStatuses appendBytes:&b length:1];
    return self;
}

- (BOOL)byte:(Byte)b isInData:(NSData *)data {
    NSUInteger len = [data length];
    if (len == 0)
        return NO;

    int i;
    Byte *bytes = (Byte *)[data bytes];
    for (i = 0; i < len; ++i)
        if (b == bytes[i])
            return YES;
    return NO;
}

- (BOOL)acceptInput:(Byte *)data {
    if (inputChan != UNDEFINED && is_channel(data[0]) && channel(data[0]) != inputChan)
        return NO;

    // Check to see if this is a controller message and we're filtering this
    // controller.
    Byte highNibble = data[0] & 0xF0;
    if (highNibble == CONTROLLER && [filteredControllerNumbers length] > 0)
        if ([self byte:data[1] isInData:filteredControllerNumbers])
            return NO;

    // Check to see if this is a status and we're filtering it.
    if (is_status(data[0])) {
        Byte status = data[0];
        if (is_channel(data[0]))
            status &= 0xF0;
        if ([self byte:status isInData:filteredStatuses])
            return NO;
    }

    return YES;
}

- (id)midiIn:(MIDIPacket *)packet {
    size_t bufSize = packet->length + LIST_OVERHEAD;
    MIDIPacketList *packetList = (MIDIPacketList *)malloc(bufSize);
    MIDIPacket *p = MIDIPacketListInit(packetList);

    PacketMessageIterator *pmi = [[PacketMessageIterator alloc] initWithPacket:packet];
    Byte *data;
    for (data = [pmi message]; data != nil; data = [pmi nextMessage]) {
        if (![self acceptInput:data])
            continue;

        NSUInteger numBytes = 0;
        Byte bytes[4];
        
        if (is_note(data[0])) {
            if ([self inZone:data[1]]) {
                bytes[0] = (data[0] & 0xF0) + outputChan;
                bytes[1] = data[1] + xpose;
                bytes[2] = data[2];
                numBytes = 3;
            }
        }
        else if (is_channel(data[0])) {
            bytes[0] = (data[0] & 0xF0) + outputChan;
            bytes[1] = data[1];
            Byte highNibble = data[0] & 0xF0;

            if (highNibble == CONTROLLER || highNibble == PITCH_BEND) {
                bytes[2] = data[2];
                numBytes = 3;
            }
            else
                numBytes = 2;
        }
        else if (is_realtime(data[0])) {
            numBytes = 1;
            bytes[0] = data[0];
        }
        else {
            switch (data[0]) {
            case SYSEX:
                numBytes = [pmi messageLength];
                p = MIDIPacketListAdd(packetList, (size_t)bufSize, p, 0, numBytes, data);
                numBytes = 0;   // do not re-copy below
                break;
            case EOX:           // should not see a naked EOX
                break;
            case SONG_POINTER:
                bytes[0] = data[0];
                bytes[1] = data[1];
                bytes[2] = data[2];
                numBytes = 3;
                break;
            case SONG_SELECT:
                bytes[0] = data[0];
                bytes[1] = data[1];
                numBytes = 2;
                break;
            case TUNE_REQUEST:
                bytes[0] = data[0];
                numBytes = 1;
                break;
            default:
                // FIXME handle partial SYSEX messages
                break;
            }
        }

        // TODO filter

        if (numBytes > 0)
            p = MIDIPacketListAdd(packetList, (size_t)bufSize, p, 0, numBytes, bytes);
    }

    [output sendPacketList:packetList];
    free(packetList);
    return self;
}

@end
