#import <Foundation/NSString.h>
#import <Foundation/NSRegularExpression.h>
#import <Chain.h>
#import <Song.h>

@implementation Chain

+ (id)withName:(NSString *)name {
    return [[Chain alloc] initWithName:name];
}

- (id)initWithName:(NSString *)str {
    self = [super init];
    name = str;
    songs = [[NSMutableArray alloc] init];
    return self;
}

- (NSString *)name {
    return name;
}

- (NSArray *)songs {
    return songs;
}

- (NSUInteger)count {
    return [songs count];
}

- (id)addSong:(Song *)song {
    [songs addObject:song];
    return self;
}

- (Song *)findSongWithName:(NSString *)str {
    for (id s in songs) {
        if ([[s name] caseInsensitiveCompare:str] == NSOrderedSame)
            return s;
    }
    return nil;
}

- (Song *)findSongWithNameMatching:(NSString *)regexString {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error != nil) {
        NSLog(@"%@", error);
        return nil;
    }

    for (id s in songs) {
        NSTextCheckingResult *match = [regex firstMatchInString:[s name]
                                                        options:0
                                                          range:NSMakeRange(0, [[s name] length])];
        if (match != nil)
            return s;
    }
    return nil;
}

- (id)sortBySongName {
    [songs sortUsingSelector:@selector(compareToSong:)];
    return self;
}

@end
