//
//  ISSLiveView.m
//  ISSLive
//
//  Created by Boog on 5/1/14.
//  Copyright (c) 2014 Bailey Carlson. All rights reserved.
//

#import "ISSLiveView.h"

static NSString * const MyModuleName = @"com.baileycarlson.ISSLive";

@implementation ISSLiveView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {

        ScreenSaverDefaults* defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
        // Register our default values
        [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                    @"http://iphone-streaming.ustream.tv/uhls/17074538/streams/live/iphone/playlist.m3u8", @"Current URL",
                                    nil]];

        _currentURL = [defaults stringForKey:@"Current URL"];
        NSLog(_currentURL);
        playerView = [[AVPlayerView alloc] initWithFrame:frame];
        AVPlayerItem* playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:_currentURL]];
        player = [AVPlayer playerWithPlayerItem:playerItem];
        [playerView setPlayer:player];
        [player play];
        [self addSubview:playerView];
    }
    return self;
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    if (!_theWindow)
    {
        NSBundle* classBundle = [NSBundle bundleForClass:[self class]];
        if (![classBundle loadNibNamed:@"Configure" owner:self topLevelObjects:nil])
        {
            NSLog( @"Failed to load configure sheet." );
            NSBeep();
        }
    }
    ScreenSaverDefaults* defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
    _currentURL = [defaults stringForKey:@"Current URL"];
    [_streamURLTextBox setStringValue:_currentURL];
    
    return _theWindow;
}


- (IBAction)saveClicked:(id)sender {
    ScreenSaverDefaults* defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
    [defaults setValue:[_streamURLTextBox stringValue] forKey:@"Current URL"];
    [defaults synchronize];
    [NSApp endSheet:_theWindow];
}
@end
