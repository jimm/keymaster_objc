#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

int main() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    SenSelfTestMain();
    [pool release];
    return 0;
}
