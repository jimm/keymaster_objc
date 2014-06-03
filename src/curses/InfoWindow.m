#import <Foundation/NSError.h>
#import <Foundation/NSString.h>
#import <Foundation/NSCharacterSet.h>
#import <curses/InfoWindow.h>

@implementation InfoWindow

+ (id)withRect:(NSRect)r {
    return [[InfoWindow alloc] initWithRect:r];
}

- (id)initWithRect:(NSRect)r {
    self = [super initWithRect: r titlePrefix:nil];
    NSError *err = nil;
    infoText = [NSString stringWithContentsOfFile:@"resources/info_window.txt"
                                         encoding:NSUTF8StringEncoding error:&err];
    if (err != nil) {
        NSLog(@"%@", [err localizedDescription]);
        NSLog(@"%@", [err localizedFailureReason]);
        NSLog(@"%@", [err localizedRecoveryOptions]);
    }
    text = nil;
    return self;
}

- (NSString *)text {
    return text;
}

- (id)text:(NSString *)str {
    if (str != nil) {
        text = str;
        [self title:@"Song Notes"];
    }
    else {
        text = infoText;
        [self title:@"KeyMaster"];
    }
    return self;
}

- (id)draw {
    [super draw];
    if (text == nil)            // should not happen
        return self;

    int i = 1;
    int *pi = &i;
    [text enumerateLinesUsingBlock: ^(NSString *line, BOOL *stop) {
            if (*pi >= getmaxy(win) - 2)
                *stop = YES;
            else {
                wmove(win, *pi+1, 1);
                NSString *str = [NSString stringWithFormat:@" %@", line];
                waddstr(win, [[self makeFit:str] cStringUsingEncoding:NSASCIIStringEncoding]);
                ++*pi;
            }
        }];
    return self;
}

@end
