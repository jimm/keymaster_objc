/* -*- objc -*- */

#import <Foundation/NSObject.h>
#import <CoreMIDI/CoreMIDI.h>

@class InputInstrument, OutputInstrument, NSMutableData;

@interface Connection : NSObject {
    InputInstrument *input;
    int inputChan;             // -1 means all channels
    OutputInstrument *output;
    int outputChan;
    int bank;                   // -1 means no bank
    int pcProg;                 // -1 means no prog
    int zoneLow;
    int zoneHigh;
    int xpose;
    NSMutableData *filteredControllerNumbers;
    NSMutableData *filteredStatuses;
}

- (id)init;

- (id)start:(NSData *)startData;
- (id)stop:(NSData *)stopData;

- (InputInstrument *)input;
- (id)input:(InputInstrument *)input;

- (int)inputChan;
- (id)inputChan:(int)inputChan;

- (OutputInstrument *)output;
- (id)output:(OutputInstrument *)output;

- (int)outputChan;
- (id)outputChan:(int)outputChan;

- (int)bank;
- (id)bank:(int)bank;

- (int)pcProg;
- (id)pcProg:(int)pcProg;

- (int)zoneLow;
- (id)zoneLow:(int)zoneLow;

- (int)zoneHigh;
- (id)zoneHigh:(int)zoneHigh;

- (BOOL)inZone:(Byte)note;

- (int)xpose;
- (id)xpose:(int)xpose;

- (NSData *)filteredControllerNumbers;
- (id)addFilteredControllerNumber:(Byte)cc;

- (NSData *)filteredStatuses;
- (id)addFilteredStatus:(Byte)b;

- (id)midiIn:(MIDIPacket *)packet;

@end
