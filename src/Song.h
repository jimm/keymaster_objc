/* -*- objc -*- */

#import <Foundation/NSArray.h>

@class Patch;

@interface Song : NSObject {
    NSString *name;
    NSString *notes;
    NSMutableArray *patches;
}

+ (id)withName:(NSString *)name;

- (id)init;
- (id)initWithName:(NSString *)name;

- (NSString *)name;
- (NSString *)notes;
- (id)notes:(NSString *)notes;
- (NSArray *)patches;

- (id)addPatch:(Patch *)patch;

/**
 * For sorting within a chain.
 */
- (NSComparisonResult)compareToSong:(Song *)song;

@end
