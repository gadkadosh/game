#import <AppKit/AppKit.h>
#import <stdio.h>

static float GlobalRenderWidth = 1024;
static float GlobalRenderHeight = 768;

static bool Running = true;

@interface HandmadeHeroMainWindowDelegate : NSObject <NSWindowDelegate>
@end

@implementation HandmadeHeroMainWindowDelegate
- (void)windowWillClose:(id)sender {
    Running = false;
}
@end

int main() {
    NSLog(@"Starting Handmade Hero");

    HandmadeHeroMainWindowDelegate *mainWindowDelegate =
        [[HandmadeHeroMainWindowDelegate alloc] init];

    NSRect frame = NSMakeRect(0, 0, GlobalRenderWidth, GlobalRenderHeight);

    [NSApplication sharedApplication];

    NSWindow *window = [[NSWindow alloc]
        initWithContentRect:frame
                  styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                             NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable)
                    backing:NSBackingStoreBuffered
                      defer:NO];

    [window setBackgroundColor:NSColor.redColor];
    [window setTitle:@"Test Window"];
    [window makeKeyAndOrderFront:nil];
    [window setDelegate:mainWindowDelegate];

    do {
        NSEvent *event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                            untilDate:nil
                                               inMode:NSDefaultRunLoopMode
                                              dequeue:YES];
        [NSApp sendEvent:event];
    } while (Running);

    return 0;
}
