#import <SenTestingKit/SenTestingKit.h>
#import <consts.h>

@interface ConstsTest : SenTestCase
@end

@implementation ConstsTest

- (void)testStatusNames {
    STAssertEquals(0x80, statusFromName("NOTE_OFF"), @"wrong value");
    STAssertEquals(0xff, statusFromName("SYSTEM_RESET"), @"wrong value");
    STAssertEquals(0xff, statusFromName("system_reset"), @"wrong value");
    STAssertEquals(-1, statusFromName("foo"), @"wrong value");
}

- (void)testControllerNames {
    STAssertEquals(0, ccFromName("CC_BANK_SELECT"), @"wrong value");
    STAssertEquals(0x7b, ccFromName("CM_ALL_NOTES_OFF"), @"wrong value");
    STAssertEquals(0x7b, ccFromName("cm_all_notes_off"), @"wrong value");
    STAssertEquals(-1, ccFromName("foo"), @"wrong value");
}

@end
