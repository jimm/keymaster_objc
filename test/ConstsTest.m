#import <XCTest/XCTest.h>
#import <consts.h>

@interface ConstsTest : XCTestCase
@end

@implementation ConstsTest

- (void)testStatusNames {
    STAssertEquals(0x80, statusFromName("NOTE_OFF"), @"wrong value");
    STAssertEquals(0x90, statusFromName("note_on"), @"wrong value");
    STAssertEquals(0xff, statusFromName("SYSTEM_RESET"), @"wrong value");
    STAssertEquals(0xff, statusFromName("system_reset"), @"wrong value");
    STAssertEquals(UNDEFINED, statusFromName("foo"), @"wrong value");
}

- (void)testStatusChannels {
    STAssertEquals(0x90, statusFromName("NOTE_ON:1"), @"wrong channel");
    STAssertEquals(0x9f, statusFromName("note_on:16"), @"wrong channel");
    STAssertEquals(0xa9, statusFromName("poly_pressure:10"), @"wrong channel");
}

- (void)testStatusBadChannelsIgnored {
    STAssertEquals(0x90, statusFromName("NOTE_ON:99"), @"wrong channel");
    STAssertEquals(0x90, statusFromName("NOTE_ON:0"), @"wrong channel");
    STAssertEquals(0x90, statusFromName("note_on:xyzzy"), @"wrong channel");
}

- (void)testControllerNames {
    STAssertEquals(0, ccFromName("CC_BANK_SELECT"), @"wrong value");
    STAssertEquals(0x7b, ccFromName("CM_ALL_NOTES_OFF"), @"wrong value");
    STAssertEquals(0x7b, ccFromName("cm_all_notes_off"), @"wrong value");
    STAssertEquals(UNDEFINED, ccFromName("foo"), @"wrong value");
}

- (void)testControllerNamesIgnoreChannels {
    STAssertEquals(0, ccFromName("CC_BANK_SELECT:1"), @"wrong value");
    STAssertEquals(0x7b, ccFromName("CM_ALL_NOTES_OFF:2"), @"wrong value");
}

@end
