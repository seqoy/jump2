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
 
@implementation JPDBManagerAction


#pragma mark - Init Methods.
+(id)initWithManager:(JPDBManager*)anManager {
	return [[self alloc] initWithManager:anManager];
}
  
-(id)initWithManager:(JPDBManager*)anManager {
	self = [super init];
	if (self != nil) {
		
		// Initializations.
		self.manager = anManager;
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
	_sortDescriptors = newSorters;
	
	// New General value.
	_ascendingOrder = newValue;
}




#pragma mark - Private Methods.
-(JPDBManager*)getManagerOrDie {
	if ( ! self.manager) {
		[NSException raise:JPDBManagerActionException
					format:@"You must define an Database Manager before perform any action."];
		return nil;
	}
	
	// Return instance.
	return self.manager;
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
-(id)queryEntity:(NSString*)anEntityName withPredicate:(NSPredicate*)anPredicate {
	return [self queryEntity:anEntityName withPredicate:anPredicate orderWithKey:nil];
}
 
-(id)queryEntity:(NSString*)anEntityName withPredicate:(NSPredicate*)anPredicate orderWithKey:(id)anKey {
	return [self queryEntity:anEntityName withPredicate:anPredicate orderWithKeys:anKey, nil];	
}
 
-(id)queryEntity:(NSString*)anEntityName withPredicate:(NSPredicate*)anPredicate orderWithKeys:(id)listOfKeys, ... {
	
	// Create one Array of Sort Descriptors.
	JPDatabaseCreateArrayOfKeys( listOfKeys, arrayOfSorter, anEntityName );
	
	//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// 
	
	// Call Next Processing.
	return [self queryEntity:anEntityName withPredicate:anPredicate arrayOfSortDescriptors:arrayOfSorter ];
	
}
 
-(id)queryEntity:(NSString*)anEntityName withPredicate:(NSPredicate*)anPredicate arrayOfSortDescriptors:(NSArray*)anArrayOfSortDescriptors {
	
	return [self queryEntity:anEntityName withFetchTemplate:nil replaceFetchWithDictionary:nil 
	  arrayOfSortDescriptors:anArrayOfSortDescriptors customPredicate:anPredicate];
	
}




#pragma mark - Fetch Data Methods.
-(id)queryAllDataFromEntity:(NSString*)anEntityName {
	return [self queryEntity:anEntityName withFetchTemplate:nil];
}
 
-(id)queryAllDataFromEntity:(NSString*)anEntityName orderWithKey:(id)anKey {
	return [self queryAllDataFromEntity:anEntityName orderWithKeys:anKey, nil];
}
 
-(id)queryAllDataFromEntity:(NSString*)anEntityName orderWithKeys:(id)anKey, ... {
    va_list listOfKeys;
    va_start(listOfKeys, anKey);

    NSArray *result = [self queryAllDataFromEntity:anEntityName
                                      orderWithKey:anKey
                                        parameters:listOfKeys];

    va_end(listOfKeys);
    return result;
}

- (id)queryAllDataFromEntity:(NSString *)anEntityName orderWithKey:(id)anKey parameters:(va_list)arguments {
    NSMutableArray *sorters = [[NSMutableArray alloc] init];
    for (id arg = anKey; arg != nil; arg = va_arg(arguments, id))
    {
        if ( ![self existAttribute:arg inEntity:anEntityName] )
        {
            [self throwExceptionWithCause:NSFormatString( @"The attribute '%@' doesn't exist on '%@' Entity.", arg, anEntityName)];
        }
        [sorters addObject:[[NSSortDescriptor alloc] initWithKey:arg ascending:self.ascendingOrder]];
    }

    // Call Next Processing.
    return [self queryEntity:anEntityName
           withFetchTemplate:nil
  replaceFetchWithDictionary:nil
      arrayOfSortDescriptors:sorters ];
}

-(id)queryEntity:(NSString*)anEntityName withFetchTemplate:(NSString*)anFetchName  {
	return [self queryEntity:anEntityName withFetchTemplate:anFetchName replaceFetchWithDictionary:nil];
}

-(id)queryEntity:(NSString*)anEntityName withFetchTemplate:(NSString*)anFetchName orderWithKey:(id)anKey {
	return [self queryEntity:anEntityName withFetchTemplate:anFetchName orderWithKeys:anKey, nil];
}

-(id)queryEntity:(NSString*)anEntityName withFetchTemplate:(NSString*)anFetchName orderWithKeys:(id)listOfKeys, ... {
	
	// Create one Array of Sort Descriptors.
	JPDatabaseCreateArrayOfKeys( listOfKeys, arrayOfSorter, anEntityName );
	
	//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// 
	
	// Call Next Processing.
	return [self queryEntity:anEntityName  
		   withFetchTemplate:anFetchName 
  replaceFetchWithDictionary:nil
 	  arrayOfSortDescriptors:arrayOfSorter ];
}

-(id)queryEntity:(NSString*)anEntityName withFetchTemplate:(NSString*)anFetchName orderWithKey:(id)anKey withVariables:(id)variableList, ... {
    [NSException raise:JPDBManagerDeprecatedException format:@"Deprecated. Use 'queryEntity:withFetchTemplate:replaceFetchWithDictionary:orderWithKey:' instead."];
    return nil;
}
 
-(id)queryEntity:(NSString*)anEntityName withFetchTemplate:(NSString*)anFetchName withVariables:(id)variableList, ...  {
    [NSException raise:JPDBManagerDeprecatedException format:@"Deprecated. Use 'queryEntity:withFetchTemplate:replaceFetchWithDictionary:' instead."];
    return nil;
}
 
-(id)queryEntity:(NSString*)anEntityName withFetchTemplate:(NSString*)anFetchName replaceFetchWithDictionary:(NSDictionary*)anDictionary {
	return [self queryEntity:anEntityName 
		   withFetchTemplate:anFetchName 
  replaceFetchWithDictionary:anDictionary 
	  arrayOfSortDescriptors:nil];
	
}
 
-(id)queryEntity:(NSString*)anEntityName withFetchTemplate:(NSString*)anFetchName replaceFetchWithDictionary:(NSDictionary*)anDictionary orderWithKey:(id)anKey {
	return [self queryEntity:anEntityName 
		   withFetchTemplate:anFetchName
  replaceFetchWithDictionary:anDictionary 
			   orderWithKeys:anKey, nil];
}

-(id)queryEntity:(NSString*)anEntityName withFetchTemplate:(NSString*)anFetchName 
replaceFetchWithDictionary:(NSDictionary*)anDictionary orderWithKeys:(id)listOfKeys, ... {
	
	// Create one Array of Sort Descriptors.
	JPDatabaseCreateArrayOfKeys( listOfKeys, arrayOfSorter, anEntityName );
	
	//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// 
	// Call Next Processing.
	return [self queryEntity:anEntityName 
		   withFetchTemplate:anFetchName 
  replaceFetchWithDictionary:anDictionary 	
	  arrayOfSortDescriptors:arrayOfSorter ];
	
}
 
-(id)queryEntity:(NSString*)anEntityName withFetchTemplate:(NSString*)anFetchName 
replaceFetchWithDictionary:(NSDictionary*)anDictionary  arrayOfSortDescriptors:(NSArray*)anArrayOfSortDescriptors {
	
	return [self queryEntity:anEntityName withFetchTemplate:anFetchName replaceFetchWithDictionary:anDictionary 
	  arrayOfSortDescriptors:anArrayOfSortDescriptors customPredicate:nil];
	
}
 
-(id)queryEntity:(NSString*)anEntityName withFetchTemplate:(NSString*)anFetchName 
replaceFetchWithDictionary:(NSDictionary*)anDictionary  arrayOfSortDescriptors:(NSArray*)anArrayOfSortDescriptors
 customPredicate:(NSPredicate*)anPredicate {
	
	// Apply All Data.
	[[[self applyEntity:anEntityName] applyFetchTemplate:anFetchName] applyFetchReplaceWithDictionary:anDictionary];
	[[self applyArrayOfSortDescriptors:anArrayOfSortDescriptors] applyPredicate:anPredicate];
	
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
    _entity = [anEntity copy];
	return self;
}

-(id)applyFetchTemplate:(NSString*)anFetchRequest {
    _fetchTemplate = anFetchRequest;
	return self;
}

-(id)applyFetchReplaceWithDictionary:(NSDictionary*)anDictionary {
    _variablesListAndValues = [anDictionary mutableCopy];
	return self;
}

-(id)applyFetchReplaceWithVariables:(id)variableList, ... {

	// Create one Dictionary with Variable Arguments.
	JPDatabaseCreateDictionaryOfVariables( variableList, createdDictionary );
	
	//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// ////
	return [self applyFetchReplaceWithDictionary:createdDictionary];
}	

-(instancetype)applyPredicate:(NSPredicate*)anPredicate {
    _predicate = anPredicate;
	return self;
}




#pragma mark - Order Keys Methods
-(id)applyOrderKeys:(id)listOfKeys, ... {
	// Must have an entity defined at this point.
	if ( !self.entity)
		[self throwExceptionWithCause:NSFormatString( @"You must define one Entity first. Use [%@ applyEntity:].",
                                                                                      NSStringFromClass([self class]))];
	
	// Create one Array of Sort Descriptors.
	JPDatabaseCreateArrayOfKeys( listOfKeys, createdArray, self.entity );

	// Store it.
	return [self applyArrayOfSortDescriptors:createdArray];
}

- (id)applyAsAscendingOrder:(BOOL)order {
    [self setAscendingOrder:order];
    return self;
}

-(id)applyArrayOfSortDescriptors:(NSArray*)anArray {
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
    _sortDescriptors = [anArray mutableCopy];
	return self;
}

-(instancetype)applyOrderKey:(id)anKey {
	return [self applyOrderKeys:anKey, nil];
}

-(id)addOrderKey:(id)anKey {
	// Must have an entity defined at this point.
	if ( !self.entity)
		[self throwExceptionWithCause:NSFormatString( @"You must define one Entity first. Use [%@ applyEntity:].",
                                                                                      NSStringFromClass([self class]))];
	
	// Check attribute.
	if ( ![self existAttribute:anKey inEntity:self.entity] )
		[self throwExceptionWithCause:NSFormatString( @"The attribute '%@' doesn't exist "
                                                      @"on '%@' Entity.", anKey, self.entity)];

	// Alloc if needed it.
	if ( !self.sortDescriptors) 
		_sortDescriptors = [NSMutableArray new];
	
	// Add it.
	[self.sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:anKey ascending:self.ascendingOrder]];
		
	// Return it self.
	return self;
}

-(void)removeOrderKey:(id)anKey {
	// If are empty, do nothing.
	if ( !self.sortDescriptors || [self.sortDescriptors count] == 0 )
		return;

	/////////////////
	NSSortDescriptor *found = nil;
	
	//// //// //// //// //// //// //// //// //// //// //// //// //// //// 
	// Search him.
	for ( NSSortDescriptor *sorter in self.sortDescriptors) {
		if ( sorter.key == anKey ) {
			found = sorter;
			break;
		}
	}
	
	// //// //// //// //// //// //// //// //// // //// //// //// //// //// //// //// //// 
	// Remove it if found.
	if ( found ) 
		[self.sortDescriptors removeObject:found];
}




#pragma mark - Query Limits.
-(void)setStartFetchInLine:(int)anValue setLimitFetchResults:(int)anValue2 {
	self.limitFetchResults = anValue2; self.startFetchInLine = anValue;
}

-(void)resetFetchLimits { 	 self.limitFetchResults = self.startFetchInLine = 0; }

-(void)resetDefaultValues {
	//LogWhereCommentTo(SEQOYDBManager, @"Resetting Default Values")
	
	[self resetFetchLimits];
	////
	self.returnObjectsAsFault = NO;
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
// Create and return a new empty Record for specified Entity.
-(id)createNewRecordForEntity:(NSString*)anEntityName {
	// Store the Entity.
	[self applyEntity:anEntityName];
	
	// Perform creation. This is a private call.
	id result = [[self getManagerOrDie] performSelector:@selector(createNewRecordForEntity:)
										withObject:anEntityName];
	
	// Commit after creation if needed.
	if (_commitTransaction)
		[[self getManagerOrDie] commit];
	
	// Return result.
	return result;	
}




#pragma mark - Remove Data Methods.

// Delete all Records from specified entity.
-(void)deleteAllRecordsFromEntity:(NSString*)anEntityName {
	[self deleteRecordsFromEntity:anEntityName withFetchTemplate:nil];
}

// Delete all records, use an Fetch Template to query for an specified entity.
-(void)deleteRecordsFromEntity:(NSString*)anEntityName withFetchTemplate:(NSString*)anFetchName {
	id entityData = [self queryEntity:anEntityName withFetchTemplate:anFetchName];

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


@end
