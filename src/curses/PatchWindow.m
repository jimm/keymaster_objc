#import <curses/PatchWindow.h>
#import <KeyMaster.h>
#import <Patch.h>
#import <Connection.h>
#import <Instrument.h>
#import <consts.h>

@interface PatchWindow (private)
- (id)drawHeaders;
- (id)drawConnection:(Connection *)c;
@end

@implementation PatchWindow

+ (id)withRect:(NSRect)r titlePrefix:(NSString *)tp {
    return [[PatchWindow alloc] initWithRect:r titlePrefix:tp];
}

- (id)initWithRect:(NSRect)r titlePrefix:(NSString *)tp {
    self = [super initWithRect:r titlePrefix:tp];
    patch = nil;
    return self;
}

- (Patch *)patch {
    return patch;
}

- (id)patch:(Patch *)p {
    patch = p;
    [self title:(patch == nil ? nil : [patch name])];
    return self;
}

- (id)draw {
    [super draw];
    wmove(win, 1, 1);
    [self drawHeaders];
    if (patch == nil)
        return self;

    int i = 0;
    for (id conn in [patch connections]) {
        wmove(win, i+2, 1);
        [self drawConnection:conn];
        ++i;
    }

    return self;
}

- (id)drawHeaders {
    wattron(win, A_REVERSE);
    NSString *str = @" Input          Chan | Output         Chan |  Prog |    Zone   | Xpose | Filter";
    str = [str stringByAppendingFormat:@"%*s", (int)(getmaxx(win) - 2 - [str length]), " "];
    waddstr(win, [str cStringUsingEncoding:NSASCIIStringEncoding]);
    wattroff(win, A_REVERSE);
    return self;
}

- (id)drawConnection:(Connection *)c {
    char buf[BUFSIZ];

    sprintf(buf, "%16s", [[[c input] longName] cStringUsingEncoding:NSASCIIStringEncoding]);
    NSString *str = [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];

    if ([c inputChan] == UNDEFINED)
        str = [str stringByAppendingString:@"     |"];
    else
        str = [str stringByAppendingFormat:@" %2d  |", [c inputChan] + 1];

    sprintf(buf, " %16s", [[[c output] longName] cStringUsingEncoding:NSASCIIStringEncoding]);
    str = [str stringByAppendingString:[NSString stringWithCString:buf encoding:NSASCIIStringEncoding]];
    str = [str stringByAppendingFormat:@" %2d |", [c outputChan] + 1];

    if ([c bank] == UNDEFINED)
        str = [str stringByAppendingString:@"   "];
    else
        str = [str stringByAppendingFormat:@" %1d/", [c bank]];
    if ([c pcProg] == UNDEFINED)
        str = [str stringByAppendingString:@"   |"];
    else
        str = [str stringByAppendingFormat:@"%3d |", [c pcProg]];

    PYMIDIManager *manager = [[KeyMaster instance] manager];
    // FIXME "%3@% doesn't pad as expected
    sprintf(buf, " %3s - %3s |",
            [[manager nameOfNote:(Byte)[c zoneLow]] cStringUsingEncoding:NSASCIIStringEncoding],
            [[manager nameOfNote:(Byte)[c zoneHigh]] cStringUsingEncoding:NSASCIIStringEncoding]);
    str = [str stringByAppendingString:[NSString stringWithCString:buf encoding:NSASCIIStringEncoding]];

    str = [str stringByAppendingFormat:@"  %4d |", [c xpose]];

    // TODO filter

    waddstr(win, [[self makeFit:str] cStringUsingEncoding:NSASCIIStringEncoding]);

    return self;
}

@end
