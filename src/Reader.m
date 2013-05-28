#import <Foundation/NSData.h>
#import <Foundation/NSRegularExpression.h>
#import <Foundation/NSCharacterSet.h>
#import <PYMIDI/PYMIDI.h>
#import <Reader.h>
#import <KeyMaster.h>
#import <Chain.h>
#import <Song.h>
#import <Patch.h>
#import <Connection.h>
#import <Trigger.h>
#import <InputInstrument.h>
#import <OutputInstrument.h>

@interface Reader (private)
- (void)processLine:(NSString *)line;
- (void)notesLine:(NSString *)line;
- (void)endNotes:(NSString *)line;
- (int)noteFromStr:(NSString *)str;
- (void)addSongToChain:(NSString *)line;
- (NSString *)cleanse:(NSString *)line;
- (NSTextCheckingResult *)match:(NSString *)regexString inString:(NSString *)str;
@end

@implementation Reader

- (id)init {
    self = [super init];
    km = [KeyMaster instance];
    chain = nil;
    song = nil;
    patch = nil;
    connection = nil;
    trigger = nil;
    readingNotes = NO;
    readingChain = NO;
    return self;
}

- (id)read:(NSString *)file {
    NSError *err = nil;
    NSString *text = [NSString stringWithContentsOfFile:file
                                               encoding:NSUTF8StringEncoding error:&err];
    if (err != nil) {
        NSLog(@"error reading %@: %@", file, err);
        return self;
    }

    [text enumerateLinesUsingBlock: ^(NSString *line, BOOL *stop) { [self processLine:line]; }];
    return self;
}


- (void)processLine:(NSString *)line {
    if (readingNotes) {
        if ([line caseInsensitiveCompare:@"end notes"] == NSOrderedSame)
            [self endNotes:line];
        else
            [self notesLine:line];
        return;
    }

    line = [self cleanse:line];
    if ([line length] == 0)
        return;

    if (readingChain) {
        [self addSongToChain:line];
        return;
    }

    NSTextCheckingResult *match = [self match:@"^(\\w+)" inString:line];
    if (match) {
        NSString *word = [line substringWithRange:[match rangeAtIndex:1]];

        NSString *selString = [NSString stringWithFormat:@"%@:", [word lowercaseString]];
        SEL sel = NSSelectorFromString(selString);
        if ([self respondsToSelector:sel])
            [self performSelector:sel withObject:line];
        else
            NSLog(@"Reader does not respond to selector %@", selString);
    }
}

- (void)input:(NSString *)line {
    NSTextCheckingResult *match = [self match:@"input\\s+(\\w+)\\s+(.*)" inString:line];
    if (match) {
        NSRange shortNameRange = [match rangeAtIndex:1];
        NSRange longNameRange = [match rangeAtIndex:2];
        NSString *longName = [line substringWithRange:longNameRange];
        InputInstrument *input = [InputInstrument withShortName:[line substringWithRange:shortNameRange]
                                                       longName:longName
                                                       endpoint:[km inputNamed:longName]];
        [km addInput:input];
    }
}

- (void)output:(NSString *)line {
    NSTextCheckingResult *match = [self match:@"output\\s+(\\w+)\\s+(.*)" inString:line];
    if (match) {
        NSRange shortNameRange = [match rangeAtIndex:1];
        NSRange longNameRange = [match rangeAtIndex:2];
        NSString *longName = [line substringWithRange:longNameRange];
        OutputInstrument *output = [OutputInstrument withShortName:[line substringWithRange:shortNameRange]
                                                          longName:longName
                                                          endpoint:[km inputNamed:longName]];
        [km addOutput:output];
    }
}

- (void)message:(NSString *)line {
    // TODO
}

- (void)messageKey:(NSString *)line {
    // TODO
}

