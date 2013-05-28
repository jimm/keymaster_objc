/* -*- objc -*- */

#import <Foundation/NSArray.h>

@class Song, Connection;

@interface Patch : NSObject {
    NSString *name;
    Song *song;
    NSMutableArray *connections;
    NSData *enterData;
    NSData *exitData;
    BOOL running;
}

+ (id)withName:(NSString *)name inSong:(Song *)s;

- (id)init;
- (id)initWithName:(NSString *)name andSong:(Song *)s;

- (id)start;
- (id)stop;

- (NSString *)name;
- (Song *)song;
- (NSArray *)connections;
- (NSData *)enterData;
- (id)enterData:(NSData *)data;
- (NSData *)exitData;
- (id)exitData:(NSData *)data;

- (id)addConnection:(Connection *)connection;

@end
