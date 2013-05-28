#import <SenTestingKit/SenTestingKit.h>
#import <Trigger.h>
#import <KeyMaster.h>
#import <consts.h>

@interface TriggerTest : SenTestCase {
    Trigger *trigger;
}
@end

@implementation TriggerTest

- (void)setUp {
    Byte bytes[1];
    bytes[0] = TUNE_REQUEST;
    NSData *data = [NSData dataWithBytes:bytes length:1];
    trigger = [Trigger withData:data performKey:[[KeyMaster instance] testingKey]];
    [[KeyMaster instance] testingKeySent:NO];
}

- (void)testSignal {
    MIDIPacket packet;
    packet.timeStamp = 0;
    packet.length = 4;
    packet.data[0] = NOTE_ON;
    packet.data[1] = 42;
    packet.data[2] = 127;
    packet.data[3] = TUNE_REQUEST;

    STAssertEquals(NO, [[KeyMaster instance] testingKeySent], @"bad initial state");
    [trigger signal:&packet];
    STAssertEquals(YES, [[KeyMaster instance] testingKeySent], @"trigger not executed");
}

- (void)testSignalDoesNotTrigger {
    MIDIPacket packet;
    packet.timeStamp = 0;
    packet.length = 4;
    packet.data[0] = NOTE_ON;
    packet.data[1] = 42;
    packet.data[2] = 127;

    STAssertEquals(NO, [[KeyMaster instance] testingKeySent], @"bad initial state");
    [trigger signal:&packet];
    STAssertEquals(NO, [[KeyMaster instance] testingKeySent], @"trigger should not have been executed");
}

- (void)testDataDescription {
    STAssertTrue([@"f6" compare: [trigger dataDescription]] == NSOrderedSame, @"bad data desc \"%@\"", [trigger dataDescription]);
}

@end
