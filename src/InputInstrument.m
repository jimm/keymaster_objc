#import <InputInstrument.h>
#import <Trigger.h>
#import <Connection.h>

@implementation InputInstrument

+ (id)withShortName:(NSString *)sn longName:(NSString *)ln endpoint:(PYMIDIEndpoint *)e {
    return [[InputInstrument alloc] initWithShortName:sn longName:ln endpoint:e];
}

- (id)initWithShortName:(NSString *)sn longName:(NSString *)ln endpoint:(PYMIDIEndpoint *)e {
    self = [super initWithShortName:sn longName:ln endpoint:e];
    connections = [[NSMutableArray alloc] init];
    triggers = [[NSMutableArray alloc] init];
    return self;
}

- (NSArray *)connections {
    return connections;
}

- (id)addConnection:(Connection *)c {
    [connections addObject:c];
    return self;
}

- (id)removeConnection:(Connection *)c {
    [connections removeObject:c];
    return self;
}

- (NSArray *)triggers {
    return triggers;
}

- (id)addTrigger:(Trigger *)t {
    [triggers addObject:t];
    return self;
}

- (id)start {
    NSLog(@"instrument %@ starting", longName);
    [endpoint addReceiver:self];
    return self;
}

- (id)stop {
    NSLog(@"instrument %@ stopping", longName);
    [endpoint removeReceiver:self];
    return self;
}

- (void)processMIDIPacketList:(MIDIPacketList*)packetList sender:(id)sender {
    int i;
    MIDIPacket *packet = &packetList->packet[0];
    for (i = 0; i < packetList->numPackets; ++i) {
        for (id t in triggers)
            [t signal:packet];
        for (id conn in connections)
            [conn midiIn:packet];
        packet = MIDIPacketNext(packet);
    }
}

@end
