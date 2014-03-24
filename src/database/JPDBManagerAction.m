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
#import "JPCore.h"
#import "JPDBManagerAction.h"
#import "JPDBManager.h"
#import "NSMutableArray+ObjectiveSugar.h"

@interface JPDBManagerAction() {
    NSEntityDescription *_entity;
}
@end

@implementation JPDBManagerAction


#pragma mark - Init Methods.
+ (id)initWithEntityName:(NSString *)anEntityName andManager:(JPDBManager *)anManager {
	return [[self alloc] initWithEntityName:anEntityName andManager:anManager];
}

- (id)initWithEntityName:(NSString *)anEntityName andManager:(JPDBManager *)anManager {
	self = [super init];
	if (self != nil) {

		// Initializations.
		self.manager = anManager;

        // Apply the entity.
        [self applyEntity:anEntityName];

        // Reset default values.
        [self resetDefaultValues];
	}
	return self;
}


#pragma mark - Getters and Setters.

-(void)setAscendingOrder:(BOOL)newValue {
	// If no changes, do nothing..
	if ( self.ascendingOrder == newValue )
		return;

	// Sorter descriptors can't be changed once it's created, so we'll allocate everybody again.
	NSMutableArray *newSorters = [NSMutableArray arrayWithCapacity:[self.sortDescriptors count]];

	// Recreate...
	for ( NSSortDescriptor *sorter in self.sortDescriptors) {
		
		// Alloc new sorter with same values except order and store it.
		[newSorters addObject:[NSSortDescriptor sortDescriptorWithKey:sorter.key 
															ascending:newValue 
															 selector:sorter.selector]];
	}
	
	// Store new sorters.
	self.sortDescriptors = newSorters;
	
	// New General value.
	_ascendingOrder = newValue;
}




#pragma mark - Private Methods.
-(JPDBManager*)getManagerOrDie {
	if ( ! _manager) {
		[NSException raise:JPDBManagerActionException
					format:@"You must define an Database Manager before perform any action."];
		return nil;
	}
	
	// Return instance.
	return _manager;
}
 
-(BOOL)existEntity:(NSString*)anEntityName {
	return [[self getManagerOrDie] existEntity:anEntityName];
}
-(BOOL)existAttribute:(NSString*)anAttributeName inEntity:(NSString*)anEntityName {
	return [[self getManagerOrDie] existAttribute:anAttributeName inEntity:anEntityName];
}
-(void)throwExceptionWithCause:(NSString*)anCause {
	[NSException raise:JPDBManagerActionException format:@"%@", anCause];
}




#pragma mark - Fetch Data Methods With Custom Predicates.
- (id)queryWithPredicate:(NSPredicate *)anPredicate {
	return [self queryWithPredicate:anPredicate orderByKey:nil ];
}

- (id)queryWithPredicate:(NSPredicate *)anPredicate orderByKey:(id)anKey {
	return [self queryWithPredicate:anPredicate orderedByKeys:anKey, nil];
}

- (id)queryWithPredicate:(NSPredicate *)anPredicate orderedByKeys:(id)listOfKeys, ... {
	
	// Create one Array of Sort Descriptors.
	JPDatabaseCreateArrayOfKeys( listOfKeys, arrayOfSorter, self.entityName );
	
	//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// 
	
	// Call Next Processing.
	return [self queryWithPredicate:anPredicate sortDescriptors:arrayOfSorter];
	
}

- (id)queryWithPredicate:(NSPredicate *)anPredicate sortDescriptors:(NSArray *)sortDescriptors {
	return [self queryWithFetchTemplate:nil andVariables:nil sortDescriptors:sortDescriptors predicate:anPredicate];
	
}




#pragma mark - Fetch Data Methods.
- (id)queryAllData {
	return [self queryWithFetchTemplate:nil ];
}

- (id)queryAllDataOrderedByKey:(NSString *)anKey {
	return [self queryAllDataOrderedByKey:anKey parameters:nil];
}

