//  TCMMMLogStatisticsEntry.h
//  SubEthaEdit
//
//  Created by Dominik Wagner on 21.08.07.

#import <Cocoa/Cocoa.h>

@class TCMMMUser, TCMMMLoggedOperation, TCMMMLoggingState;

@interface TCMMMLogStatisticsEntry : NSObject {
    TCMMMUser *user;
    NSDate *lastActivity;
    BOOL isInside;
    unsigned long operationCount;
    unsigned long deletedCharacters;
    unsigned long insertedCharacters;
    unsigned long selectedCharacters;
}

@property (nonatomic, weak) TCMMMLoggingState *loggingState;

- (id)initWithMMUser:(TCMMMUser *)aUser;
- (void)updateWithOperation:(TCMMMLoggedOperation *)anOperation;
- (unsigned long)operationCount;
- (unsigned long)deletedCharacters;
- (unsigned long)insertedCharacters;
- (unsigned long)selectedCharacters;
- (TCMMMUser *)user;
- (NSDate *)dateOfLastActivity;
- (BOOL)isInside;
@end
