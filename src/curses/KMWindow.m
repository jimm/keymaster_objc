#import <Foundation/NSString.h>
#import <curses/KMWindow.h>

@interface KMWindow (private)

- (id)setMaxContentsLen:(int)len;

@end

@implementation KMWindow

+ (id)withRect:(NSRect)r titlePrefix:(NSString *)tp {
    return [[KMWindow alloc] initWithRect: r titlePrefix:tp];
}

- (id)initWithRect:(NSRect)r titlePrefix:(NSString *)tp {
    self = [super init];
    win = newwin((int)r.size.height, (int)r.size.width, (int)r.origin.y, (int)r.origin.x);
    titlePrefix = tp;
    title = nil;
    [self setMaxContentsLen:r.size.width];
    return self;
}

- (NSString *)titlePrefix {
    return titlePrefix;
}

- (id)titlePrefix:(NSString *)str {
    titlePrefix = str;
    return self;
}

- (NSString *)title {
    return title;
}

- (id)title:(NSString *)str {
    title = str;
    return self;
}

- (id)moveAndResizeTo:(NSRect)r {
    mvwin(win, r.origin.y, r.origin.x);
    wresize(win, r.size.height, r.size.width);
    [self setMaxContentsLen:r.size.width];
    return self;
}

- (id)draw {
    wclear(win);
    box(win, 0, 0);
    if (titlePrefix == nil && title == nil)
        return self;

    wmove(win, 0, 1);
    wattron(win, A_REVERSE);
    waddch(win, ' ');
    if (titlePrefix != nil) {
        waddstr(win, [titlePrefix cStringUsingEncoding:NSASCIIStringEncoding]);
        waddstr(win, ": ");
    }
    if (title != nil)
        waddstr(win, [title cStringUsingEncoding:NSASCIIStringEncoding]);
    waddch(win, ' ');
    wattroff(win, A_REVERSE);

    return self;
}

- (id)noutrefresh {
    wnoutrefresh(win);
    return self;
}

- (int)visibleHeight {
    return getmaxy(win);
}

- (id)setMaxContentsLen:(int)len {
    maxContentsLen = len - 3;    // 2 for borders
    return self;
}

- (NSString *)makeFit:(NSString *)str {
    return [str length] > maxContentsLen ? [str substringToIndex:maxContentsLen] : str;
}

@end
