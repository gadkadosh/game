#import <AppKit/AppKit.h>
#import <stdio.h>

typedef struct {
    int width;
    int height;
    int bytesPerPixel;
    int pitch;
    unsigned char *memory;
} Backbuffer;

static bool Running;
static Backbuffer GlobalBackbuffer;

static void RenderGradient(Backbuffer buffer, int xOffset, int yOffset) {
    uint8 *row = (uint8 *)buffer.memory;
    for (int y = 0; y < buffer.height; y++) {
        uint32 *pixel = (uint32 *)row;
        for (int x = 0; x < buffer.width; x++) {
            uint8 Red;
            uint8 Green;
            uint8 Blue;
            uint8 Alpha = 255;

            if (((x + xOffset) / 256) % 3 == 0) {
                Red = x + xOffset;
                Green = 0;
                Blue = y + yOffset;
            } else if (((x + xOffset) / 256) % 3 == 1) {
                Red = 0;
                Green = x + xOffset;
                Blue = y + yOffset;
            } else {
                Red = y + yOffset;
                Green = x + xOffset;
                Blue = 0;
            }

            // RR GG BB AA
            // Little Endian -> AA BB GG RR

            *pixel++ = (Red << 0 | Green << 8 | Blue << 16 | Alpha << 24);
        }
        row += buffer.pitch;
    }
}

@interface HandmadeHeroMainWindowDelegate : NSObject <NSWindowDelegate>
@end

@implementation HandmadeHeroMainWindowDelegate
- (void)windowWillClose:(id)sender {
    Running = false;
}
@end

@interface GameView : NSView
@end

@implementation GameView
- (void)drawRect:(NSRect)rect {
    NSBitmapImageRep *bitmapRep =
        [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&GlobalBackbuffer.memory
                                                 pixelsWide:GlobalBackbuffer.width
                                                 pixelsHigh:GlobalBackbuffer.height
                                              bitsPerSample:8
                                            samplesPerPixel:GlobalBackbuffer.bytesPerPixel
                                                   hasAlpha:YES
                                                   isPlanar:NO
                                             colorSpaceName:NSCalibratedRGBColorSpace
                                                bytesPerRow:GlobalBackbuffer.pitch
                                               bitsPerPixel:32] autorelease];
    [bitmapRep drawInRect:self.bounds];
}
@end

int main() {
    NSLog(@"Starting Handmade Hero");

    GlobalBackbuffer.width = 1024;
    GlobalBackbuffer.height = 768;
    GlobalBackbuffer.bytesPerPixel = 4;
    GlobalBackbuffer.pitch = GlobalBackbuffer.width * GlobalBackbuffer.bytesPerPixel;
    GlobalBackbuffer.memory = NULL;
    size_t size = GlobalBackbuffer.height * GlobalBackbuffer.width * GlobalBackbuffer.bytesPerPixel;
    GlobalBackbuffer.memory = malloc(size);
    if (!GlobalBackbuffer.memory) {
        NSLog(@"Bitmap Memory allocation failed");
        return 1;
    }

    HandmadeHeroMainWindowDelegate *mainWindowDelegate =
        [[HandmadeHeroMainWindowDelegate alloc] init];

    NSRect frame = NSMakeRect(0, 0, GlobalBackbuffer.width, GlobalBackbuffer.height);

    GameView *gameView = [[GameView alloc] initWithFrame:frame];
    if (!gameView) {
        NSLog(@"Failed to allocate GameView");
        return 1;
    }

    [NSApplication sharedApplication];
    [NSApp setPresentationOptions:NSApplicationPresentationDefault];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp finishLaunching];

    NSWindow *window = [[NSWindow alloc]
        initWithContentRect:frame
                  styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                             NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable)
                    backing:NSBackingStoreBuffered
                      defer:NO];

    [window setBackgroundColor:NSColor.blackColor];
    [window setTitle:@"Handmade Hero"];
    [window makeKeyAndOrderFront:nil];
    [window setDelegate:mainWindowDelegate];
    [window setContentView:gameView];

    Running = true;
    int xOffset = 0;
    int yOffset = 0;
    while (Running) {
        @autoreleasepool {
            NSEvent *Event;

            while ((Event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                               untilDate:nil
                                                  inMode:NSDefaultRunLoopMode
                                                 dequeue:YES])) {
                [NSApp sendEvent:Event];
            }

            RenderGradient(GlobalBackbuffer, xOffset, yOffset);
            ++xOffset;
            yOffset += 2;

            gameView.needsDisplay = YES;

            usleep(16000);
        }
    }

    return 0;
}
