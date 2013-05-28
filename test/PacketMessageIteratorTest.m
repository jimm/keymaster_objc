#import <SenTestingKit/SenTestingKit.h>
#import <PacketMessageIterator.h>
#import <consts.h>

#define BIG_MESSAGE_SIZE 3333

@interface PacketMessageIteratorTest : SenTestCase {
    MIDIPacket *packet;
    PacketMessageIterator *pmi;
}

- (void)createPMIWithBytes:(Byte *)bytes len:(NSUInteger)len;
@end

@implementation PacketMessageIteratorTest

- (void)setUp {
    packet = nil;
    pmi = nil;
}

- (void)tearDown {
    if (packet != nil)
        free(packet);
}

// Sets the packet and pmi ivars.
- (void)createPMIWithBytes:(Byte *)bytes len:(NSUInteger)len {
    packet = (MIDIPacket *)malloc(sizeof(MIDITimeStamp) + sizeof(UInt16) + len);
    packet->timeStamp = 0;
    packet->length = len;
    memcpy(packet->data, bytes, len);

    pmi = [[PacketMessageIterator alloc] initWithPacket:packet];
}

- (void)testEmptyPacket {
    Byte bytes[0];
    [self createPMIWithBytes:bytes len:0];
    
    STAssertNil((void *)[pmi message], @"message before nextMessage should return nil");
    STAssertNil((void *)[pmi nextMessage], @"nextMessage should be nil for empty packet");
}

- (void)testMessageAndNextMessage {
    Byte bytes[3];
    bytes[0] = NOTE_ON;
    bytes[1] = 42;
    bytes[2] = 127;
    [self createPMIWithBytes:bytes len:3];
    
    STAssertNotNil((void *)[pmi message], @"first message call should succeed");
    STAssertEquals(3UL, [pmi messageLength], @"first message should be 3 bytes");
    Byte *msg = [pmi nextMessage];
    STAssertNil((void *)msg, @"nextMessage should return nil");
    STAssertNil((void *)[pmi message], @"message should now return nil");
}

- (void)testMultipleMessages {
    Byte bytes[8];
    bytes[0] = PROGRAM_CHANGE;
    bytes[1] = 1;
    bytes[2] = NOTE_ON;
    bytes[3] = 42;
    bytes[4] = 127;
    bytes[5] = NOTE_OFF;
    bytes[6] = 40;
    bytes[7] = 127;
    [self createPMIWithBytes:bytes len:8];
    
    Byte *msg = [pmi message];
    STAssertNotNil((void *)msg, @"first message call should succeed");
    STAssertEquals(2UL, [pmi messageLength], @"first message should be 2 bytes");
    STAssertEquals((Byte)PROGRAM_CHANGE, msg[0], @"bad status");
    STAssertEquals((Byte)1, msg[1], @"bad pc val");
    
    msg = [pmi nextMessage];
    STAssertNotNil((void *)msg, @"message call should succeed");
    STAssertEquals(3UL, [pmi messageLength], @"message should be 3 bytes");
    STAssertEquals((Byte)NOTE_ON, msg[0], @"bad status");
    STAssertEquals((Byte)42, msg[1], @"bad note");
    STAssertEquals((Byte)127, msg[2], @"bad note vel");

    msg = [pmi nextMessage];
    STAssertNotNil((void *)msg, @"message call should succeed");
    STAssertEquals(3UL, [pmi messageLength], @"message should be 3 bytes");
    STAssertEquals((Byte)NOTE_OFF, msg[0], @"bad status");
    STAssertEquals((Byte)40, msg[1], @"bad note");
    STAssertEquals((Byte)127, msg[2], @"bad note vel");
    
    msg = [pmi nextMessage];
    STAssertNil((void *)msg, @"message call should be nil");
    STAssertEquals(0UL, [pmi messageLength], @"message should be 0 bytes");
}

- (void)testSysex {
    Byte bytes[4];
    bytes[0] = SYSEX;
    bytes[1] = 1;
    bytes[2] = 2;
    bytes[3] = EOX;
    [self createPMIWithBytes:bytes len:4];

    Byte *msg = [pmi message];
    STAssertNotNil((void *)msg, @"first message call should succeed");
    STAssertEquals(4UL, [pmi messageLength], @"first message should be 4 bytes");
    STAssertEquals((Byte)SYSEX, msg[0], @"bad sysex");
    STAssertEquals((Byte)1, msg[1], @"bad sysex body");
    STAssertEquals((Byte)2, msg[2], @"bad sysex body");
    STAssertEquals((Byte)EOX, msg[3], @"bad eox");
}

- (void)testSysexWithStuffAfter {
    Byte bytes[5];
    bytes[0] = SYSEX;
    bytes[1] = 1;
    bytes[2] = 2;
    bytes[3] = EOX;
    bytes[4] = TUNE_REQUEST;
    [self createPMIWithBytes:bytes len:5];

    Byte *msg = [pmi message];
    STAssertNotNil((void *)msg, @"first message call should succeed");
    STAssertEquals(4UL, [pmi messageLength], @"first message should be 4 bytes");
    STAssertEquals((Byte)SYSEX, msg[0], @"bad sysex");
    STAssertEquals((Byte)1, msg[1], @"bad sysex body");
    STAssertEquals((Byte)2, msg[2], @"bad sysex body");
    STAssertEquals((Byte)EOX, msg[3], @"bad eox");

    msg = [pmi nextMessage];
    STAssertNotNil((void *)msg, @"next message not seen");
    STAssertEquals(1UL, [pmi messageLength], @"bad msg len");
    STAssertEquals((Byte)TUNE_REQUEST, msg[0], @"bad tune req");
}

- (void)testSysexFirstPart {
    Byte bytes[4];
    bytes[0] = SYSEX;
    bytes[1] = 1;
    bytes[2] = 2;
    bytes[3] = 3;
    [self createPMIWithBytes:bytes len:4];

    Byte *msg = [pmi message];
    STAssertNotNil((void *)msg, @"first message call should succeed");
    STAssertEquals(4UL, [pmi messageLength], @"first message should be 4 bytes");
    STAssertEquals((Byte)SYSEX, msg[0], @"bad sysex");
    STAssertEquals((Byte)1, msg[1], @"bad sysex body");
    STAssertEquals((Byte)2, msg[2], @"bad sysex body");
    STAssertEquals((Byte)3, msg[3], @"bad eox");
}

- (void)testSysexSecondPart {
    Byte bytes[6];
    bytes[0] = 0;
    bytes[1] = 1;
    bytes[2] = 2;
    bytes[3] = EOX;
    bytes[4] = PROGRAM_CHANGE;
    bytes[5] = 42;
    [self createPMIWithBytes:bytes len:6];

    Byte *msg = [pmi message];
    STAssertNotNil((void *)msg, @"first message call should succeed");
    STAssertEquals(4UL, [pmi messageLength], @"first message should be 4 bytes");
    STAssertEquals((Byte)0, msg[0], @"bad sysex");
    STAssertEquals((Byte)1, msg[1], @"bad sysex body");
    STAssertEquals((Byte)2, msg[2], @"bad sysex body");
    STAssertEquals((Byte)EOX, msg[3], @"bad eox");

    msg = [pmi nextMessage];
    STAssertEquals(2UL, [pmi messageLength], @"following message len is wrong");
    STAssertEquals((Byte)PROGRAM_CHANGE, msg[0], @"bad pc status");
    STAssertEquals((Byte)42, msg[1], @"bad data byte");
}


@end
