//  SEEPlainTextEditorScrollView.m
//  SubEthaEdit
//
//  Created by Dominik Wagner on Thu Apr 15 2004.
//  Recreated by Michael Ehrmannn on Tue Jan 21 2014
//

#import "SEEPlainTextEditorScrollView.h"

#if !__has_feature(objc_arc)
#error ARC must be enabled!
#endif

void * const SEEScrollViewOverlayObservingContext = (void *)&SEEScrollViewOverlayObservingContext;

@implementation SEEPlainTextEditorScrollView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self installKVO];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
		[self installKVO];
    }
    return self;
}

- (void)dealloc
{
	[self removeKVO];
}

- (void)installKVO {
	[self addObserver:self forKeyPath:@"topOverlayHeight" options:0 context:SEEScrollViewOverlayObservingContext];
	[self addObserver:self forKeyPath:@"bottomOverlayHeight" options:0 context:SEEScrollViewOverlayObservingContext];
}

- (void)removeKVO {
	[self removeObserver:self forKeyPath:@"topOverlayHeight" context:SEEScrollViewOverlayObservingContext];
	[self removeObserver:self forKeyPath:@"bottomOverlayHeight" context:SEEScrollViewOverlayObservingContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == SEEScrollViewOverlayObservingContext) {
		[self tile];
		[self updateTrackingAreas];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)tile {
    // Let the superclass do most of the work.
    [super tile];
	//	return;
	
    if ([self hasVerticalScroller]) {
        NSScroller *verticalScroller = self.verticalScroller;
        NSRect verticalScrollerFrame = verticalScroller.frame;

        verticalScrollerFrame.size.height -= self.topOverlayHeight + self.bottomOverlayHeight;
        verticalScrollerFrame.origin.y    += self.topOverlayHeight;

        verticalScroller.frame = verticalScrollerFrame;
    }

	if ([self hasHorizontalScroller]) {
		NSScroller *horizontalScroller = self.horizontalScroller;
		NSRect horizontalScrollerFrame = horizontalScroller.frame;

		horizontalScrollerFrame.origin.y -= self.bottomOverlayHeight;
		horizontalScroller.frame = horizontalScrollerFrame;
	}
}


- (void)setTopOverlayHeightNumber:(NSNumber *)heightNumber {
	self.topOverlayHeight = heightNumber.doubleValue;
}

- (void)setBottomOverlayHeightNumber:(NSNumber *)heightNumber {
	self.bottomOverlayHeight = heightNumber.doubleValue;
}

- (NSSize)SEE_effectiveContentSize {
    NSSize size = self.contentSize;
    NSEdgeInsets insets = self.contentView.contentInsets;
    size.width -= insets.left + insets.right;
    size.height -= insets.top + insets.bottom;
    return size;
}

- (void)scrollClipView:(NSClipView *)clipView toPoint:(NSPoint)point {
    NSRect bounds = clipView.bounds;
    
    if (point.x == 0 &&
        bounds.origin.x < 0 &&
        clipView.contentInsets.left == -bounds.origin.x) {
        // in this case keep the bounds at the edge they are
        // looks like a terrible fix, because it is. It would be nicer to find the underlying reason,
        // e.g. the offender that ignores the contentInset / left rule thickness here
        point.x = bounds.origin.x;
    }
    [super scrollClipView:clipView toPoint:point];
}

#pragma mark - State Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
//	NSLog(@"%s - %d : %@", __FUNCTION__, __LINE__, self);
	[super encodeRestorableStateWithCoder:coder];
}

- (void)restoreStateWithCoder:(NSCoder *)coder {
//	NSLog(@"%s - %d : %@", __FUNCTION__, __LINE__, self);
	[super restoreStateWithCoder:coder];
}

@end
