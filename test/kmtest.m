#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

int main() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    SenSelfTestMain();
    [pool release];
    return 0;
}
