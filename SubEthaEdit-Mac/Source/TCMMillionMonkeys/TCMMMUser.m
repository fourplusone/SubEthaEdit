//  TCMMMUser.m
//  SubEthaEdit
//
//  Created by Dominik Wagner on Wed Feb 25 2004.

#import "TCMFoundation.h"
#import "TCMBencodingUtilities.h"
#import "TCMMMUserManager.h"
#import "TCMMMUser.h"

// this file needs arc - either project wide,
// or add -fobjc-arc on a per file basis in the compile build phase
#if !__has_feature(objc_arc)
#error ARC must be enabled!
#endif

NSString * const TCMMMUserPropertyKeyImageAsPNGData = @"ImageAsPNG";

NSString * const TCMMMUserWillLeaveSessionNotification = @"TCMMMUserWillLeaveSessionNotification";

void * const TCMMMUserPropertyChangeObservanceContext = (void *)&TCMMMUserPropertyChangeObservanceContext;

@interface TCMMMUser ()
@property (nonatomic, copy) NSString *userIDIncludingChangeCount;
@end

@implementation TCMMMUser

#pragma mark - User with Notification
+ (instancetype)userWithNotification:(NSDictionary *)aNotificationDict {
	if (![[aNotificationDict objectForKey:@"name"] isKindOfClass:[NSString class]] ||
		![[aNotificationDict objectForKey:@"cnt"]  isKindOfClass:[NSNumber class]] ||
		![[aNotificationDict objectForKey:@"uID"]  isKindOfClass:[NSData   class]]
	) {
		return nil;
	}
	
	NSString *userID=[NSString stringWithUUIDData:[aNotificationDict objectForKey:@"uID"]];
	if (!userID) return nil;
    TCMMMUser *user=[TCMMMUser new];
    [user setName:[aNotificationDict objectForKey:@"name"]];
    [user setUserID:userID];
    [user setChangeCount:[[aNotificationDict objectForKey:@"cnt"] longLongValue]];
	NSNumber *hue = aNotificationDict[@"hue"];
	if (hue && [hue isKindOfClass:[NSNumber class]]) {
		[user setUserHue:hue];
	}
    return user;
}


+ (id)userWithBencodedNotification:(NSData *)aData {
    NSDictionary *notificationDict=TCM_BdecodedObjectWithData(aData);
    return notificationDict?[self userWithNotification:notificationDict]:nil;
}

- (NSData *)notificationBencoded {
    return TCM_BencodedObject([self notification]);
}

- (NSDictionary *)notification {
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [self name],@"name",
        [NSData dataWithUUIDString:[self userID]],@"uID",
        [NSNumber numberWithLongLong:[self changeCount]],@"cnt",
			self.properties[@"Hue"], @"hue", // might be nil but is okay as it is last element of constructor -evildom
			nil];
}

#pragma mark
- (instancetype)init {
    if ((self=[super init])) {
        I_properties=[NSMutableDictionary new];
        I_propertiesBySessionID=[NSMutableDictionary new];
        [self updateChangeCount];
		[self registerKVO];
    }
    return self;
}

- (void)dealloc {
	[self unregisterKVO];
}

#pragma mark - KVO

- (void)registerKVO {
	[self addObserver:self forKeyPath:@"name" options:0 context:TCMMMUserPropertyChangeObservanceContext];
}

- (void)unregisterKVO {
	[self removeObserver:self forKeyPath:@"name" context:TCMMMUserPropertyChangeObservanceContext];
}


- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)aObject change:(NSDictionary *)aChange context:(void *)aContext {
    if (aContext == TCMMMUserPropertyChangeObservanceContext) {
		if ([[[self properties] objectForKey:@"HasDefaultImage"] boolValue]) { // TODO: remove when merging additions into here and use the set image methods
			[self.properties removeObjectForKey:@"Image"];
			[self.properties removeObjectForKey:TCMMMUserPropertyKeyImageAsPNGData];
		}

    } else {
        [super observeValueForKeyPath:aKeyPath ofObject:aObject change:aChange context:aContext];
    }
}

#pragma mark
- (NSString *)description {
    return [NSString stringWithFormat:@"TCMMMUser <ID:%@,Name:%@,properties:%lu,cc:%llu>",[self userID],[self name],(unsigned long)[[self properties] count], self.changeCount];
}

#pragma mark
- (BOOL)isMe {
    return [[self userID] isEqualToString:[TCMMMUserManager myUserID]];
}

#pragma mark - Properties
- (NSMutableDictionary *)properties {
    return I_properties;
}

- (void)setProperties:(NSMutableDictionary *)aDictionary {
     I_properties = [aDictionary mutableCopy];
}

