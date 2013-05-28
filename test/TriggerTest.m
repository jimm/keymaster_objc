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
    trigger = [Trigger withData:data performKey:'n'];
}

- (void)testSignal {
    MIDIPacket packet;
    packet.timeStamp = 0;
    packet.length = 4;
    packet.data[0] = NOTE_ON;
    packet.data[1] = 42;
    packet.data[2] = 127;
    packet.data[3] = TUNE_REQUEST;

    [[KeyMaster instance] queueKeyPress:0];
    [trigger signal:&packet];
    STAssertEquals((int)'n', [[KeyMaster instance] queuedKey], @"bad queued key");
}

- (void)testSignalDoesNotTrigger {
    MIDIPacket packet;
    packet.timeStamp = 0;
    packet.length = 4;
    packet.data[0] = NOTE_ON;
    packet.data[1] = 42;
    packet.data[2] = 127;

    [[KeyMaster instance] queueKeyPress:0];
    [trigger signal:&packet];
    STAssertEquals((int)0, [[KeyMaster instance] queuedKey], @"trigger should not have been sent");
}

- (void)testDataDescription {
    STAssertTrue([@"f6" compare: [trigger dataDescription]] == NSOrderedSame, @"bad data desc \"%@\"", [trigger dataDescription]);
}

@end
