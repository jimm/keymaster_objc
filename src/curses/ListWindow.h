/* -*- objc -*- */

#import <Foundation/NSArray.h>
#import <curses/KMWindow.h>

@interface ListWindow : KMWindow {
  NSArray *list;
  int offset;
  SEL currentItemSelector;
}

+ (id)withRect:(NSRect)r titlePrefix:(NSString *)tp;

- (id)initWithRect:(NSRect)r titlePrefix:(NSString *)tp;

- (id)list:(NSArray *)newList title:(NSString *)newTitle currItemSel:(SEL)sel;

- (id)draw;

@end