- (void)trigger:(NSString *)line {
    NSArray *args = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([args count] < 4) {
        NSLog(@"trigger command needs instrument, a key, and one or more byte values");
        return;
    }

    InputInstrument *inst = [km inputWithShortName:[args objectAtIndex:1]];
    if (inst == nil) {
        NSLog(@"trigger: can't find instrument with short name %@", [args objectAtIndex:1]);
        return;
    }
    int key = [[args objectAtIndex:2] characterAtIndex:0];

    // The rest of the args are byte values, except the last one which is a
    // keypress key number.
    int len = [args count];
    unsigned char bytes[len-3];
    int i;
    for (i = 3; i < len; ++i)
        bytes[i-3] = [[args objectAtIndex:i] intValue];

    NSData *data = [NSData dataWithBytes:bytes length:len-3]; // all but the last key byte
    [inst addTrigger:[Trigger withData:data performKey:key]];
}

- (void)song:(NSString *)line {
    NSTextCheckingResult *match = [self match:@"song\\s+(.*)" inString:line];
    if (match) {
        NSRange nameRange = [match rangeAtIndex:1];
        NSString *name = [line substringWithRange:nameRange];
        song = [Song withName:name];
        [km addSong:song];
    }
}

- (void)notes:(NSString *)line {
    readingNotes = YES;
}

- (void)notesLine:(NSString *)line {
    if (notes == nil)
        notes = [NSString stringWithString:line];
    else
        notes = [notes stringByAppendingFormat:@"\n%@", line];
}

- (void)endNotes:(NSString *)line {
    [song notes:notes];
    notes = nil;
    readingNotes = NO;
}

- (void)patch:(NSString *)line {
    NSTextCheckingResult *match = [self match:@"patch\\s+(.*)" inString:line];
    if (match) {
        NSRange nameRange = [match rangeAtIndex:1];
        patch = [Patch withName:[line substringWithRange:nameRange] inSong:song];
        [song addPatch:patch];
    }
}

- (void)startBytes:(NSString *)line {
    // TODO
}

- (void)stopBytes:(NSString *)line {
    // TODO
}

- (void)connection:(NSString *)line {
    NSString *inName = nil;
    NSString *inChanStr = nil;
    NSString *outName = nil;
    NSString *outChanStr = nil;

    NSTextCheckingResult *match = [self match:@"\\w+\\s+(\\w+)\\s+(\\d+)\\s+(\\w+)\\s+(\\d+)"
                                     inString:line];
    if (match) {
        NSRange r1 = [match rangeAtIndex:1];
        NSRange r2 = [match rangeAtIndex:2];
        NSRange r3 = [match rangeAtIndex:3];
        NSRange r4 = [match rangeAtIndex:4];
        inName = [line substringWithRange:r1];
        inChanStr = [line substringWithRange:r2];
        outName = [line substringWithRange:r3];
        outChanStr = [line substringWithRange:r4];
    }
    else {
        match = [self match:@"\\w+\\s+(\\w+)\\s+(\\w+)\\s+(\\d+)"
                   inString:line];
        if (!match)
            return;

        NSRange r1 = [match rangeAtIndex:1];
        NSRange r2 = [match rangeAtIndex:2];
        NSRange r3 = [match rangeAtIndex:3];

        inName = [line substringWithRange:r1];
        outName = [line substringWithRange:r2];
        outChanStr = [line substringWithRange:r3];
    }

    connection = [[Connection alloc] init];
    [connection input:[km inputWithShortName:inName]];
    if (inChanStr != nil)
        [connection inputChan:[inChanStr intValue] - 1];
    [connection output:[km outputWithShortName:outName]];
    [connection outputChan:[outChanStr intValue] - 1];

    [patch addConnection:connection];
}

- (void)conn:(NSString *)line {
    [self connection:line];
}

- (void)c:(NSString *)line {
    [self connection:line];
}

