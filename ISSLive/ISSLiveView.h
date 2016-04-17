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

@interface ISSLiveView : ScreenSaverView <NSTableViewDataSource> {
    ScreenSaverDefaults* defaults;
    NSMutableArray* streams;
}

- (IBAction)addClicked:(id)sender;
- (IBAction)saveClicked:(id)sender;
- (IBAction)removeClicked:(id)sender;

@property (weak) IBOutlet NSButton *muteCheckbox;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *streamURLText;
@property (strong) IBOutlet NSPanel *theWindow;
@property (strong) IBOutlet NSArrayController *arrayController;
@end