#pragma mark - Change Count
- (void)updateChangeCount {
    [self setChangeCount:(long long)[NSDate timeIntervalSinceReferenceDate]];
	self.userIDIncludingChangeCount = nil;
}

- (NSString *)userIDIncludingChangeCount {
	if (!_userIDIncludingChangeCount) {
		_userIDIncludingChangeCount = [NSString stringWithFormat:@"%@+%lld",self.userID,self.changeCount];
	}
	return _userIDIncludingChangeCount;
}

#pragma mark - Session
- (void)joinSessionID:(NSString *)aSessionID {
    if (!([I_propertiesBySessionID objectForKey:aSessionID]==nil)) DEBUGLOG(@"MillionMonkeysLogDomain", DetailedLogLevel, @"User already joined");
    [I_propertiesBySessionID setObject:[NSMutableDictionary dictionary] forKey:aSessionID];
}

- (void)leaveSessionID:(NSString *)aSessionID {
    [[NSNotificationCenter defaultCenter] postNotificationName:TCMMMUserWillLeaveSessionNotification object:self userInfo:[NSDictionary dictionaryWithObject:aSessionID forKey:@"SessionID"]];
    [I_propertiesBySessionID removeObjectForKey:aSessionID];
}

- (NSMutableDictionary *)propertiesForSessionID:(NSString *)aSessionID {
    return [I_propertiesBySessionID objectForKey:aSessionID];
}

#pragma mark
- (void)updateWithUser:(TCMMMUser *)aUser {
    NSParameterAssert([[aUser userID] isEqualTo:[self userID]]);
    [self setProperties:[aUser properties]];
    [self setName:[aUser name]];
    [self setChangeCount:[aUser changeCount]];
}

#pragma mark
- (NSString *)shortDescription {
    NSMutableArray *additionalData = [NSMutableArray arrayWithObject:[self userID]];
    if ([[self properties] objectForKey:@"AIM"] && [(NSString*)[[self properties] objectForKey:@"AIM"] length]>0) 
        [additionalData addObject:[NSString stringWithFormat:@"aim:%@",[[self properties] objectForKey:@"AIM"]]];
    if ([[self properties] objectForKey:@"Email"] && [(NSString*)[[self properties] objectForKey:@"Email"] length] >0) 
        [additionalData addObject:[NSString stringWithFormat:@"mail:%@",[[self properties] objectForKey:@"Email"]]];
    return [NSString stringWithFormat:@"%@ (%@)",[self name],[additionalData componentsJoinedByString:@", "]];
}


#pragma mark - User Class methods
+ (instancetype)userWithBencodedUser:(NSData *)aData {
    NSDictionary *userDict = TCM_BdecodedObjectWithData(aData);
    return [self userWithDictionaryRepresentation:userDict];
}

+ (instancetype)userWithDictionaryRepresentation:(NSDictionary *)aRepresentation {
    // bail out for malformed data
    if (![[aRepresentation objectForKey:@"name"] isKindOfClass:[NSString class]] ||
        ![[aRepresentation objectForKey:@"uID"] isKindOfClass:[NSData class]] ||
        ![[aRepresentation objectForKey:@"cnt"] isKindOfClass:[NSNumber class]] ||
        ([aRepresentation objectForKey:@"PNG"] && ![[aRepresentation objectForKey:@"PNG"] isKindOfClass:[NSData class]]) ||
        ([aRepresentation objectForKey:@"hue"] && ![[aRepresentation objectForKey:@"hue"] isKindOfClass:[NSNumber class]]))
    {
        return nil;
    }
    
    TCMMMUser *user = [[TCMMMUser alloc] init];
    [user setName:[aRepresentation objectForKey:@"name"]];
	NSString *userID = [NSString stringWithUUIDData:[aRepresentation objectForKey:@"uID"]];
	if (!userID) return nil;
    [user setUserID:userID];
    
    [user setChangeCount:[[aRepresentation objectForKey:@"cnt"] longLongValue]];
    
    NSString *string = [aRepresentation objectForKey:@"AIM"];
    if (string == nil) string = @"";
    else if (![string isKindOfClass:[NSString class]])  return nil;
    [[user properties] setObject:string forKey:@"AIM"];
    
    string = [aRepresentation objectForKey:@"mail"];
    if (string == nil) string = @"";
    else if (![string isKindOfClass:[NSString class]]) return nil;
    [[user properties] setObject:string forKey:@"Email"];
    
    [user setUserHue:[aRepresentation objectForKey:@"hue"]];

	if ([aRepresentation[@"hDI"] boolValue]) {
		user.properties[@"HasDefaultImage"] = @(YES);
	} else {
		NSData *pngData = [aRepresentation objectForKey:@"PNG"];
		[user setImageWithPNGData:pngData];
	}
    return user;
}

