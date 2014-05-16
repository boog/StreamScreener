//
//  ISSLiveView.m
//  ISSLive
//
//  Created by Boog on 5/1/14.
//  Copyright (c) 2014 Bailey Carlson. All rights reserved.
//

#import "ISSLiveView.h"

static NSString * const MyModuleName = @"com.baileycarlson.ISSLive";
static NSString* const defaultStreamsKey = @"StreamURLCollection";
static NSString* const defaultMuteKey = @"MuteAudio";

@implementation ISSLiveView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self && !isPreview) {
        [self configureDefaults];
        
        long numScreens = [[NSScreen screens] count];
        if (numScreens < 2)
        {
            // Split screens
            for (NSString* url in streams)
            {
                NSURL* parsedUrl = [NSURL URLWithString:url];
                if (parsedUrl)
                {
                    [self startPlayingURL:parsedUrl withFrame:frame];
                }
            }
        }
        else
        {
            // Multimonitor, identify screen
            for (int i = 0; i < numScreens; i++)
            {
                NSScreen* screen = [[NSScreen screens] objectAtIndex:i];
                NSRect screenFrame = [screen frame];
                if (frame.origin.x >= screenFrame.origin.x &&
                    frame.origin.y >= screenFrame.origin.y &&
                    frame.origin.x + frame.size.width <= screenFrame.origin.x + screenFrame.size.width &&
                    frame.origin.y + frame.size.height <= screenFrame.origin.y + screenFrame.size.height) {
                    if (i < [streams count])
                    {
                        NSString* urlStr = [streams objectAtIndex:i];
                        NSURL* url = [NSURL URLWithString:urlStr];
                        if (url)
                        {
                            frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
                            [self startPlayingURL:url  withFrame:frame];
                        }
                    }
                }
            }
        }
        
    }
    return self;
}

- (AVPlayerView*)startPlayingURL:(NSURL*)url withFrame:(NSRect)frame
{
    // Determine player view frame
    long numPlayers = [[self subviews] count] + 1;
    long numScreens = [[NSScreen screens] count];
    
    if (numScreens == 1 && numPlayers > 1)
    {
        // Do split screen to play additional streams
        NSView* victim = [[self subviews] lastObject];
        if (victim.frame.size.width < victim.frame.size.height)
        {
            frame = CGRectMake(victim.frame.origin.x, victim.frame.origin.y, victim.frame.size.width, victim.frame.size.height / 2);
            [victim setFrame:CGRectMake(0, victim.frame.size.height / 2, victim.frame.size.width, victim.frame.size.height / 2)];
        }
        else
        {
            frame = CGRectMake(victim.frame.origin.x, victim.frame.origin.y, victim.frame.size.width / 2, victim.frame.size.height);
            [victim setFrame:CGRectMake(victim.frame.size.width / 2, 0, victim.frame.size.width / 2, victim.frame.size.height)];
        }
    }
    
    // Add player subview
    AVPlayerView* playerView = [[AVPlayerView alloc] initWithFrame:frame];
    AVPlayerItem* playerItem = [[AVPlayerItem alloc] initWithURL:url];
    AVPlayer* player = [AVPlayer playerWithPlayerItem:playerItem];
    [playerView setPlayer:player];
    bool muted = [defaults boolForKey:defaultMuteKey];
    [player setMuted:muted];
    [player setClosedCaptionDisplayEnabled:YES];
    [player play];
    [self addSubview:playerView];
    
    return playerView;
}

- (void)configureDefaults
{
    if (!streams)
    {
        // Initialize default values
        defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
        NSArray* defaultStreams = [NSArray arrayWithObjects:
                                          // ISS HDev live stream
                                          @"http://iphone-streaming.ustream.tv/uhls/17074538/streams/live/iphone/playlist.m3u8",
                                          // NASA TV
                                          @"http://iphone-streaming.ustream.tv/uhls/6540154/streams/live/iphone/playlist.m3u8", nil];
        [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                    defaultStreams, defaultStreamsKey,
                                    YES, defaultMuteKey,
                                    nil]];
        // Load list of default streams
        streams = [NSMutableArray arrayWithArray:[defaults arrayForKey:defaultStreamsKey]];
    }
}

- (BOOL)hasConfigureSheet
{
    // Allow configure window to be shown
    return YES;
}

- (NSWindow*)configureSheet
{
    if (!_theWindow)
    {
        // Create window from IB file
        NSBundle* classBundle = [NSBundle bundleForClass:[self class]];
        if (![classBundle loadNibNamed:@"Configure" owner:self topLevelObjects:nil])
        {
            NSLog( @"Failed to load configure sheet." );
            NSBeep();
        }
        [self configureDefaults];
        
    }
    
    // Set control states
    if ([[_arrayController arrangedObjects] count] == 0)
    {
        [_arrayController addObjects:streams];
        // Select first item
        [_tableView selectRowIndexes:0 byExtendingSelection:NO];
    }
    bool muted = [defaults boolForKey:defaultMuteKey];
    [_muteCheckbox setState:muted ? NSOnState : NSOffState];
    
    return _theWindow;
}

- (IBAction)saveClicked:(id)sender {
    // Save settings and dismiss configure window
    [defaults setValue:[_arrayController arrangedObjects] forKey:defaultStreamsKey];
    bool mute = [_muteCheckbox state] == NSOnState;
    [defaults setBool:mute forKey:defaultMuteKey];
    [defaults synchronize];
    [NSApp endSheet:_theWindow];
}

- (IBAction)addClicked:(id)sender {
    // Add url to stream list
    [_arrayController addObject:[_streamURLText stringValue]];
    [_streamURLText setStringValue:@""];
}

- (IBAction)removeClicked:(id)sender {
    // Remove selected url from stream list
    [_arrayController removeObjectsAtArrangedObjectIndexes:[_tableView selectedRowIndexes]];
}
@end
