/* -*- objc -*- */

#import <Foundation/NSGeometry.h>

@interface Geometry : NSObject {
    int lines;
    int cols;
    int topHeight;
    int botHeight;
    int topWidth;
    int slsHeight;
    int slHeight;
    int infoWidth;
    int infoLeft;
}

- (id)init;

- (NSRect)songListRect;
- (NSRect)songRect;
- (NSRect)songListsRect;
- (NSRect)triggerRect;
- (NSRect)patchRect;
- (NSRect)messageRect;
- (NSRect)infoRect;
- (NSRect)helpRect;
- (NSRect)promptRect;

@end
