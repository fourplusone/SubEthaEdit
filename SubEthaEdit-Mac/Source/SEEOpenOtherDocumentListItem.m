//  SEEBrowserOpenOtherItem.m
//  SubEthaEdit
//
//  Created by Michael Ehrmann on 27.02.14.

#if !__has_feature(objc_arc)
#error ARC must be enabled!
#endif

#import "SEEOpenOtherDocumentListItem.h"

@implementation SEEOpenOtherDocumentListItem

@dynamic uid;
@synthesize name = _name;
@synthesize image = _image;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"DOCUMENT_LIST_OPEN", @"");
		self.image = [NSImage imageNamed:@"OpenFilesSymbol"];
    }
    return self;
}

- (NSString *)uid {
	return [NSString stringWithFormat:@"com.subethaedit.%@", NSStringFromClass(self.class)];
}

- (IBAction)itemAction:(id)sender {
	[NSApp sendAction:@selector(openNormalDocument:) to:nil from:sender];
}

@end
