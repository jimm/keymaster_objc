#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSString.h>
#import <KeyMaster.h>
#import <Reader.h>
#import <string.h>

#define LOGFILE "/tmp/keymaster.log"

int main(int argc, char **argv) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    freopen(LOGFILE, "a+", stderr);

    if (argc > 1 && strncmp(argv[1], "-l", 2) == 0) {
        [[KeyMaster instance] printSourcesAndDestinations];
    }
    else {
        if (argc > 1)
            [[[Reader alloc] init] read:[NSString stringWithCString:argv[1] encoding:NSASCIIStringEncoding]];
        [[KeyMaster instance] run];
    }

    [pool release];
    return 0;
}
