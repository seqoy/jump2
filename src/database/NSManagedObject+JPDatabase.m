/*
 * Created by Paulo Oliveira at 2011. JUMP version 2, Copyright (c) 2014 - SEQOY.org and Paulo Oliveira ( http://www.seqoy.org )
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#import "NSManagedObject+JPDatabase.h"
#import "JPDBManagerDefinitions.h"
#import "JPDBManagerSingleton.h"
#import "JPDBManagerAction.h"

#define JPBuildPredicate( __anPredicate  ) \
                                va_list va_arguments;\
                                va_start(va_arguments, condition);\
                                NSPredicate *__anPredicate = [self predicateFromObject:condition arguments:va_arguments];\
                                va_end(va_arguments);

@implementation NSManagedObject (JPDatabase)

+(JPDBManagerSingleton *)manager {
    return [JPDBManagerSingleton sharedInstance];
}

+ (NSString *)entity {
    NSEntityDescription *entity = [[self manager] entity:NSStringFromClass(self)];
    if ( entity == nil ) {
        NSString *reason = [NSString stringWithFormat:@"Entity '%@' wasn't found in the Context. Maybe you're using"
                                                      @"an different class name.", entity];
        [NSException exceptionWithName:JPDBManagerActionException
                                reason:reason
                              userInfo:nil
        ];
    }

    return entity.name;
}

+ (JPDBManagerAction *)getAction {
    return [[self manager] getDatabaseActionForEntity:self.entity];
}

+(void)save {
    [[self manager] commit];
}

- (void)delete {
    [[[self class] getAction] deleteRecord:self];
}

+ (void)deleteAll {
    [[self getAction] deleteAllRecords];
}

+ (instancetype)create {
    return [[self getAction] createNewRecord];
}

+ (NSArray *)all {
    return [[[self getAction] all] run];
}

+ (NSArray *)allOrderedBy:(NSString *)anKey {
    return [[[self getAction] applyOrderKey:anKey] run];
}

+ (NSArray *)allOrderedByKeys:(id)anKey, ... {
    va_list listOfKeys;
    va_start(listOfKeys, anKey);

    NSArray *result = [[self getAction] queryAllDataOrderedByKey:anKey parameters:listOfKeys];

    va_end(listOfKeys);
    return result;
}

+ (id)query:(void (^)(JPDBManagerAction *query))configBlock {
    JPDBManagerAction *action = [self getAction];
    
    // Config the block.
    configBlock( action );
    
    // Run.
    return [action run];
}

+ (id)where:(id)condition, ... {
    JPBuildPredicate( anPredicate );

    return [[[self getAction] applyPredicate:anPredicate] run];
}

+ (id)usingOrder:(NSString*)order where:(id)condition,...  {
    JPBuildPredicate( anPredicate );

    return [[[[self getAction] applyOrderKey:order] applyPredicate:anPredicate] run];
}

+ (instancetype)find:(id)condition, ... {
    JPBuildPredicate( anPredicate );

    id data = [[[self getAction] applyPredicate:anPredicate] run];

    // If found nothing, return nil.
    if ( !data || [data count] == 0 )
        return nil;

    // Return the object.
    return data[0];
}

+ (NSUInteger)count {
    return [[self all] count];
}

+ (NSUInteger)countWhere:(id)condition, ... {
    JPBuildPredicate( anPredicate );

    return [[[[self getAction] applyPredicate:anPredicate] run] count];
}

#pragma mark - Private

+ (NSPredicate *)predicateFromDictionary:(NSDictionary *)dict {
    NSMutableArray *subpredicates = [NSMutableArray new];
    for ( id key in [dict allKeys]) {
        [subpredicates addObject:
                [NSPredicate predicateWithFormat:@"%K == %@", key, dict[key]]
        ];
    }
    return [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
}

+ (NSPredicate *)predicateFromObject:(id)condition {
    return [self predicateFromObject:condition arguments:NULL];
}

+ (NSPredicate *)predicateFromObject:(id)condition arguments:(va_list)arguments {
    if ([condition isKindOfClass:[NSPredicate class]])
        return condition;

    if ([condition isKindOfClass:[NSString class]])
        return [NSPredicate predicateWithFormat:condition arguments:arguments];

    else if ([condition isKindOfClass:[NSDictionary class]])
        return [self predicateFromDictionary:condition];

    return nil;
}

@end