- (id)queryAllDataOrderedByKeys:(NSString*)anKey, ... {

    id result;

    va_list args;
    va_start(args, anKey);
    result = [self queryAllDataOrderedByKey:anKey parameters:args];
    va_end(args);

    return result;
}

- (id)queryAllDataOrderedByKey:(NSString *)anKey parameters:(va_list)arguments {
    NSMutableArray *sorters = [[NSMutableArray alloc] init];
    NSString *attribute;

    for (attribute  = anKey;
         attribute != nil;
         attribute  = arguments != nil ? va_arg(arguments, NSString*) : nil )

    {
        if ( ![self existAttribute:attribute inEntity:self.entityName] )
        {
            [self throwExceptionWithCause:NSFormatString( @"The attribute '%@' doesn't exist on '%@' Entity.", attribute, self.entityName)];
        }
        [sorters addObject:[[NSSortDescriptor alloc] initWithKey:attribute
                                                       ascending:self.ascendingOrder]];
    }

    // Call Next Processing.
    return [self queryWithFetchTemplate:nil andVariables:nil sortDescriptors:sorters];
}


- (id)queryWithFetchTemplate:(NSString *)anFetchName {
	return [self queryWithFetchTemplate:anFetchName ordereredByKey:nil];
}

- (id)queryWithFetchTemplate:(NSString *)anFetchName ordereredByKey:(id)anKey {
	return [self queryWithFetchTemplate:anFetchName orderedByKeys:anKey, nil];
}

- (id)queryWithFetchTemplate:(NSString *)anFetchName orderedByKeys:(id)listOfKeys, ... {

	// Create one Array of Sort Descriptors.
	JPDatabaseCreateArrayOfKeys( listOfKeys, arrayOfSorter, self.entityName );
	
	//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// 
	
	// Call Next Processing.
	return [self queryWithFetchTemplate:anFetchName andVariables:nil sortDescriptors:arrayOfSorter];
}

- (id)queryWithFetchTemplate:(NSString *)anFetchName andVariables:(NSDictionary *)anDictionary {
	return [self queryWithFetchTemplate:anFetchName andVariables:anDictionary sortDescriptors:nil ];
}

- (id)queryWithFetchTemplate:(NSString *)anFetchName andVariables:(NSDictionary *)anDictionary orderByKey:(id)anKey {
    return [self queryWithFetchTemplate:anFetchName
                           andVariables:anDictionary
                          orderedByKeys:anKey, nil];
}

- (id)queryWithFetchTemplate:(NSString *)anFetchName andVariables:(NSDictionary *)anDictionary
               orderedByKeys:(id)listOfKeys, ... {

	// Create one Array of Sort Descriptors.
	JPDatabaseCreateArrayOfKeys( listOfKeys, arrayOfSorter, self.entityName );
	
	//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// 
	// Call Next Processing.
	return [self queryWithFetchTemplate:anFetchName andVariables:anDictionary sortDescriptors:arrayOfSorter];
	
}

- (id)queryWithFetchTemplate:(NSString *)anFetchName andVariables:(NSDictionary *)anDictionary
             sortDescriptors:(NSArray *)sortDescriptors {
	
	return [self queryWithFetchTemplate:anFetchName andVariables:anDictionary
                        sortDescriptors:sortDescriptors predicate:nil ];
	
}

- (id)queryWithFetchTemplate:(NSString *)anFetchName andVariables:(NSDictionary *)anDictionary
                                                  sortDescriptors:(NSArray *)sortDescriptors predicate:(NSPredicate *)anPredicate {
	
	// Apply All Data.
    [[self applyFetchTemplate:anFetchName] applyFetchVariables:anDictionary];
	[[self applySortDescriptors:sortDescriptors] applyPredicate:anPredicate];
	
	// Perform this action on the manager.
	return [self runAction];
}
 
