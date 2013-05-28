#import <SenTestingKit/SenTestingKit.h>
#import <KeyMaster.h>
#import <MockInputInstrument.h>
#import <MockOutputInstrument.h>
#import <Connection.h>
#import <consts.h>

#define BIG_MESSAGE_SIZE 3333

@interface ConnectionTest : SenTestCase {
    MockInputInstrument *input;
    MockOutputInstrument *output;
    Connection *conn;
}
@end

@implementation ConnectionTest

- (void)setUp {
    input = [MockInputInstrument withShortName:@"mockin" longName:@"Mock Input Instrument"];
    output = [MockOutputInstrument withShortName:@"mockout" longName:@"Mock Output Instrument"];

    conn = [[Connection alloc] init];
    [conn input:input];
    [conn output:output];
    [conn outputChan:2];
    [conn pcProg: 3];
    [[conn zoneLow:40] zoneHigh: 60];
    [conn xpose: 12];

    [[KeyMaster instance] start];
}

- (void)tearDown {
    [conn stop:nil];
    [[KeyMaster instance] stop];
}

- (void)testAccessors {
    STAssertEquals(input, [conn input], @"conn input not set correctly");
    STAssertTrue([conn inputChan] == -1, @"conn input chan not set correctly");
    STAssertEquals(output, [conn output], @"conn output not set correctly");
    STAssertTrue([conn outputChan] == 2, @"conn output chan not set correctly");
    STAssertTrue([conn pcProg] == 3, @"pcProg is wrong");
    STAssertTrue([conn zoneLow] == 40, @"zoneLow is wrong");
    STAssertTrue([conn zoneHigh] == 60, @"zoneHigh is wrong");
    STAssertTrue([conn xpose] == 12, @"xpose is wrong");
}

- (void)testStartAttachesSelfToInput {
    STAssertEquals(0UL, [[input connections] count], @"input should have no connections yet");
    [conn start:nil];
    STAssertTrue([[input connections] count] == 1, @"input should have one connection after conn starts");
    STAssertEqualObjects(conn, [[input connections] objectAtIndex:0], @"input connection is the wrong one");
}

- (void)testStopDetachesSelfFromInput {
    [conn start:nil];
    [conn stop:nil];
    STAssertTrue([[input connections] count] == 0, @"connection was not removed from input connections list");
}

- (void)testStartSendsStartBytes {
    int i;
    Byte bytes[3];

    STAssertEquals(0UL, [[output buffer] length], @"output buffer should start empty");
    for (i = 0; i < 3; ++i)
        bytes[i] = i + 1;
    NSData *startMessage = [NSData dataWithBytes:bytes length:3];
    [conn start:startMessage];
    STAssertTrue([[output buffer] length] >= 3UL, @"output buffer should include 3 start bytes");
    for (i = 0; i < 3; ++i)
        STAssertEquals((Byte)(i+1), ((Byte *)[[output buffer] bytes])[i], @"bad data in output buffer");
}

- (void)testStopSendsStopBytes {
    int i;
    Byte bytes[3];

    STAssertEquals(0UL, [[output buffer] length], @"output buffer should start empty");
    for (i = 0; i < 3; ++i)
        bytes[i] = i + 4;
    NSData *stopMessage = [NSData dataWithBytes:bytes length:3];
    [conn start:nil];
    [conn stop:stopMessage];
    STAssertTrue([[output buffer] length] >= 3UL, @"output buffer should include 3 start bytes");
    int end = [[output buffer] length];
    for (i = 0; i < 3; ++i)
        STAssertEquals((Byte)(i+4), ((Byte *)[[output buffer] bytes])[end - (3 - i)], @"bad data in output buffer");
}

- (void)testInsideZone {
    NSString *msg = @"zone test failed";
    STAssertFalse([conn inZone:39], msg);
    STAssertTrue([conn inZone:40], msg);
    STAssertTrue([conn inZone:60], msg);
    STAssertFalse([conn inZone:61], msg);
}

- (void)sendNoteChan:(Byte)ch note:(Byte)n vel:(Byte)v {
    MIDIPacket packet;
    packet.timeStamp = 0;
    packet.length = 3;
    packet.data[0] = NOTE_ON + ch;
    packet.data[1] = n;
    packet.data[2] = v;
    [conn midiIn:&packet];
}

