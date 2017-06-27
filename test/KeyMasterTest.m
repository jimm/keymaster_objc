#import <XCTest/XCTest.h>
#import <KeyMaster.h>
#import <Chain.h>
#import <Song.h>
#import <consts.h>
#import <MockOutputInstrument.h>

@interface KeyMasterTest : XCTestCase {
    KeyMaster *km;
}
@end

@implementation KeyMasterTest

- (void)setUp {
    km = [[KeyMaster alloc] init];
}

- (void)tearDown {
    [km stop];
}

- (void)testInit {
    STAssertEquals(1UL, [[km chains] count], @"allSongs not added to chains");
    STAssertEquals([km allSongs], [[km chains] objectAtIndex:0], @"allSongs is not only first/only chain");
    STAssertNotNil([km cursor], @"cursor is nil");
    STAssertEquals(0UL, [[km inputs] count], @"should not have any inputs");
    STAssertEquals(0UL, [[km outputs] count], @"should not have any outputs");
}

- (void)testAddSongKeepsAllSongsSorted {
    [km addSong:[Song withName:@"Zee or Zed"]];
    [km addSong:[Song withName:@"Aardvarks Rule"]];
    NSArray *songs = [[km allSongs] songs];
    STAssertTrue(NSOrderedSame == [@"Aardvarks Rule" compare:[[songs objectAtIndex:0] name]], @"wrong order");
    STAssertTrue(NSOrderedSame == [@"Zee or Zed" compare:[[songs objectAtIndex:1] name]], @"wrong order");
}

- (void)testFindChainWithNameMatching {
    Chain *chain = [Chain withName:@"foo"];
    [km addChain:chain];

    STAssertEquals(chain, [km findChainWithNameMatching:@"FOO"], @"bad match");
    STAssertEquals(chain, [km findChainWithNameMatching:@"oo"], @"bad match");
    STAssertEquals(chain, [km findChainWithNameMatching:@"f.*"], @"bad match");
    STAssertEquals(chain, [km findChainWithNameMatching:@"o$"], @"bad match");
    STAssertEquals([km allSongs], [km findChainWithNameMatching:@"all"], @"bad match");
}

- (void)testPanic {
    MockOutputInstrument *output = [MockOutputInstrument withShortName:@"mockout" longName:@"Mock Output Instrument"];
    [km addOutput:output];

    [km executeKeyPress:[km testingKey]];
    [km executeKeyPress:27];
    STAssertEquals((NSUInteger)(MIDI_CHANNELS * 3), [[output buffer] length], @"wrong num panic bytes sent");
}

- (void)testPanicSecondTime {
    MockOutputInstrument *output = [MockOutputInstrument withShortName:@"mockout" longName:@"Mock Output Instrument"];
    [km addOutput:output];

    [km executeKeyPress:[km testingKey]];
    [km executeKeyPress:27];
    [output reset];
    [km executeKeyPress:27];
    NSUInteger expectedLength = MIDI_CHANNELS * 3 + MIDI_CHANNELS * 128 * 3;
    STAssertEquals(expectedLength, [[output buffer] length], @"wrong num panic bytes sent");
}

@end
