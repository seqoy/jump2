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
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 * This category extends NSManagedObject adding an set of convenient helper methods for basic operations.
 * They are wrappers to the JPDBManagerAction class. But doesn't implement all of then.
 * You should use JPDBManagerAction for more powerful and complex operations.
 */
@interface NSManagedObject (JPDatabase)

/**
 * Returns the entity name of the receiver.
 */
+(NSString *)entity;

/**
 * Count how many objcets this entity has.
 */
+ (NSUInteger)count;

//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// ////
#pragma mark -
#pragma mark Query All Data Methods.
//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// ////
/** @name Query All Data Methods
 */
///@{

/**
 * Query all data of this Entity.
 * @return One unordered collection with queried data Objects.
 */
+ (NSArray *)all;

/**
 * Query all data of this Entity.
 * @param anKey One Key attribute to sort the result.
 * @return One unordered collection with queried data Objects.
 */
+ (NSArray *)allOrderedBy:(NSString*)anKey;

/**
 * Query all data of this Entity.
 * @param listOfKeys Accept one or more Key Attributes to sort the result. Doesn't forget to terminate the list with an 'nil' token.
 * @return One unordered collection with queried data Objects.
 */
+ (NSArray *)allOrderedByKeys:(id)listOfKeys, ... NS_REQUIRES_NIL_TERMINATION;

///@}
//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// ////
#pragma mark -
#pragma mark Remove Data Methods.
//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// ////
/** @name Remove Data Methods
 */
///@{

/**
* Delete this object from his Entity on the Database.
*/
- (void)delete;

/**
 * Delete all objects from this Entity.
 * This could be a consuming time operation on large databases.
 */
+ (void)deleteAll;

///@}
//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// ////
#pragma mark -
#pragma mark Write Data Methods.
//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// ////
/** @name Write Data Methods
 */
///@{

/**
 * Create a new instance of this Entity.
 * @return New empty Record.
 */
+ (instancetype)create;

/**
 * Commit unsaved changes on pending objects of this instance.
 * An JPDBManagerErrorNotification notification will be posted in any error.
 */
- (void)save;

//@}


@end