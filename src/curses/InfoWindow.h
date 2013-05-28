/* -*- objc -*- */

#import <Foundation/NSArray.h>
#import <curses/KMWindow.h>

@interface InfoWindow : KMWindow {
  NSString *infoText;
  NSString *text;
}

+ (id)withRect:(NSRect)r;

- (id)initWithRect:(NSRect)r;

- (NSString *)text;
- (id)text:(NSString *)str;

- (id)draw;

@end
