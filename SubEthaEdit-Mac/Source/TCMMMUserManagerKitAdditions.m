//  TCMMMUserManagerKitAdditions.m
//  SubEthaEdit
//
//  Created by Martin Ott on 3/19/07.

#import "TCMMMUserManagerKitAdditions.h"


// this file needs arc - add -fobjc-arc in the compile build phase
#if !__has_feature(objc_arc)
#error ARC must be enabled!
#endif


@implementation TCMMMUserManager (TCMMMUserManagerKitAdditions)

- (BOOL)validateMenuItem:(NSMenuItem *)anItem {
    SEL selector = [anItem action];
    
    if (selector == @selector(sendEmail:)) {
    
        BOOL isValid = NO;
        NSEnumerator *enumerator = [[anItem representedObject] objectEnumerator];
        NSString *userID;
        while ((userID = [enumerator nextObject])) {
            TCMMMUser *user = [self userForUserID:userID];
            if ([(NSString *)[[user properties] objectForKey:@"Email"] length] > 0) {
                isValid = YES;
            } else {
                isValid = NO;
                break;
            }
        }
        return isValid;
        
    } else if (selector == @selector(initiateAIMChat:)) {

        BOOL isValid = NO;
        NSEnumerator *enumerator = [[anItem representedObject] objectEnumerator];
        NSString *userID;
        while ((userID = [enumerator nextObject])) {
            TCMMMUser *user = [self userForUserID:userID];
            if ([(NSString *)[[user properties] objectForKey:@"AIM"] length] > 0) {
                if ([userID isEqualToString:[TCMMMUserManager myUserID]]) {
                    isValid = NO;
                    break;
                } else {
                    isValid = YES;
                }
            } else {
                isValid = NO;
                break;
            }
        }
        return isValid;    
    }
    
    return YES;
}

- (IBAction)sendEmail:(id)sender {
    NSMutableString *URLString = [NSMutableString stringWithString:@"mailto:"];
    NSEnumerator *enumerator = [[sender representedObject] objectEnumerator];
    NSString *userID;
    BOOL hasRecipient = NO;
    while ((userID = [enumerator nextObject])) {
        TCMMMUser *user = [self userForUserID:userID];
        NSString *email = [[user properties] objectForKey:@"Email"];
        [URLString appendFormat:@"%@,", email];
        hasRecipient = YES;
    }
    
    if (hasRecipient) {
        [URLString deleteCharactersInRange:NSMakeRange([URLString length] - 1, 1)];
        DEBUGLOG(@"MillionMonkeysLogDomain", DetailedLogLevel, @"URLString: %@", URLString);
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:URLString]];
    }
}

- (IBAction)initiateAIMChat:(id)sender {
    NSEnumerator *enumerator = [[sender representedObject] objectEnumerator];
    NSString *userID;
    while ((userID = [enumerator nextObject])) {
        TCMMMUser *user = [self userForUserID:userID];
        NSString *screenname = [[user properties] objectForKey:@"AIM"];
        NSString *URLString = [NSString stringWithFormat:@"aim:goim?screenname=%@", screenname];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:URLString]];
    }
}

@end
