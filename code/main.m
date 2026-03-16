#import <AppKit/AppKit.h>
#import <stdio.h>

static int Width = 1024;
static int Height = 768;

static bool Running;

unsigned char *bitmapMemory;

static void RenderGradient(int xOffset, int yOffset) {
    int pitch = Width * 4;
    uint8 *row = (uint8 *)bitmapMemory;
    for (int y = 0; y < Height; y++) {
        uint32 *pixel = (uint32 *)row;
        for (int x = 0; x < Width; x++) {
            int Red = 0;
            int Blue = x + xOffset;
            int Green = y + yOffset;
            int Alpha = 255;

            // RR GG BB AA
            // Big Endianness -> AA BB GG RR

            *pixel++ = (Red | Blue << 8 | Green << 16 | Alpha << 24);
        }
        row += pitch;
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
    if (bitmapMemory) {
        free(bitmapMemory);
        bitmapMemory = NULL;
    }

    Height = self.bounds.size.height;
    Width = self.bounds.size.width;
    int pitch = Width * 4;

    size_t size = Height * Width * 4;
    bitmapMemory = malloc(size);

    if (!bitmapMemory) {
        NSLog(@"Bitmap Memory allocation failed");
        return;
    }

    NSBitmapImageRep *bitmapRep =
        [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&bitmapMemory
                                                 pixelsWide:Width
                                                 pixelsHigh:Height
                                              bitsPerSample:8
                                            samplesPerPixel:4
                                                   hasAlpha:YES
                                                   isPlanar:NO
                                             colorSpaceName:NSCalibratedRGBColorSpace
                                                bytesPerRow:pitch
                                               bitsPerPixel:32] autorelease];
    [bitmapRep drawInRect:self.bounds];

    NSLog(@"Redrawing");
}
@end

int main() {
    NSLog(@"Starting Handmade Hero");

    HandmadeHeroMainWindowDelegate *mainWindowDelegate =
        [[HandmadeHeroMainWindowDelegate alloc] init];

    NSRect frame = NSMakeRect(0, 0, Width, Height);

    GameView *gameView = [[GameView alloc] initWithFrame:frame];
    if (!gameView) {
        NSLog(@"Failed to allocate GameView");
        return 1;
    }

    [NSApplication sharedApplication];

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
                NSLog(@"Received event: %@", Event);
            }

            RenderGradient(xOffset, yOffset);
            ++xOffset;

            gameView.needsDisplay = YES;

            usleep(16000);
        }
    }

    return 0;
}
