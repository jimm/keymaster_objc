/* -*- objc -*- */

#import <InputInstrument.h>

@class Connection, Trigger;

@interface MockInputInstrument : InputInstrument

+ (id)withShortName:(NSString *)sn
           longName:(NSString *)ln;

- (id)start;
- (id)stop;

@end