// Perform this action on the manager.
-(id)runAction {
	// This is a private call.
	return [[self getManagerOrDie] performSelector:@selector(performDatabaseAction:)
										withObject:self];
}

-(id)run {
    return [self runAction];
}



#pragma mark - Set Action Data Methods.
-(id)applyEntity:(NSString*)anEntity {

    // Thrown exception if Entity doesn't exist.
    if ( ![self existEntity:anEntity] )
          [self throwExceptionWithCause:NSFormatString( @"The Entity '%@' doesn't exist on any Model.", anEntity )];

    // Set the entity descriptor from manager.
    self.entity = [[self getManagerOrDie] entity:anEntity];

    return nil;
}

-(id)applyFetchTemplate:(NSString*)anFetchRequest {
    _fetchTemplate = anFetchRequest;
	return self;
}

-(id)applyFetchVariables:(NSDictionary*)anDictionary {
    _fetchVariables = [anDictionary mutableCopy];
	return self;
}

-(instancetype)applyPredicate:(NSPredicate*)anPredicate {
    self.predicate = anPredicate;
	return self;
}





#pragma mark - Order Keys Methods
-(id)applyOrderKeys:(id)listOfKeys, ... {

	// Create one Array of Sort Descriptors.
	JPDatabaseCreateArrayOfKeys( listOfKeys, createdArray, self.entityName );

	// Store it.
	return [self applySortDescriptors:createdArray];
}

- (id)applyAsAscendingOrder:(BOOL)order {
    [self setAscendingOrder:order];
    return self;
}

-(id)applySortDescriptors:(NSArray*)anArray {
	// Check elements.
	for ( id element in anArray ) {
		if ( ![element isKindOfClass:[NSSortDescriptor class]] ) {
			NSString *cause = NSFormatString( @"The array passed as parameter on [%@ %@] must contain only "
                                              @"'NSSortDescriptor' objects. An '%@' class object was passed.",
											 NSStringFromClass([self class]),
											 NSStringFromSelector(_cmd), 
											 NSStringFromClass([element class]));
			//// //// //// //// //// ////// //// //// //// //// ////// //// //// //// //// //
			[self throwExceptionWithCause:cause];
		}
	}
	
	//// //// ////// //// //// //// //// ////// //// //// //// //// //
    self.sortDescriptors = anArray;
	return self;
}

-(instancetype)applyOrderKey:(id)anKey {
	return [self applyOrderKeys:anKey, nil];
}

-(id)addOrderKey:(id)anKey {

	// Check attribute.
	if ( ![self existAttribute:anKey inEntity:self.entityName] )
		  [self throwExceptionWithCause:NSFormatString( @"The attribute '%@' doesn't exist "
                                                        @"on '%@' Entity.", anKey, self.entityName)];

    // Mutable Sort descriptors.
    NSMutableArray *sortDescriptors = [self.sortDescriptors mutableCopy];

	// Alloc if needed it.
	if ( !sortDescriptors)
 	  	  sortDescriptors = [NSMutableArray new];
	
	// Add it.
    [sortDescriptors push:[NSSortDescriptor sortDescriptorWithKey:anKey ascending:self.ascendingOrder]];

	// Save it.
    self.sortDescriptors = sortDescriptors;

	// Return it self.
	return self;
}

-(void)removeOrderKey:(id)anKey {
	// If are empty, do nothing.
	if ( !self.sortDescriptors || [self.sortDescriptors count] == 0 )
		return;

	NSSortDescriptor *found = nil;
	
	// Search him.
	for ( NSSortDescriptor *sorter in self.sortDescriptors) {
		if ( sorter.key == anKey ) {
			found = sorter;
			break;
		}
	}
	
	// Remove it if found.
	if ( found ) {
        NSMutableArray *sortDescriptors = [self.sortDescriptors mutableCopy];
        [sortDescriptors removeObject:found];
        self.sortDescriptors = sortDescriptors;
    }
}




