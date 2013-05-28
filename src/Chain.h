/* -*- objc -*- */

#import <Foundation/NSArray.h>

@class Song;

@interface Chain : NSObject {
    NSString *name;
    NSMutableArray *songs;
}

+ (id)withName:(NSString *)name;

- (id)initWithName:(NSString *)name;

- (NSString *)name;
- (NSArray *)songs;
- (NSUInteger)count;

- (id)addSong:(Song *)song;

/**
 * Find first song with same name, using case-independent comparison.
 */
- (Song *)findSongWithName:(NSString *)name;

/**
 * Finds first song that matches regex, ignoring case. If no match is found,
 * returns nil.
 */
- (Song *)findSongWithNameMatching:(NSString *)regex;

- (id)sortBySongName;

@end