- (void)assertBytes:(Byte)b1 and:(Byte)b2 and:(Byte)b3 msg:(NSString *)prefix {
    STAssertEquals(3UL, [[output buffer] length], @"expected 3 bytes");
    Byte *bytes = (Byte *)[[output buffer] bytes];
    // We cast to int so that error messages show numeric values, not characters
    STAssertEquals((int)b1, (int)bytes[0], [NSString stringWithFormat: @"%@: bad data byte 0", prefix]);
    STAssertEquals((int)b2, (int)bytes[1], [NSString stringWithFormat: @"%@: bad data byte 1", prefix]);
    STAssertEquals((int)b3, (int)bytes[2], [NSString stringWithFormat: @"%@: bad data byte 2", prefix]);
}

- (void)testOutOfZoneNoBytesSent {
    NSUInteger beforeLen = [[output buffer] length];
    [self sendNoteChan:0 note:3 vel:127];
    STAssertEquals(beforeLen, [[output buffer] length], @"output buffer should be empty because note is out of range");
}

- (void)testOutputSentToOutputChannel {
    [conn xpose:0];
    [self sendNoteChan:1 note:40 vel:127];
    [self assertBytes:NOTE_ON + 2 and:40 and:127 msg:@"sent chan 1"];

    [output reset];
    [self sendNoteChan:0 note:40 vel:127];
    [self assertBytes:NOTE_ON + 2 and:40 and:127 msg:@"sent chan 0"];

    [output reset];
    [self sendNoteChan:15 note:40 vel:127];
    [self assertBytes:NOTE_ON + 2 and:40 and:127 msg:@"sent chan 15"];
}

- (void)testTranspose {
    STAssertEquals(12, [conn xpose], @"bad xpose value");
    [self sendNoteChan:1 note:40 vel:127];
    [self assertBytes:NOTE_ON + 2 and:52 and:127 msg:@"xpose didn't work"];
}

- (void)testProgSent {
    STAssertEquals(3, [conn pcProg], @"bad prog chg value");
    [conn start:nil];
    Byte *buf = (Byte *)[[output buffer] bytes];
    STAssertEquals((Byte)(PROGRAM_CHANGE + [conn outputChan]), buf[0], @"bad pc status byte");
    STAssertEquals((Byte)3, buf[1], @"bad pc value");
}

- (void)testBankSent {
    [conn bank:2];
    [conn start:nil];
    Byte *buf = (Byte *)[[output buffer] bytes];
    STAssertEquals((Byte)(CONTROLLER + [conn outputChan]), buf[0], @"bad controller status byte");
    STAssertEquals((Byte)(CC_BANK_SELECT + 32), buf[1], @"bad bank controller number");
    STAssertEquals((Byte)2, buf[2], @"bad bank number");
    STAssertEquals((Byte)(PROGRAM_CHANGE + [conn outputChan]), buf[3], @"bad pc status byte");
    STAssertEquals((Byte)3, buf[4], @"bad pc value");
}

- (void)testNonChannelMessages {
    Byte buf[5];
    buf[0] = SONG_POINTER;
    buf[1] = 42;
    buf[2] = 3;
    buf[3] = TUNE_REQUEST;
    buf[4] = CLOCK;

    MIDIPacket packet;
    packet.timeStamp = 0;
    packet.length = 5;
    memcpy(packet.data, buf, 5);
    [conn midiIn:&packet];

    STAssertEquals(5UL, [[output buffer] length], @"wrong num bytes sent");

    int i;
    Byte *data = (Byte *)[[output buffer] bytes];
    for (i = 0; i < 5; ++i)
        STAssertEquals(buf[i], data[i], @"non-channel message data is wrong");
}

- (void)testLargeSysex {
    int i;
    Byte buf[BIG_MESSAGE_SIZE];

    buf[0] = SYSEX;
    for (i = 1; i < BIG_MESSAGE_SIZE - 1; ++i)
        buf[i] = 3;
    buf[BIG_MESSAGE_SIZE - 1] = EOX;

    MIDIPacket *packet = (MIDIPacket *)malloc(sizeof(MIDITimeStamp) + sizeof(UInt16) + BIG_MESSAGE_SIZE);
    packet->timeStamp = 0;
    packet->length = BIG_MESSAGE_SIZE;
    memcpy(packet->data, buf, BIG_MESSAGE_SIZE);

    [conn midiIn:packet];
    STAssertEquals((NSUInteger)BIG_MESSAGE_SIZE, [[output buffer] length], @"wrong num bytes sent");

    Byte *data = (Byte *)[[output buffer] bytes];
    for (i = 0; i < BIG_MESSAGE_SIZE; ++i) {
        STAssertEquals(buf[i], data[i], @"data mismatch");
        // Break after the first failure. No sense having thousands of error messages
        if (buf[i] != data[i])
            break;
    }

    free(packet);
}

@end
