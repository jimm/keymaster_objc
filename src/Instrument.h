/* -*- objc -*- */

#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#include <PYMIDI/PYMIDI.h>

struct Connection;

@interface Instrument : NSObject {
    NSString *shortName;
    NSString *longName;
    PYMIDIEndpoint *endpoint;
}

+ (id)withShortName:(NSString *)sn
           longName:(NSString *)ln
           endpoint:(PYMIDIEndpoint *)endpoint;

- (id)initWithShortName:(NSString *)sn
               longName:(NSString *)ln
               endpoint:(PYMIDIEndpoint *)endpoint;

- (NSString *)shortName;
- (NSString *)longName;

@end
