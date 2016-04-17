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
    if (self) {
        [self configureDefaults];
        
        long numScreens = [[NSScreen screens] count];
        if (isPreview) {
            numScreens = 1;
            [defaults setBool:YES forKey:defaultMuteKey];
        }
        if (numScreens < 2)
        {
            frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            // Split screens
            for (NSString* url in streams)
            {
                NSURL* parsedUrl = [NSURL URLWithString:url];
                if (parsedUrl)
                {
                    [self startPlayingURL:parsedUrl withFrame:frame splitScreen:YES];
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
                    screenFrame = CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height);
                    if (i == 0)
                    {
                        // Main monitor, fullscreen
                        NSString* urlStr = [streams objectAtIndex:i];
                        NSURL* url = [NSURL URLWithString:urlStr];
                        if (url)
                        {
                            [self startPlayingURL:url withFrame:screenFrame splitScreen:NO];
                        }
                    }
                    else
                    {
                        [streams removeObjectAtIndex:0];
                        // Secondary monitors, split screens
                        for (NSString* url in streams)
                        {
                            NSURL* parsedUrl = [NSURL URLWithString:url];
                            if (parsedUrl)
                            {
                                [self startPlayingURL:parsedUrl withFrame:screenFrame splitScreen:YES];
                            }
                        }
                    }
                }
            }
        }
        
    }
    return self;
}

- (AVPlayerView*)startPlayingURL:(NSURL*)url withFrame:(NSRect)frame splitScreen:(BOOL)isSplit
{
//    NSLog(@"origin-x:%f", frame.origin.x);
//    NSLog(@"origin-y:%f", frame.origin.y);
//    NSLog(@"height:%f", frame.size.height);
//    NSLog(@"width:%f", frame.size.width);
    if ([[self subviews] count] > 0)
    {
        // Do split screen to play additional streams
        NSView* victim = nil;
        CGFloat max = 0;
        // Vicitimize biggest view
        for (NSView* view in [self subviews]) {
            CGFloat area = view.frame.size.width * view.frame.size.height;
            if (area > max) {
                victim = view;
                max = area;
            }
        }
        CGFloat aspectRatio = 1.8; // ~16:9
        if (victim.frame.size.width / victim.frame.size.height < aspectRatio)
        {
            // Cut in half vertically
            CGFloat halfHeight = floor(victim.frame.size.height / 2.0);
            frame = CGRectMake(victim.frame.origin.x, victim.frame.origin.y, victim.frame.size.width, halfHeight);
            [victim setFrame:CGRectMake(victim.frame.origin.x, halfHeight, victim.frame.size.width, victim.frame.size.height / 2)];
            NSLog(@"Set height / 2: %f", halfHeight);
        }
        else
        {
            // Cut in half horizontally
            CGFloat halfWidth = floor(victim.frame.size.width / 2.0);
            frame = CGRectMake(victim.frame.origin.x, victim.frame.origin.y, halfWidth, victim.frame.size.height);
            [victim setFrame:CGRectMake(halfWidth, victim.frame.origin.y, halfWidth, victim.frame.size.height)];
            NSLog(@"Set width / 2: %f", halfWidth);
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
        // Enable Drag-drop
        [_tableView registerForDraggedTypes: [NSArray arrayWithObject: @"public.text"]];
    }
    bool muted = [defaults boolForKey:defaultMuteKey];
    [_muteCheckbox setState:muted ? NSOnState : NSOffState];
    
    return _theWindow;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView
                validateDrop:(id<NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)operation {
    BOOL canDrag = row >= 0;
    if (canDrag) {
        return NSDragOperationMove;
    }else {
        return NSDragOperationNone;
    }
}

- (BOOL)tableView:(NSTableView *)aTableView
       acceptDrop:(id<NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)operation {

    NSPasteboard *p = [info draggingPasteboard];
    NSString *rowIndex = [p stringForType:@"public.text"];
    NSInteger index = [rowIndex integerValue];
    
    NSLog(@"target:%d", index);
    NSLog(@"dest:%d", row);
    NSArray* items = [_arrayController arrangedObjects];
    id target = [items objectAtIndex:index];
    NSLog(@"url:%@", target);
    if (row >= [items count]) {
        NSLog(@"Index too big");
        row = [items count] - 1;
    }
    
    [_arrayController removeObject:target];
    [_arrayController insertObject:target atArrangedObjectIndex:row];
    [aTableView reloadData];

    return YES;
}

- (id<NSPasteboardWriting>)tableView:(NSTableView *)tableView
              pasteboardWriterForRow:(NSInteger)row {
    NSString *identifier = [@(row) stringValue];
    
    NSPasteboardItem *pboardItem = [[NSPasteboardItem alloc] init];
    [pboardItem setString:identifier forType: @"public.text"];
    
    return pboardItem;
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
