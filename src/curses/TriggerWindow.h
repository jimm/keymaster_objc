/* -*- objc -*- */

#import <Foundation/NSArray.h>
#import <curses/KMWindow.h>

@interface TriggerWindow : KMWindow {
}

+ (id)withRect:(NSRect)r;

- (id)initWithRect:(NSRect)r;

- (id)draw;

@end
