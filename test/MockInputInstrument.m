#import <MockInputInstrument.h>
#import <InputInstrument.h>

@implementation MockInputInstrument

+ (id)withShortName:(NSString *)sn longName:(NSString *)ln {
    return [[MockInputInstrument alloc] initWithShortName:sn longName:ln endpoint:nil];
}

- (id)start {
    return self;
}

- (id)stop {
    return self;
}

@end
