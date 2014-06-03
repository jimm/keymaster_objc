#import <curses/TriggerWindow.h>
#import <Trigger.h>
#import <KeyMaster.h>
#import <InputInstrument.h>

@implementation TriggerWindow

+ (id)withRect:(NSRect)r {
    return [[TriggerWindow alloc] initWithRect:r];
}

- (id)initWithRect:(NSRect)r {
    self = [super initWithRect: r titlePrefix:nil];
    [self title:@"Triggers"];
    return self;
}

- (id)draw {
    [super draw];

    wmove(win, 1, 1);
    wattron(win, A_REVERSE);
    NSString *str = @" Key | Input            | Trigger";
    str = [str stringByAppendingFormat:@"%*s", (int)(getmaxx(win) - 2 - [str length]), " "];
    waddstr(win, [str cStringUsingEncoding:NSASCIIStringEncoding]);
    wattroff(win, A_REVERSE);

    char buf[BUFSIZ];
    KeyMaster *km = [KeyMaster instance];
    int i = 0;
    for (InputInstrument *instrument in [km inputs]) {
        for (Trigger *trigger in [instrument triggers]) {
            if (i < [self visibleHeight]) {
                wmove(win, i+2, 2);
                sprintf(buf, "%16s", [[instrument longName] cStringUsingEncoding:NSASCIIStringEncoding]);
                str = [NSString stringWithFormat:@" %c  | %s | %@", [trigger actionKey], buf, [trigger dataDescription]];
                waddstr(win, [[self makeFit:str] cStringUsingEncoding:NSASCIIStringEncoding]);
            }
            ++i;
        }
    }
    return self;
}

@end
