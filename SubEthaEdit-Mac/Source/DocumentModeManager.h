//  DocumentModeManager.h
//  SubEthaEdit
//
//  Created by Dominik Wagner on Mon Mar 22 2004.

#import <Cocoa/Cocoa.h>
#import "DocumentMode.h"
#import "SEEStyleSheet.h"

//#define MODE_EXTENSION [[NSWorkspace sharedWorkspace] preferredFilenameExtensionForType:@"de.codingmonkeys.subethaedit.seemode"]
#define MODE_EXTENSION @"seemode"
#define BASEMODEIDENTIFIER @"SEEMode.Base"
#define AUTOMATICMODEIDENTIFIER @"SEEMode.Automatic"


@interface DocumentModePopUpButton : NSPopUpButton {
    BOOL I_automaticMode;
}

- (void)setHasAutomaticMode:(BOOL)aFlag;
- (DocumentMode *)selectedMode;
- (void)setSelectedMode:(DocumentMode *)aMode;
- (NSString *)selectedModeIdentifier;
- (void)setSelectedModeIdentifier:(NSString *)aModeIdentifier;
- (void)documentModeListChanged:(NSNotification *)notification;
@end

@interface DocumentModeMenu : NSMenu {
    SEL I_action;
    BOOL I_alternateDisplay;
}
- (void)configureWithAction:(SEL)aSelector alternateDisplay:(BOOL)aFlag;
@end

@interface DocumentModeManager : NSObject <NSAlertDelegate> {
    NSMutableDictionary *I_modeBundles;
    NSMutableDictionary *I_documentModesByIdentifier;
    NSMutableDictionary *I_documentModesByName;

	NSRecursiveLock *I_documentModesByIdentifierLock; // (ifc - experimental locking for thread safety... TCM are putting in a real fix)

	NSMutableArray      *I_modeIdentifiersTagArray;
	
	// style sheet management
	NSMutableDictionary *I_styleSheetPathsByName;
	NSMutableDictionary *I_styleSheetsByName;
}

@property (nonatomic, strong, readonly) NSArray *allPathExtensions;
@property (nonatomic, strong) NSMutableArray *modePrecedenceArray;

+ (DocumentModeManager *)sharedInstance;
+ (DocumentMode *)baseMode;
+ (NSString *)xmlFileRepresentationOfAllStyles;
+ (NSString *)defaultStyleSheetName;

- (DocumentMode *)baseMode;
- (DocumentMode *)modeForNewDocuments;
- (DocumentMode *)documentModeForIdentifier:(NSString *)anIdentifier;
- (DocumentMode *)documentModeForPath:(NSString *)path withContentData:(NSData *)content;
- (DocumentMode *)documentModeForPath:(NSString *)path withContentString:(NSString *)contentString;
- (DocumentMode *)documentModeForName:(NSString *)aName;
- (NSArray *)allLoadedDocumentModes;
- (NSString *)documentModeIdentifierForTag:(int)aTag;
- (BOOL)documentModeAvailableModeIdentifier:(NSString *)anIdentifier;
- (int)tagForDocumentModeIdentifier:(NSString *)anIdentifier;
- (NSDictionary *)availableModes;

- (NSMutableArray *)reloadPrecedences;
- (void)revalidatePrecedences;

@property (readonly) NSDictionary *changedScopeNameDict;
- (void)reloadAllStyles;
- (SEEStyleSheet *)styleSheetForName:(NSString *)aStyleSheetName;
- (NSArray *)allStyleSheetNames;
- (void)saveStyleSheet:(SEEStyleSheet *)aStyleSheet;
- (SEEStyleSheet *)duplicateStyleSheet:(SEEStyleSheet *)aStyleSheet;
- (void)revealStyleSheetInFinder:(SEEStyleSheet *)aStyleSheet;
- (NSURL *)customStyleSheetFolderURL;

- (IBAction)reloadDocumentModes:(id)aSender;
- (void)revealModeInFinder:(DocumentMode *)aMode jumpIntoContentFolder:(BOOL)aJumpIntoContentFolder;
- (NSURL *)urlForWritingModeWithName:(NSString *)aModeName;

@end
