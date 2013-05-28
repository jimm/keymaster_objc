#import <curses/Geometry.h>
#include <curses.h>

#define PROMPT_WINDOW_MAX_WIDTH 30

@implementation Geometry

- (id)init {
    self = [super init];

    getmaxyx(stdscr, lines, cols);

    topHeight = (lines - 1) * 2 / 3;
    botHeight = (lines - 1) - topHeight;
    topWidth = cols / 3;

    slsHeight = topHeight / 3;
    slHeight = topHeight - slsHeight;

    infoWidth = cols - (topWidth * 2);
    infoLeft = topWidth * 2;
    return self;
}

- (NSRect)songListRect {
    return NSMakeRect(0, 0, topWidth, slHeight);
}

- (NSRect)songRect {
    return NSMakeRect(topWidth, 0, topWidth, slHeight);
}

- (NSRect)songListsRect {
    return NSMakeRect(0, slHeight, topWidth, slsHeight);
}

- (NSRect)triggerRect {
    return NSMakeRect(topWidth, slHeight, topWidth, slsHeight);
}

- (NSRect)patchRect {
    return NSMakeRect(0, topHeight, cols, botHeight);
}

- (NSRect)messageRect {
    return NSMakeRect(0, lines - 1, cols, 1);
}

- (NSRect)infoRect {
    return NSMakeRect(infoLeft, 0, infoWidth, topHeight);
}

- (NSRect)helpRect {
    return NSMakeRect(3, 3, 6-lines, cols-6);
}

- (NSRect)promptRect {
    int width = cols / 2;
    if (width > PROMPT_WINDOW_MAX_WIDTH)
        width = PROMPT_WINDOW_MAX_WIDTH;
    return NSMakeRect((cols - width) / 2, lines / 3, width, 4);
}

@end
