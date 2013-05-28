/* -*- objc -*- */

#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSString.h>
#import <curses.h>

@interface PromptWindow : NSObject {
  WINDOW *win;
  NSString *title;
  NSString *prompt;
}

+ (id)withTitle:(NSString *)t prompt:(NSString *)p;

- (id)initWithTitle:(NSString *)t prompt:(NSString *)p;

- (NSString *)gets;

@end
