//  TCMMMMessage.m
//  SubEthaEdit
//
//  Created by Martin Ott on Fri Mar 19 2004.

#import "TCMMMMessage.h"
#import "TCMMMOperation.h"

@implementation TCMMMMessage

+ (instancetype)messageWithDictionaryRepresentation:(NSDictionary *)aDictionary {
    return [[TCMMMMessage alloc] initWithDictionaryRepresentation:aDictionary];
}

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)aDictionary {
    self = [super init];
    if (self) {
        //NSLog(@"initWithDictionary: %@",aDictionary);
        I_numberOfClientMessages = [[aDictionary objectForKey:@"#C"] longLongValue];
        I_numberOfServerMessages = [[aDictionary objectForKey:@"#S"] longLongValue];

        I_operation = [TCMMMOperation operationWithDictionaryRepresentation:[aDictionary objectForKey:@"op"]];
        NSAssert(I_operation,@"operation was nill");
        //NSLog(@"message: %@",[self description]);
    }
    return self;
}

- (instancetype)initWithOperation:(TCMMMOperation *)anOperation numberOfClient:(NSInteger)aClientNumber numberOfServer:(NSInteger)aServerNumber {
    self = [super init];
    if (self) {
        I_numberOfClientMessages = aClientNumber;
        I_numberOfServerMessages = aServerNumber;
        [self setOperation:anOperation];
    }
    return self;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"\nstate: (%qi, %qi)\nop: %@", (long long)I_numberOfClientMessages, (long long)I_numberOfServerMessages, [I_operation description]];
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *representation = [NSMutableDictionary dictionary];
    [representation setObject:[[self operation] dictionaryRepresentation]
                       forKey:@"op"];
    [representation setObject:[NSNumber numberWithLongLong:I_numberOfClientMessages] forKey:@"#C"];
    [representation setObject:[NSNumber numberWithLongLong:I_numberOfServerMessages] forKey:@"#S"];
    return representation;
}

- (void)setOperation:(TCMMMOperation *)anOperation {
    I_operation = [anOperation copy];
}

- (TCMMMOperation *)operation {
    return I_operation;
}

- (NSInteger)numberOfClientMessages {
    return I_numberOfClientMessages;
}

- (NSInteger)numberOfServerMessages {
    return I_numberOfServerMessages;
}

- (void)incrementNumberOfClientMessages {
    I_numberOfClientMessages++;
}

- (void)incrementNumberOfServerMessages {
    I_numberOfServerMessages++;
}

@end
