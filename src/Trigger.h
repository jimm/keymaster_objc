/* -*- objc -*- */

#import <Foundation/NSObject.h>
#import <CoreMIDI/CoreMIDI.h>

@class NSData, NSString;

@interface Trigger : NSObject {
    NSData* data;
    int actionKey;
}

+ withData:(NSData *)data performKey:(int)actionKey;

- initWithData:(NSData *)data performKey:(int)actionKey;

- (id)signal:(MIDIPacket *)packet;
- (int)actionKey;
- (NSString *)dataDescription;

@end
