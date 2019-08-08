//  TCMMMOperation.h
//  SubEthaEdit
//
//  Created by Martin Ott on Fri Mar 19 2004.

#import <Foundation/Foundation.h>


extern NSString * const TCMMMOperationTypeKey;


@interface TCMMMOperation : NSObject <NSCopying>

@property (nonatomic, copy) NSString *userID;

+ (void)registerClass:(Class)aClass forOperationType:(NSString *)aType;

+ (id)operationWithDictionaryRepresentation:(NSDictionary *)aDictionary;
+ (NSString *)operationID;

- (id)initWithDictionaryRepresentation:(NSDictionary *)aDictionary;
- (NSDictionary *)dictionaryRepresentation;
- (NSString *)operationID;

@end
