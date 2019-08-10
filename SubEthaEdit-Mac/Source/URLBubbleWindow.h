//  URLBubbleWindow.h
//  SubEthaEdit
//
//  Created by dom on 13.07.09.

#import <Cocoa/Cocoa.h>
#import "MAAttachedWindow.h"


@interface URLBubbleWindow : MAAttachedWindow {
    NSURL *I_URLToOpen;
}

@property (readwrite, strong) IBOutlet NSView *openURLViewOutlet;

+ (URLBubbleWindow *)sharedURLBubbleWindow;

- (instancetype)initAsBubble;

- (IBAction)openURLAction:(id)aSender;
- (IBAction)hideWindow:(id)aSender;
- (void)hideIfNecessary;

- (void)setURLToOpen:(NSURL *)inURL;
- (void)setPosition:(NSPoint)inPosition inWindow:(NSWindow *)inWindow;
- (void)setVisible:(BOOL)inVisible animated:(BOOL)inAnimated;

@end
