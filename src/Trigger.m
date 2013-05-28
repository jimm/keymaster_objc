#import <Foundation/NSData.h>
#import <Foundation/NSString.h>
#import <Trigger.h>
#import <PacketMessageIterator.h>
#import <KeyMaster.h>

@implementation Trigger

+ withData:(NSData *)data performKey:(int)actionKey {
    return [[Trigger alloc] initWithData:data performKey:actionKey];
}

- initWithData:(NSData *)d performKey:(int)key {
    self = [super init];
    data = d;
    actionKey = key;
    return self;
}

- (id)signal:(MIDIPacket *)packet {
    PacketMessageIterator *pmi = [[PacketMessageIterator alloc] initWithPacket:packet];
    Byte *bytes;
    for (bytes = [pmi message]; bytes != nil; bytes = [pmi nextMessage]) {
        if (strncmp((char *)[data bytes], (char *)bytes, [data length]) == 0) {
            [[KeyMaster instance] queueKeyPress:actionKey];
            break;
        }
    }
    return self;
}

- (int)actionKey {
    return actionKey;
}

- (NSString *)dataDescription {
    if ([data length] == 0)
        return @"";

    Byte *buf = malloc([data length] * 3), *p;
    const unsigned char *bytes = [data bytes];

    int i;
    for (i = 0, p = buf; i < [data length]; ++i, p+= 3)
        sprintf(p, " %02x", (unsigned char)bytes[i]);

    // The +1 removes the initial space
    NSString *str = [NSString stringWithCString:buf+1 encoding:NSASCIIStringEncoding];
    free(buf);
    return str;
}

@end
