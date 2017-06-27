#import <XCTest/XCTest.h>
#import <KeyMaster.h>
#import <MockInputInstrument.h>
#import <MockOutputInstrument.h>
#import <Patch.h>
#import <Connection.h>
#import <consts.h>

@interface PatchTest : XCTestCase {
    MockInputInstrument *input;
    MockOutputInstrument *output;
    Patch *patch;
    Connection *conn;
}
@end

@interface PatchTest (private)
- (void)sendNoteChan:(Byte)ch note:(Byte)n vel:(Byte)v;
- (void)assertBytes:(Byte)b1 and:(Byte)b2 and:(Byte)b3 msg:(NSString *)prefix;
@end


@implementation PatchTest

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

    patch = [Patch withName:@"Untitled" inSong:nil];
    [patch addConnection:conn];

    [[KeyMaster instance] start];
}

- (void)tearDown {
    [patch stop];
    [[KeyMaster instance] stop];
}

- (void)testStartStartsConnection {
    [patch start];
    STAssertEqualObjects(conn, [[input connections] objectAtIndex:0], @"conn not set in input");
    [patch stop];
}

- (void)testStartSendsStartBytes {
    Byte bytes[3];
    int i;

    for (i = 0; i < 3; ++i)
        bytes[i] = i + 1;
    NSData *data = [NSData dataWithBytes:bytes length:3];
    [patch enterData:data];

    [patch start];

    Byte *buf = (Byte *)[[output buffer] bytes];
    NSString *msg = @"bad data";
    for (i = 0; i < 3; ++i)
        STAssertEquals((Byte)(i+1), buf[i], msg);
}

- (void)testStopSendsStopBytes {
    Byte bytes[3];
    int i;

    for (i = 0; i < 3; ++i)
        bytes[i] = i + 1;
    NSData *data = [NSData dataWithBytes:bytes length:3];
    [patch exitData:data];

    [patch start];
    [patch stop];

    Byte *buf = (Byte *)[[output buffer] bytes];
    int len = [[output buffer] length];
    NSString *msg = @"bad data";
    for (i = 0; i < 3; ++i)
        STAssertEquals((Byte)(i+1), buf[len - (3 - i)], msg);
}

- (void)testAllProgChangesSent {
    Connection *conn2 = [[Connection alloc] init];
    [conn2 input:input];
    [conn2 output:output];
    [conn2 outputChan:3];
    [conn2 pcProg:42];
    [patch addConnection:conn2];

    Byte expected[4];
    expected[0] = PROGRAM_CHANGE + 2;
    expected[1] = 3;
    expected[2] = PROGRAM_CHANGE + 3;
    expected[3] = 42;

    [patch start];
    STAssertTrue(memcmp(expected, [[output buffer] bytes], 4) == 0, @"bad data");
}

- (void)sendNoteChan:(Byte)ch note:(Byte)n vel:(Byte)v {
    MIDIPacketList packetList;
    packetList.numPackets = 1;

    MIDIPacket *packet = &packetList.packet[0];
    packet->timeStamp = 0;
    packet->length = 3;
    packet->data[0] = NOTE_ON + ch;
    packet->data[1] = n;
    packet->data[2] = v;

    // Pretend the input received this packetList via PYMIDI and tell it to
    // process the packet list.
    [input processMIDIPacketList:&packetList sender:nil];
}

- (void)assertBytes:(Byte)b1 and:(Byte)b2 and:(Byte)b3 msg:(NSString *)prefix {
    STAssertEquals(3UL, [[output buffer] length], [NSString stringWithFormat: @"%@: expected 3 bytes", prefix]);
    Byte *bytes = (Byte *)[[output buffer] bytes];
    // We cast to int so that error messages show numeric values, not characters
    STAssertEquals((int)b1, (int)bytes[0], [NSString stringWithFormat: @"%@: bad data byte 0", prefix]);
    STAssertEquals((int)b2, (int)bytes[1], [NSString stringWithFormat: @"%@: bad data byte 1", prefix]);
    STAssertEquals((int)b3, (int)bytes[2], [NSString stringWithFormat: @"%@: bad data byte 2", prefix]);
}

// Tests two connections with non-overlapping zones that go to different
// channels on the same instrument.
- (void)testZones {
    [conn pcProg:UNDEFINED];
    [[conn zoneLow:0] zoneHigh: 68];

    Connection *conn2 = [[Connection alloc] init];
    [conn2 input:input];
    [conn2 output:output];
    [conn2 outputChan:3];
    [conn2 pcProg: 3];
    [[conn2 zoneLow:69] zoneHigh: 127];
    [patch addConnection:conn2];

    [patch start];

    // Starting the patch hooks up the inputs' connections
    STAssertEquals(2UL, [[input connections] count], @"input should have 2 connections");
    STAssertEqualObjects(conn,  [[input connections] objectAtIndex:0], @"first connection should be conn");
    STAssertEqualObjects(conn2, [[input connections] objectAtIndex:1], @"second connection should be conn2");

    Byte expected[3];
    NSString *msg = @"bad split/xpose";

    // Send note in conn zone
    [output reset];
    [self sendNoteChan:9 note:42 vel:127];
    [self assertBytes:NOTE_ON + 2 and:54 and:127 msg:@"test z1"]; // transposed, channel 2

    // Send note in conn2 zone
    [output reset];
    [self sendNoteChan:9 note:100 vel:127];
    [self assertBytes:NOTE_ON + 3 and:100 and:127 msg:@"test z2"]; // not transposed, channel 3

    // Note at top of conn zone
    [output reset];
    [self sendNoteChan:9 note:68 vel:127];
    [self assertBytes:NOTE_ON + 2 and:80 and:127 msg:@"test z3"]; // transposed, channel 2

    // Note at bottom of conn2 zone
    [output reset];
    [self sendNoteChan:9 note:69 vel:127];
    [self assertBytes:NOTE_ON + 3 and:69 and:127 msg:@"test z4"]; // not transposed, channel 3
}

@end
