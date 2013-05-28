#import <Foundation/NSString.h>
#import <Song.h>
#import <Patch.h>

@implementation Song

+ (id)withName:(NSString *)newName {
    return [[Song alloc] initWithName:newName];
}

- (id)init {
    self = [super init];
    name = nil;
    notes = nil;
    patches = [[NSMutableArray alloc] init];
    return self;
}

- (id)initWithName:(NSString *)newName {
    self = [self init];
    name = newName;
    return self;
}

- (NSString *)name {
    return name;
}

- (NSString *)notes {
    return notes;
}

- (id)notes:(NSString *)str {
    notes = str;
    return self;
}

- (NSArray *)patches {
    return patches;
}

- (id)addPatch:patch {
    [patches addObject:patch];
}

- (NSComparisonResult)compareToSong:(Song *)song {
    return [name caseInsensitiveCompare:[song name]];
}

@end