- (void)pc:(NSString *)line {
    NSTextCheckingResult *match = [self match:@"\\w+\\s+(\\w+)(\\s+(\\w+))?" inString:line];
    if (match) {
        NSRange firstArgRange = [match rangeAtIndex:1];
        NSRange secondArgRange = [match rangeAtIndex:3];
        if (secondArgRange.location == NSNotFound) {
            [connection pcProg:[[line substringWithRange:firstArgRange] intValue]];
        }
        else {
            [connection bank:[[line substringWithRange:firstArgRange] intValue]];
            [connection pcProg:[[line substringWithRange:secondArgRange] intValue]];
        }
    }
}

- (void)programchange:(NSString *)line {
    [self pc:line];
}

 - (void)progchg:(NSString *)line {
    [self pc:line];
}

- (void)zone:(NSString *)line {
    NSTextCheckingResult *match = [self match:@"zone\\s+(\\w+)\\s+(\\w+)" inString:line];
    if (match) {
        [connection  zoneLow:[self noteFromStr:[line substringWithRange:[match rangeAtIndex:1]]]];
        [connection zoneHigh:[self noteFromStr:[line substringWithRange:[match rangeAtIndex:2]]]];
    }
}

- (int)noteFromStr:(NSString *)str {
    char ch = [str characterAtIndex:0];
    if (isdigit(ch))
        return [str intValue];
    else {
        int note, octave;
        switch (ch) {
        case 'c': case 'C': note = 0; break;
        case 'd': case 'D': note = 2; break;
        case 'e': case 'E': note = 4; break;
        case 'f': case 'F': note = 5; break;
        case 'g': case 'G': note = 7; break;
        case 'a': case 'A': note = 9; break;
        case 'b': case 'B': note = 11; break;
        }
        ch = [str characterAtIndex:1];
        int octaveIndex = 1;
        if (ch == '#' || ch == 's' || ch == 'S') {
            ++note;
            ++octaveIndex;
        }
        else if (ch == 'b') {
            --note;
            ++octaveIndex;
        }
        octave = [[str substringFromIndex:octaveIndex] intValue];
        return (octave - 1) * 12 + note;
    }
}

- (void)xpose:(NSString *)line {
    NSTextCheckingResult *match = [self match:@"\\w+\\s+(\\w+)" inString:line];
    if (match)
        [connection xpose:[[line substringWithRange:[match rangeAtIndex:1]] intValue]];
}

- (void)x:(NSString *)line {
    [self xpose:line];
}

- (void)transpose:(NSString *)line {
    [self xpose:line];
}

- (void)filter:(NSString *)line {
    // TODO
}

- (void)chain:(NSString *)line {
    NSTextCheckingResult *match = [self match:@"chain\\s+(.*)" inString:line];
    if (match) {
        chain = [Chain withName:[line substringWithRange:[match rangeAtIndex:1]]];
        [km addChain:chain];
        readingChain = YES;
    }
}

- (void)addSongToChain:(NSString *)line {
    NSTextCheckingResult *match = [self match:@"song\\s+(.*)" inString:line];
    if (match) {
        NSString *name = [line substringWithRange:[match rangeAtIndex:1]];
        song = [[km allSongs] findSongWithName:name];
        if (song == nil)
            NSLog(@"Could not find song named \"%@\"", name);
        else
            [chain addSong:song];
    }
}


- (void)aliasInput:(NSString *)line {
    // TODO
}

- (void)aliasOutput:(NSString *)line {
    // TODO
}

- (NSString *)cleanse:(NSString *)line {
    // Remove comment
    NSRange range = [line rangeOfString:@"//"];
    if (range.location != NSNotFound)
        line = [line substringToIndex:range.location];

    // Trim whitespace
    return [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSTextCheckingResult *)match:(NSString *)regexString inString:(NSString *)str {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                           options:0
                                                                             error:&error];
    if (error != nil) {
        NSLog(@"%@", error);
        return;
    }
    return [regex firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
}

@end
