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
    STAssertEquals(48, (int)[reader noteFromString:@"C4"], msg);
    STAssertEquals(49, (int)[reader noteFromString:@"c#4"], msg);
    STAssertEquals(49, (int)[reader noteFromString:@"cs4"], msg);
    STAssertEquals(47, (int)[reader noteFromString:@"Cb4"], msg);
    STAssertEquals(47, (int)[reader noteFromString:@"Cf4"], msg);
    STAssertEquals(0, (int)[reader noteFromString:@"c0"], msg);
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
    [reader trigger:@"trigger n foo 0xb0 50 0xff"];
    STAssertEquals(1UL, [[inst triggers] count], @"trigger not created");

    Trigger *trigger = [[inst triggers] objectAtIndex:0];
    STAssertEquals((int)'n', [trigger actionKey], @"bad trigger key");
    STAssertEqualObjects(@"b0 32 ff", [trigger dataDescription], @"bad trigger bytes");
}

- (void)testKeyFromStr {
    NSString *msg = @"bad note parsing";
    STAssertEquals('n', [reader keyFromString:@"n"], msg);
    STAssertEquals('3', [reader keyFromString:@"3"], msg);
    STAssertEquals(27, [reader keyFromString:@"ESC"], msg);
    STAssertEquals(27, [reader keyFromString:@"esc"], msg);
    STAssertEquals(KEY_F(1), [reader keyFromString:@"F1"], msg);
    STAssertEquals(KEY_UP, [reader keyFromString:@"up"], msg);
}

- (void)testNoteIndentationPreservation {
    [reader notesLine:@" \t line one"];
    [reader notesLine:@" \t   line two"];
    [reader notesLine:@" \t line three"];
    STAssertEqualObjects(@"line one\n  line two\nline three", [reader notes], @"song note indentation preservation failure indication");
}

- (void)testReadBytes {
    NSData *data = [reader readBytesFromString:@"1 2 NOTE_OFF:3" skippingWords:0];
    Byte *bytes = (Byte *)[data bytes];
    STAssertEquals(3UL, [data length], @"bad length");
    STAssertEquals((Byte)1, bytes[0], @"bad byte");
    STAssertEquals((Byte)2, bytes[1], @"bad byte");
    STAssertEquals((Byte)0x82, bytes[2], @"bad byte");
}

- (void)testReadBytesSkippingWords {
    NSData *data = [reader readBytesFromString:@"hello world 1 2 NOTE_OFF:3" skippingWords:2];
    Byte *bytes = (Byte *)[data bytes];
    STAssertEquals(3UL, [data length], @"bad length");
    STAssertEquals((Byte)1, bytes[0], @"bad byte");
    STAssertEquals((Byte)2, bytes[1], @"bad byte");
    STAssertEquals((Byte)0x82, bytes[2], @"bad byte");
}

@end
