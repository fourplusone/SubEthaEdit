//  EditPreferences.m
//  SubEthaEdit
//
//  Created by Martin Ott on Mon Mar 29 2004.

#import "EditPreferences.h"
#import "DocumentModeManager.h"
#import "EncodingManager.h"

// this file needs arc - add -fobjc-arc in the compile build phase
#if !__has_feature(objc_arc)
#error ARC must be enabled!
#endif

@implementation EditPreferences

- (NSImage *)icon {
    return [NSImage imageNamed:@"EditPrefs"];
}

- (NSString *)iconLabel {
    return NSLocalizedString(@"EditPrefsIconLabel", @"Label displayed below edit icon and used as window title.");
}

- (NSString *)identifier {
    return @"de.codingmonkeys.subethaedit.preferences.edit";
}

- (NSString *)mainNibName {
    return @"EditPrefs";
}

- (void)mainViewDidLoad {
    // Initialize user interface elements to reflect current preference settings
    [O_encodingPopUpButton setEncoding:NoStringEncoding defaultEntry:YES modeEntry:NO lossyEncodings:nil];
    [self changeMode:O_modePopUpButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentModeListChanged:) name:@"DocumentModeListChanged" object:nil];
    
}

- (void)documentModeListChanged:(NSNotification *)aNotification {
    [self performSelector:@selector(changeMode:) withObject:O_modePopUpButton afterDelay:.2];
}

- (IBAction)validateDefaultsState:(id)aSender {
    DocumentMode *baseMode=[[DocumentModeManager sharedInstance] baseMode];
    DocumentMode *selectedMode=[O_modeController content];
    [O_viewController setContent:([O_viewDefaultButton state]==NSOnState)?baseMode:selectedMode];
    [O_editController setContent:([O_editDefaultButton state]==NSOnState)?baseMode:selectedMode];
    [O_fileController setContent:([O_fileDefaultButton state]==NSOnState)?baseMode:selectedMode];
}

- (IBAction)changeMode:(id)aSender {
    DocumentMode *newMode=[aSender selectedMode];
    [O_modeController setContent:newMode];
    [self validateDefaultsState:aSender];
}

- (void)didUnselect {
    // Save preferences
}

- (IBAction)applyToOpenDocuments:(id)aSender {
    // make sure changes are saved first
    [O_viewController commitEditing];
    [O_editController commitEditing];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DocumentModeApplyEditPreferencesNotification object:[O_modeController content]];
}

@end
