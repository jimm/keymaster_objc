#import <XCTest/XCTest.h>
#import <MockOutputInstrument.h>
#import <consts.h>

@interface OutputInstrumentTest : XCTestCase {
    MockOutputInstrument *output;
}
@end

@implementation OutputInstrumentTest

- (void)setUp {
    output = [MockOutputInstrument withShortName:@"mockout" longName:@"Mock Output Instrument"];
}

- (void)testSendPacketList {
    MIDIPacketList packetList;
    packetList.numPackets = 1;
    packetList.packet[0].timeStamp = 0;
    packetList.packet[0].length = 1;
    packetList.packet[0].data[0] = TUNE_REQUEST;

    [output sendPacketList:&packetList];
    STAssertEquals(1UL, [[output buffer] length], @"bad size");
    STAssertEquals((int)(Byte)TUNE_REQUEST, (int)((Byte *)[[output buffer] bytes])[0], @"bad data");
}

- (void)testSendPacket {
    MIDIPacket packet;
    packet.timeStamp = 0;
    packet.length = 1;
    packet.data[0] = TUNE_REQUEST;

    [output sendPacket:&packet];
    STAssertEquals(1UL, [[output buffer] length], @"bad size");
    STAssertEquals((int)TUNE_REQUEST, (int)((Byte *)[[output buffer] bytes])[0], @"bad data");
}

- (void)testSendData {
    Byte bytes[1];
    bytes[0] = TUNE_REQUEST;
    NSData *data = [NSData dataWithBytes:bytes length:1];

    [output sendData:data];
    STAssertEquals(1UL, [[output buffer] length], @"bad size");
    STAssertEquals((int)TUNE_REQUEST, (int)((Byte *)[[output buffer] bytes])[0], @"bad data");
}

- (void)testPanic {
    [output panicSendIndividualNotes:NO];
    STAssertEquals((NSUInteger)(MIDI_CHANNELS * 3), [[output buffer] length], @"wrong num bytes sent");
}

- (void)testPanicWithIndividualNotes {
    [output panicSendIndividualNotes:YES];
    NSUInteger expectedLength = MIDI_CHANNELS * 3 + MIDI_CHANNELS * 128 * 3;
    STAssertEquals(expectedLength, [[output buffer] length], @"wrong num bytes sent");
}

@end
