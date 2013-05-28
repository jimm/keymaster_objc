#import <Foundation/NSString.h>
#import <curses/PromptWindow.h>
#import <curses/Geometry.h>

@interface PromptWindow (private)
- (NSString *)readString;
- (id)draw;
@end

@implementation PromptWindow

+ (id)withTitle:(NSString *)t prompt:(NSString *)p {
    return [[PromptWindow alloc] initWithTitle:t prompt:p];
}

- (id)initWithTitle:(NSString *)t prompt:(NSString *)p {
    self = [super init];
    Geometry *g = [[Geometry alloc] init];
    NSRect r = [g promptRect];
    win = newwin((int)r.size.height, (int)r.size.width, (int)r.origin.y, (int)r.origin.x);
    title = t;
    prompt = p;
    return self;
}

- (NSString *)gets {
    [self draw];
    NSString *str = [self readString];
    delwin(win);
    return str;
}

- (id)draw {
    box(win, 0, 0);
    wmove(win, 0, 1);
    wattron(win, A_REVERSE);
    waddch(win, ' ');
    waddstr(win, [title cStringUsingEncoding:NSASCIIStringEncoding]);
    waddch(win, ' ');
    wattroff(win, A_REVERSE);

    wmove(win, 1, 1);
    waddstr(win, [prompt cStringUsingEncoding:NSASCIIStringEncoding]);

    wmove(win, 2, 1);
    wattron(win, A_REVERSE);

    int numSpaces = getmaxx(win) - 2;
    char buf[numSpaces + 1];
    sprintf(buf, "%*s", numSpaces, " ");
    buf[numSpaces] = '\0';
    waddstr(win, buf);

    wattroff(win, A_REVERSE);

    wmove(win, 2, 1);
    wrefresh(win);

    return self;
}

- (NSString *)readString {
    nocbreak();
    echo();
    curs_set(1);

    char buf[BUFSIZ];
    wattron(win, A_REVERSE);
    wgetstr(win, buf);
    wattroff(win, A_REVERSE);

    curs_set(0);
    noecho();
    cbreak();

    return [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];
}

@end
