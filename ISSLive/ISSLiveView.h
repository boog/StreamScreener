//
//  ISSLiveView.h
//  ISSLive
//
//  Created by Boog on 5/1/14.
//  Copyright (c) 2014 Bailey Carlson. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ISSLiveView : ScreenSaverView {
    AVPlayerView* playerView;
    AVPlayer* player;
    NSPanel *_theWindow;
    NSString* _currentURL;

    __weak NSTextField *_streamURLTextBox;
}
- (IBAction)saveClicked:(id)sender;
@property (strong) IBOutlet NSPanel *theWindow;
@property (strong) IBOutlet NSString *currentURL;
@property (weak) IBOutlet NSTextField *streamURLTextBox;
@end
