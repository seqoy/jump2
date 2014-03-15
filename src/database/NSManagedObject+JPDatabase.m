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
#import "JPDBManagerAction.h"
#import "JPDBManagerSingleton.h"

@implementation NSManagedObject (JPDatabase)

+ (NSString *)entity {
    return NSStringFromClass(self);
}

- (void)save {
    [[JPDBManagerSingleton sharedInstance] commit];
}

- (void)delete {
    [JPDatabaseManager deleteRecord:self];
}

+ (void)deleteAll {
    [JPDatabaseManager deleteAllRecordsFromEntity:self.entity];
}

+ (instancetype)create {
    return [JPDatabaseManager createNewRecordForEntity:self.entity];
}

+ (NSArray *)all {
    return [JPDatabaseManager queryAllDataFromEntity:self.entity];
}

+ (NSArray *)allOrderedBy:(NSString *)anKey {
    return [JPDatabaseManager queryAllDataFromEntity:self.entity
                                        orderWithKey:anKey];
}

+ (NSArray *)allOrderedByKeys:(id)listOfKeys, ... {
    return [JPDatabaseManager queryAllDataFromEntity:self.entity
                                       orderWithKeys:listOfKeys, nil];
}

+ (NSUInteger)count {
    return [[self all] count];
}


@end