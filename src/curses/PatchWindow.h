/* -*- objc -*- */

#import <Foundation/NSArray.h>
#import <curses/KMWindow.h>

@class Patch;

@interface PatchWindow : KMWindow {
  Patch *patch;
}

+ (id)withRect:(NSRect)r titlePrefix:(NSString *)tp;

- (id)initWithRect:(NSRect)r titlePrefix:(NSString *)tp;

- (Patch *)patch;
- (id)patch:(Patch *)patch;

- (id)draw;

@end
