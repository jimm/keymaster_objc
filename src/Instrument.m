#import <Instrument.h>

@implementation Instrument

+ (id)withShortName:(NSString *)sn longName:(NSString *)ln endpoint:(PYMIDIEndpoint *)e {
    return [[Instrument alloc] initWithShortName:sn longName: ln endpoint:e];
}

- (id)initWithShortName:(NSString *)sn longName:(NSString *)ln endpoint:(PYMIDIEndpoint *)e {
    self = [super init];
    shortName = sn;
    longName = ln;
    endpoint = e;
    return self;
}

- (NSString *)shortName {
    return shortName;
}

- (NSString *)longName {
    return longName;
}

@end
