/* -*- objc -*- */

#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSString.h>
#import <curses.h>

@interface KMWindow : NSObject {
  WINDOW *win;
  NSString *titlePrefix;
  NSString *title;
  int maxContentsLen;
}

+ (id)withRect:(NSRect)r titlePrefix:(NSString *)tp;

- (id)initWithRect:(NSRect)r titlePrefix:(NSString *)tp;

- (NSString *)titlePrefix;
- (id)titlePrefix:(NSString *)str;

- (NSString *)title;
- (id)title:(NSString *)str;

- (id)moveAndResizeTo:(NSRect)r;
- (id)draw;
- (id)noutrefresh;
- (int)visibleHeight;

- (NSString *)makeFit:(NSString *)str;

@end