#pragma mark - Query Limits.

-(void)setFetchOffset:(int)offset setFetchLimit:(int)limit {
    self.fetchOffset  = (NSUInteger) offset;
    self.fetchLimit   = (NSUInteger) limit;
}

-(void)resetFetchLimits {
    [self setFetchOffset:0 setFetchLimit:0];
}

-(void)resetDefaultValues {
	//LogWhereCommentTo(SEQOYDBManager, @"Resetting Default Values")
	
	[self resetFetchLimits];
	////
	self.returnsObjectsAsFaults = NO;
	self.ascendingOrder = YES;
	self.returnActionAsArray = YES;
}

- (instancetype)all {
    [self resetDefaultValues];
    [self applyPredicate:nil];
    [self applyFetchTemplate:nil];
    return self;
}

#pragma mark - Write Data Methods.
- (id)createNewRecord {

    // Perform creation. This is a private call.
    id result = [[self getManagerOrDie] performSelector:@selector(createNewRecordFromAction:)
                                             withObject:self];

    // Commit after creation if needed.
    if (_commitTransaction)
        [[self getManagerOrDie] commit];

    // Return result.
    return result;
}





#pragma mark - Remove Data Methods.

// Delete all Records from specified entityName.
- (void)deleteAllRecords {
	[self deleteRecordsWithFetchTemplate:nil];
}

// Delete all records, use an Fetch Template to query for an specified entityName.
- (void)deleteRecordsWithFetchTemplate:(NSString *)anFetchName {
	id entityData = [self queryWithFetchTemplate:anFetchName];

	/////// /////// /////// /////// /////// /////// ///////
	// Loop deleting records.
	for ( id object in entityData ) 
		[self deleteRecord:object andCommit:NO];
	
	// Commit after delete if needed.
	if (_commitTransaction)
		 [[self getManagerOrDie] commit];
} 

// Delete an record of database. Use the Default Setting to Commit Automatically decision.
-(void)deleteRecord:(id)anObject {
    [self deleteRecord:anObject andCommit:_commitTransaction];
}
 
// Delete an record of database. Inform if commit automatically.
-(void)deleteRecord:(id)anObject andCommit:(BOOL)shouldCommit {
	//LogWhereCommentTo(SEQOYDBManager, NSFormatString( @"Deleting [[%@]] %@", [[anObject objectID] URIRepresentation], (commit ? @"[COMMIT]" : @"") ) )
	
	// Delete Record From Managed Context. This is a private call.
	[[self getManagerOrDie] performSelector:@selector(deleteRecord:) withObject:anObject];

	// Commit if asked...
	if( shouldCommit )
		[[self getManagerOrDie] commit];
}



#pragma mark - Deprecated Methods.
-(id)applyFetchReplaceWithVariables:(id)variableList, ... {
    [NSException raise:JPDBManagerDeprecatedException format:@"Deprecated you should use 'applyFetchVariables:' instead."];
    return nil;
}

// Create and return a new empty Record for specified Entity.
-(id)createNewRecordForEntity:(NSString*)anEntityName {
    [NSException raise:JPDBManagerDeprecatedException format:@"Deprecated. Use 'createNewRecord' instead."];
    return nil;
}

-(id)queryEntity:(NSString*)anEntityName withFetchTemplate:(NSString*)anFetchName orderWithKey:(id)anKey withVariables:(id)variableList, ... {
    [NSException raise:JPDBManagerDeprecatedException format:@"Deprecated. Use 'queryWithFetchTemplate:andVariables:orderByKey:' instead."];
    return nil;
}

-(id)queryEntity:(NSString*)anEntityName withFetchTemplate:(NSString*)anFetchName withVariables:(id)variableList, ...  {
    [NSException raise:JPDBManagerDeprecatedException format:@"Deprecated. Use 'queryWithFetchTemplate:andVariables:' instead."];
    return nil;
}



@end
