#import <XCTest/XCTest.h>
#import <Chain.h>
#import <Song.h>
#import <consts.h>

@interface ChainTest : XCTestCase {
    Chain *chain;
    Song *s1;
    Song *s2;
}
@end

@implementation ChainTest

- (void)setUp {
    s1 = [Song withName:@"When I Dine Tonight"];
    s2 = [Song withName:@"Better Get a Bucket"];
    chain = [Chain withName:@"Test Chain"];
    [chain addSong:s1];
    [chain addSong:s2];
}

- (void)testCount {
    STAssertEquals(2UL, [chain count], @"song count wrong");
}

- (void)testAddSong {
    Song *s3 = [Song withName:@"Crunchy Frog"];
    [chain addSong:s3];
    STAssertEquals(3UL, [chain count], @"song not added");
    STAssertEqualObjects(s3, [[chain songs] objectAtIndex:2], @"song not added at end");
}

- (void)testSort {
    Song *s3 = [Song withName:@"Crunchy Frog"];
    [chain addSong:s3];
    [chain sortBySongName];
    STAssertEqualObjects(s2, [[chain songs] objectAtIndex:0], @"bad sort");
    STAssertEqualObjects(s3, [[chain songs] objectAtIndex:1], @"bad sort");
    STAssertEqualObjects(s1, [[chain songs] objectAtIndex:2], @"bad sort");
}

- (void)testFindWithName {
    Song *found = [chain findSongWithName:@"Better Get a Bucket"];
    STAssertNotNil(found, @"did not find song");
    STAssertEqualObjects(s2, found, @"wrong song found: found %@", [found name]);

    found = [chain findSongWithName:@"better get a BUCKET"];
    STAssertNotNil(found, @"did not find song");
    STAssertEqualObjects(s2, found, @"wrong song found: found %@", [found name]);
}

- (void)testFindWithNameMatching {
    Song *found = [chain findSongWithNameMatching:@"get.*ck"];
    STAssertNotNil(found, @"did not find song using regex");
    STAssertEqualObjects(s2, found, @"wrong song found: found %@", [found name]);
}

@end
