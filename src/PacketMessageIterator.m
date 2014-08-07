#import <PacketMessageIterator.h>
#import <consts.h>

@interface PacketMessageIterator (private)
- (void)calculateNextMessageLength;
@end

@implementation PacketMessageIterator

- (id)initWithPacket:(MIDIPacket *)p {
    self = [self init];
    packet = p;
    [self calculateNextMessageLength];
    i = 0;
    return self;
}

- (Byte *)message {
    if (i >= packet->length)
        return nil;
    return &packet->data[i];
}

- (NSUInteger)messageLength {
    return messageLength;
}

- (Byte *)nextMessage {
    i += messageLength;
    [self calculateNextMessageLength];
    return [self message];
}

- (void)calculateNextMessageLength {
    if (i >= packet->length) {
        messageLength = 0;
        return;
    }

    Byte status = packet->data[i];
    if (is_channel(status)) {
        switch (packet->data[i] & 0xF0) {
        case NOTE_OFF:
        case NOTE_ON:
        case POLY_PRESSURE:
        case CONTROLLER:
        case PITCH_BEND:
            messageLength = 3;
            break;
        default:
            messageLength = 2;
            break;
        }
    }
    else if (is_realtime(status))
        messageLength = 1;
    else {
        switch (status) {
        case SONG_POINTER:
            messageLength = 3;
            break;
        case SONG_SELECT:
            messageLength = 2;
            break;
        case TUNE_REQUEST:
            messageLength = 1;
            break;
        case SYSEX:         // look for EOX or any other status byte
        default:            // even if data byte, look for EOX/status byte
            for (messageLength = 1; (i + messageLength) < packet->length && packet->data[i + messageLength] < 0x80; ++messageLength)
                ;
            if (i + messageLength < packet->length)
                ++messageLength;
            break;
        }
    }
}

@end
