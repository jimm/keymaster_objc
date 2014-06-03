#import <Foundation/NSData.h>
#import <Patch.h>
#import <Song.h>
#import <Connection.h>

@interface Patch (private)
- (BOOL)isRunning;
@end

@implementation Patch

+ (id)withName:(NSString *)newName inSong:(Song *)s {
    return [[Patch alloc] initWithName:newName andSong:s];
}

- (id)init {
    self = [super init];
    name = nil;
    connections = [[NSMutableArray alloc] init];
    enterData = nil;
    exitData = nil;
    running = NO;
    return self;
}

- (id)initWithName:(NSString *)newName andSong:(Song *)s {
    self = [self init];
    name = newName;
    song = s;
    return self;
}

- (id)start {
    for (id conn in connections)
        [conn start:enterData];
    running = YES;
    return self;
}

- (BOOL)isRunning {
    return running;
}

- (id)stop {
    if (running) {
        running = NO;
        for (id conn in connections)
            [conn stop:exitData];
    }
    return self;
}

- (NSString *)name {
    return name;
}

- (Song *)song {
    return song;
}

- (NSArray *)connections {
    return connections;
}

- (NSData *)enterData {
    return enterData;
}

- (id)enterData:(NSData *)data {
    enterData = data;
    return self;
}

- (NSData *)exitData {
    return exitData;
}

- (id)exitData:(NSData *)data {
    exitData = data;
    return self;
}

- (id)addConnection:(Connection *)connection {
    [connections addObject:connection];
    return self;
}

@end
