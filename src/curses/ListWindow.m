#import <curses/ListWindow.h>
#import <KeyMaster.h>

@implementation ListWindow

+ (id)withRect:(NSRect)r titlePrefix:(NSString *)tp {
    return [[ListWindow alloc] initWithRect:r titlePrefix:tp];
}

- (id)initWithRect:(NSRect)r titlePrefix:(NSString *)tp {
    self = [super initWithRect:r titlePrefix:tp];
    offset = 0;
    list = nil;
    return self;
}

// +curr_item_method_sym+ is a method symbol that is sent to the KeyMaster
// instance to obtain the current item so we can highlight it.
- (id)list:(NSArray *)newList title:(NSString *)newTitle currItemSel:(SEL)sel {
    list = newList;
    [self title:newTitle];
    offset = 0;
    currentItemSelector = sel;
    return self;
}

- (id)draw {
    [super draw];
    if (list == nil)
        return self;

    id currItem = [[KeyMaster instance] performSelector:currentItemSelector];
    int currIndex = [list indexOfObject:currItem];

    if (currIndex < offset)
        offset = currIndex;
    else if (currIndex >= offset + [self visibleHeight])
        offset = currIndex - [self visibleHeight] + 1;

    int i = 0;
    for (id thing in list) {
        wmove(win, i+1, 1);
        if (thing == currItem)
            wattron(win, A_REVERSE);
        waddstr(win, [[self makeFit:[thing performSelector:@selector(name)]] cStringUsingEncoding:NSASCIIStringEncoding]);
        if (thing == currItem)
            wattroff(win, A_REVERSE);
        ++i;
    }

    return self;
}

@end
