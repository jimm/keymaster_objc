#import <SenTestingKit/SenTestingKit.h>
#import <Reader.h>
#import <KeyMaster.h>
#import <Trigger.h>
#import <MockInputInstrument.h>

@interface ReaderTest : SenTestCase {
    Reader *reader;
}
@end

@interface Reader (testing2)
- (void)trigger:(NSString *)line;
@end

@implementation ReaderTest

- (void)setUp {
    reader = [[Reader alloc] init];
}

- (void)testNoteFromStr {
    NSString *msg = @"bad note parsing";
    STAssertEquals(48, (int)[reader noteFromStr:@"C4"], msg);
    STAssertEquals(49, (int)[reader noteFromStr:@"c#4"], msg);
    STAssertEquals(49, (int)[reader noteFromStr:@"cs4"], msg);
    STAssertEquals(47, (int)[reader noteFromStr:@"Cb4"], msg);
    STAssertEquals(47, (int)[reader noteFromStr:@"Cf4"], msg);
    STAssertEquals(0, (int)[reader noteFromStr:@"c0"], msg);
}

- (void)testByteValue {
    NSString *msg = @"bad byte value";
    STAssertEquals(48, (int)[reader byteValue:@"C4"], msg);

    STAssertEquals(48, (int)[reader byteValue:@"48"], msg);

    STAssertEquals(32, (int)[reader byteValue:@"0x20"], msg);
    STAssertEquals(176, (int)[reader byteValue:@"0xb0"], msg);
    STAssertEquals(255, (int)[reader byteValue:@"0xff"], msg);

    STAssertEquals(0x80, (int)[reader byteValue:@"NOTE_OFF"], msg);
    STAssertEquals(0xff, (int)[reader byteValue:@"SYSTEM_RESET"], msg);
    STAssertEquals(0,    (int)[reader byteValue:@"CC_BANK_SELECT"], msg);
    STAssertEquals(0x7b, (int)[reader byteValue:@"CM_ALL_NOTES_OFF"], msg);
}

- (void)testTrigger {
    KeyMaster *km = [[KeyMaster alloc] init];
    MockInputInstrument *inst = [MockInputInstrument withShortName:@"foo" longName:@"foo bar"];
    [km addInput:inst];

    [reader km:km];
    [reader trigger:@"trigger foo n 0xb0 50 0xff"];
    STAssertEquals(1UL, [[inst triggers] count], @"trigger not created");

    Trigger *trigger = [[inst triggers] objectAtIndex:0];
    STAssertEquals((int)'n', [trigger actionKey], @"bad trigger key");
    STAssertEqualObjects(@"b0 32 ff", [trigger dataDescription], @"bad trigger bytes");
}

- (void)testNoteIndentationPreservation {
    [reader notesLine:@" \t line one"];
    [reader notesLine:@" \t   line two"];
    [reader notesLine:@" \t line three"];
    STAssertEqualObjects(@"line one\n  line two\nline three", [reader notes], @"song note indentation preservation failure indication");
}

@end