#pragma mark - Image
- (void)setImageWithPNGData:(NSData *)aPNGData {
	if (aPNGData &&
		aPNGData.length > 0) {
		NSString *md5String = [aPNGData md5String];
		static NSArray *emptyImageHashes = nil;
		if (emptyImageHashes == nil) {
			emptyImageHashes = @[
								 @"f5053bc845cf64013f86610e5c47baaf", // SubEthaEdit old
								 @"7d4a805849dc48827b2bc860431b734b", // Coda old also 2.0.14 on first launch
								 @"5d866ffe7b8695d8804daa1f306de11f", // SubEtha
								 @"11ea6051b3cd2642fea228b0d269a042", // Coda 2.0.14 by Dom
								 ];
		}
//		NSLog(@"%s md5:%@ userName:%@",__FUNCTION__,md5String,self.name);

//		if ([md5String isEqualToString:@"781adb20200190b6d278fe74af29768b"] || // Michis Coda
//			[md5String isEqualToString:@"5da9c1ca2476d61407bc9c33ad9da360"]) { // Marcels Coda
//
//			NSImage *image = [[NSImage alloc] initWithData:aPNGData];
//			NSLog(@"%@ - data: %@", image, aPNGData);
//
//			static NSInteger fileCount = 0;
//			NSString *tempFilePath = NSTemporaryDirectory();
//			fileCount++;
//			NSString *pngFilePath = [tempFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"avatar%ld.png", fileCount]];
//			NSString *tiffFilePath = [tempFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"avatar%ld.tif", fileCount]];
//
//			[aPNGData writeToFile:pngFilePath atomically:YES];
//			[[image TIFFRepresentation] writeToFile:tiffFilePath atomically:YES];
//			[[NSWorkspace sharedWorkspace]  selectFile:tempFilePath inFileViewerRootedAtPath:@""];
//		}

		if (![emptyImageHashes containsObject:md5String]) {
			NSImage *image = [[NSImage alloc] initWithData:aPNGData];
			if (image && image.size.width == 1 && image.size.height == 64.0) { // CODA has a bug if the user has no image. But it always returns a 1x64 points image.
				[self.properties setObject:@(YES) forKey:@"HasDefaultImage"];
			} else {
				[self.properties setObject:aPNGData forKey:TCMMMUserPropertyKeyImageAsPNGData];
			}
		} else {
			[self.properties setObject:@(YES) forKey:@"HasDefaultImage"];
		}
		// when asking for the image it will be created from the data
		// if there is no image and no data the default image will be set automatically and the default image flag will be turned on

	}
}

#pragma mark
- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([self userID]) [dict setObject:[NSData dataWithUUIDString:[self userID]] forKey:@"uID"];
    if ([self name]) [dict setObject:[self name] forKey:@"name"];
    if ([[self properties] objectForKey:@"AIM"]) [dict setObject:[[self properties] objectForKey:@"AIM"] forKey:@"AIM"];
    if ([[self properties] objectForKey:@"Email"]) [dict setObject:[[self properties] objectForKey:@"Email"] forKey:@"mail"];
    if ([[self properties] objectForKey:TCMMMUserPropertyKeyImageAsPNGData]) [dict setObject:[[self properties] objectForKey:TCMMMUserPropertyKeyImageAsPNGData] forKey:@"PNG"];
    if ([[self properties] objectForKey:@"Hue"]) [dict setObject:[[self properties] objectForKey:@"Hue"] forKey:@"hue"];
	[dict setObject:[[self properties] objectForKey:@"HasDefaultImage"]?:@(NO) forKey:@"hDI"];
    [dict setObject:[NSNumber numberWithLong:[self changeCount]] forKey:@"cnt"];
    return dict;
}

- (NSData *)userBencoded {
    NSDictionary *user = [self dictionaryRepresentation];
    return TCM_BencodedObject(user);
}

#pragma mark
- (void)setUserHue:(NSNumber *)aHue {
    if (aHue) {
        [[self properties] setObject:aHue forKey:@"Hue"];
        [[self properties] removeObjectForKey:@"ChangeColor"];
		if (self.isMe) {
			// only update my own change count on this setter
			[self updateChangeCount];
		}
    }
}

- (NSNumber *)userHue {
	NSNumber *result = self.properties[@"Hue"];
	return result;
}

#pragma mark
- (NSString *)aim {
    NSString *result = [[self properties] objectForKey:@"AIM"];
    if (result && [result length]>0) return result;
    else return nil;
}
- (NSString *)email {
    NSString *result = [[self properties] objectForKey:@"Email"];
    if (result && [result length]>0) return result;
    else return nil;
}

@end
