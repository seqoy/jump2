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
#import "JPDBManager.h"
#import "JPDBManagerAction.h"

@interface JPDBManager() {
    NSManagedObjectModel *_managedObjectModel;
    NSManagedObjectContext *_managedObjectContext;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}
@end

@implementation JPDBManager

#pragma mark - Init Methods.
+(id)init {
	return [[self alloc] init];
}

+(id)initAndStartCoreData {
	JPDBManager *instance = [self new];
	[instance startCoreData];
	
	// Return Instantiated.
	return instance;
}




#pragma mark - Notifications Methods.
-(void)notificateError:(NSError*)anError {
	
	// Create an Notification.
	NSNotification *anNotification = [NSNotification notificationWithName:JPDBManagerErrorNotification 
																   object:anError 
																 userInfo:@{JPDBManagerErrorNotification: self}];
	// Post notification.
	[[NSNotificationCenter defaultCenter] postNotification:anNotification];
}




#pragma mark - Private Methods.  
-(void)throwExceptionWithCause:(NSString*)anCause {
	[NSException raise:JPDBManagerActionException format:@"%@", anCause];
}
//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// /
-(void)throwIfNilObject:(id)anObject withCause:(NSString*)anCause {
	if ( anObject == nil ) 
		[self throwExceptionWithCause:anCause];
}




#pragma mark Start and Stop Methods.
-(id)startCoreData {
    
    // Set Core Data to merges conflicts between the persistent store’s version of the object 
    // and the current in-memory version, giving priority to in-memory changes.
    [self.managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
	return self;
}
 
// Start Core Data Databases. Using an specific model.
-(id)startCoreDataWithModel:(NSString*)modelName {
	//Info( @"Starting Core Data Using Model: [[%@]]", modelName );
	
	// Dealloc if needed and set.
	_loadedModelName = [modelName copy];
	
	// Continue.
	[self startCoreData];
	
	// Return ourselves.
	return self;
}
 
// Close Core Data Database.
-(void)closeCoreData {
	
	 ////// 
	// Commit data.
	[self commit];
    
    _managedObjectModel = nil;
	_managedObjectContext = nil;
	_persistentStoreCoordinator = nil;
}

-(void)removePersistentStore {

    // Error control.
    NSError *anError = nil;
    
    // The Database Manager only cares about one store, but for consistency let's loop all.
    for (NSPersistentStore *store in [self.persistentStoreCoordinator persistentStores]) {
        [self.persistentStoreCoordinator removePersistentStore:store error:&anError];
    }

    // Close it.
    _managedObjectModel = nil;
	_managedObjectContext = nil;
	_persistentStoreCoordinator = nil;
}
 
-(JPDBManagerAction*)getDatabaseAction {
	JPDBManagerAction *instance = [JPDBManagerAction initWithManager:self];
	instance.commitTransaction = self.automaticallyCommit;
	return instance;
}




#pragma mark - Core Data Stack (Private Methods).

// Returns the path to the application's documents directory.
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
	
    return basePath;
}

// Return an NSURL object that contains where the SQLite file is located.
-(NSURL*)SQLiteFilePath {
    return [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"mainDatabase.SQlite"]];
}


//
// Managed Object Model Accessor. If the model doesn't already exist, it is created by merging all of
// the models found in the application bundle.
//
// Returns the managed object model for the application.
//
- (NSManagedObjectModel *)managedObjectModel {
	
	// Return Managed Object Model if is already started...
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
	
	 ////// ////// //////
	// If defined an Model Name, search for him on bundle.
	if (_loadedModelName) {
		NSString *modelPath = NSFormatString( @"%@/%@", JPBundlePath(), _loadedModelName );
        
		 ////// //////
		// If file no exist, throw error.
		if ( _NOT_ [[NSFileManager defaultManager] fileExistsAtPath:modelPath] ) {

			// Error Message and Crash the System. 
            [NSException raise:JPDBManagerStartException
                        format:@"Informed Model: %@ **NOT FOUND on bundle. Full Path: %@", _loadedModelName, modelPath];
		}

        //Info( @"Initializing The Managed Object Model: %@", modelPath);

		 //////
		// Alloc and Init.
		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath: modelPath]];
	}
	
	 ////// ////// //////
	// If isn't specified...
	// Merge all models found in the application bundle. 
	else {
		_managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	}
	
	// Return Managed Object Model.
    return _managedObjectModel;
}


//
// persistentStoreCoordinator
//
// Accessor. If the coordinator doesn't already exist, it is created and the
// application's store added to it.
//
// Returns the persistent store coordinator for the application.
//
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {

	// Return Persistent Coordinator if is already started...
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    //
    // We're waiting until Protected Data is Available before try to start the Core Data environment.
    // More info here: http://stackoverflow.com/questions/12845790/how-to-debug-handle-intermittent-authorization-denied-and-disk-i-o-errors-wh
    //
    while(![[UIApplication sharedApplication] isProtectedDataAvailable]) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5f]];
    }
	
	 ////// ////// //////
	
	// Main Database Path.
    NSURL *mainDatabase = [self SQLiteFilePath];
	
	// Error Control.
	NSError *error = nil;
	
	 ////// ////// //////
	// Alloc and Init Persistent Coordinator.
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
	
	 ////// ////// //////
	//
	// Options to pass to persistent store. http://developer.apple.com/iphone/library/documentation/Cocoa/Conceptual/CoreDataVersioning/Articles/vmMappingOverview.html
	//
	NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,	
							 
			 // Attempt to create the mapping model automatically.
			 NSInferMappingModelAutomaticallyOption: @YES};
	
	 ////// ////// //////
	// Add JPL to the Persistent, control error above.
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:mainDatabase
                                                         options:options
                                                           error:&error]) {
		
		 ////// ////// //////
        // Handle error.
		
		// Error Message and Crash the System. 
		[NSException raise:JPDBManagerStartException
					format: @"Unsolved Error: (%@), (%@).", error, [error userInfo]];
    }    
	
	// Return Persistent Coordinator.
    return _persistentStoreCoordinator;
}

//
// Managed Object Context Accessor. If the context doesn't already exist, it is created and bound to
// the persistent store coordinator for the application.
//
// Returns the managed object context for the application.
//
- (NSManagedObjectContext*)managedObjectContext {
	
	// Return Managed Object Context if is already started...
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    // Alloc and Start.
    _managedObjectContext = self.enableThreadSafeOperation 
                                    ? [[IAThreadSafeContext alloc] init] 
                                    : [[NSManagedObjectContext alloc] init];

    [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
	
	// Return.
    return _managedObjectContext;
}


 
#pragma mark - Checking Methods. 
- (NSEntityDescription *)entity:(NSString *)entityName {
    return [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];;
}

 
// Return YES if specified Entity exist on the model.
-(BOOL)existEntity:(NSString*)anEntityName {
	
	// Try to retrieve the Entity.
	NSEntityDescription *entity = [self entity:anEntityName];

    // Not Exist.
	if ( _NOT_ entity ) {	
		//Warn( @"JPDatabaseManager : The Entity '%@' doesn't exist on any Model.", anEntityName );
		return NO;
	}
	
	// Exist.
	return YES;
}

 
// Return YES if specified Attribute exist on specified Entity.
-(BOOL)existAttribute:(NSString*)anAttributeName inEntity:(NSString*)anEntityName {
	
	// If NOT Exist Entity retun NO;
	if ( _NOT_ [self existEntity:anEntityName] )
		return NO;
	
	// Retrieve the Entity.
	NSEntityDescription *entity = [NSEntityDescription entityForName:anEntityName inManagedObjectContext:_managedObjectContext];
	
	// Test if exist this attribute.
	if ( _NOT_ [entity attributesByName][anAttributeName] ) {	
		//Warn( @"JPDatabaseManager : The Attribute/Key '%@' doesn't exist in Entity '%@'.", anAttributeName, anEntityName );
		return NO;
	}
	
	return YES;
	
}

 
#pragma mark - Database Action Methods. 
 
// This method is called from the JPDBManagerAction as an private call. 
-(id)performDatabaseActionInternally:(JPDBManagerAction*)anAction {
	
	// Can't be nil.
	[self throwIfNilObject:anAction withCause:@"Can't perform an Database Action because an Action wasn't passed."];

	// //// //// //// //// //// 
	// Put on Variables.
	NSString* anEntityName				 = [anAction entity];
	NSString* anFetchName				 = [anAction fetchTemplate];
	NSDictionary* variablesListAndValues = [anAction variablesListAndValues];
	NSArray* anArrayOfSortDescriptors	 = [anAction sortDescriptors];
	NSPredicate* anPredicate			 = [anAction predicate];

	// //// //// //// //// //// 
	// Check Parameters.
	NSString *throwMessage = @"Can't perform an Database Action because the '%@' property isn't setted.";
	[self throwIfNilObject:anEntityName withCause:NSFormatString( throwMessage, @"entity" )];

	/// // //// //// //// 
	// Format Log.
	NSMutableString *format = [NSMutableString stringWithString:NSFormatString( @"Querying {%@}", anEntityName )];
	if ( anFetchName ) 
		[format appendString:NSFormatString( @", TEMPL:(%@)", anFetchName )];
	//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// 
	if ( anPredicate ) {
		NSString *predicateLiteral = [anPredicate predicateFormat];
		[format appendString:NSFormatString( @", PREDIC:(%@%@)", [predicateLiteral substringWithRange:(NSRange){0,([predicateLiteral length] > 50 ? 50 : [predicateLiteral length])}], ([predicateLiteral length] > 50 ? @"..." : @""))];
	}
	//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// 
	if ( anArrayOfSortDescriptors _AND_ [anArrayOfSortDescriptors count] > 0) {
		[format appendString:@", ORD: "];
		for ( NSString *key in anArrayOfSortDescriptors ) {
			[format appendString:NSFormatString( @"%@, ", key)];
		}
	}
		
	/// // //// //// //// 
	// If doesn't exist the Entity, return nothing.
	if ( _NOT_ [self existEntity:anEntityName] ) {
		[self throwExceptionWithCause:NSFormatString( @"The Entity '%@' doesn't exist on any Model.", anEntityName )];
		return nil;
	}
	
	// Get the Entity.
	NSEntityDescription *entity = [NSEntityDescription entityForName:anEntityName inManagedObjectContext:_managedObjectContext];

	// //// //// //// //// //// 
	
	//// //// //// //// //// //// //// //// //// //// //// /
	// Create the Fetch Request.
	NSFetchRequest *query = [[NSFetchRequest alloc] init];

	//// //// //// //// //// //// //// //// //// //// //// /	
	// Try to use an Fetch Template, if defined.
	if ( anFetchName ) {
		
		//// //// //// //// //// //// //// //// //// //// //// /	
		// Fetch Template, replacing variables, if defined...
		if ( variablesListAndValues ) {
			query = [_managedObjectModel fetchRequestFromTemplateWithName:anFetchName substitutionVariables:variablesListAndValues];
			
		} 
		
		//// //// //// //// //// //// //// //// //// //// //// /	
		// ..if not, just get the fetch template.
		else						  [query setPredicate:[_managedObjectModel fetchRequestTemplateForName:anFetchName].predicate];
		
		//// //// //// //// //// //// //// //// //// //// //// /	
		// Not Exist.
		if ( _NOT_ query ) {
			[self throwExceptionWithCause:NSFormatString( @"The Fetch Template '%@' for Entity '%@' doesn't  exist on the Model.", anFetchName, anEntityName )];
			return nil;
		}	

	}
		
	//// //// //// //// //// //// //// //// //// //// //// ///// //// //// //// //// //// //// //// //// //// //// /		
	// If have one defined predicate (parameter). Insert on the query.
	else if ( anPredicate ) 
		[query setPredicate:anPredicate];

	//// //// //// //// //// //// //// //// //// //// //// ///// //// //// //// //// //// //// //// //// //// //// /
	// Can't perform with no predicates.
//	else {
//		[self throwExceptionWithCause:NSFormatString( throwMessage, @"fetchRequest' or 'predicate" )];
//	}
	
	// //// //// //// //// //// 
	// Set Order if defined.
	if ( anArrayOfSortDescriptors )
		[query setSortDescriptors:anArrayOfSortDescriptors];
	
	// //// //// //// //// //// 
	// Apply Settings.
	[query setReturnsObjectsAsFaults:[anAction returnObjectsAsFault]];			// Fault Lines?
	[query setEntity:entity];													// Set Entity.
	
	// Apply Limits.
	[query setFetchLimit:[anAction limitFetchResults]];
	[query setFetchOffset:[anAction startFetchInLine]];
	
	// //// //// //// //// //// 
	// Error Control.
	NSError *error = nil;
	
	// //// //// //// //// //// 
	// Return Data as Arrays.
	if ( [anAction returnActionAsArray] ) {

		// Run Fetch (SELECT).
		id queryResult = [_managedObjectContext executeFetchRequest:query error:&error];
		
		// Notificate the error.
		if ( error ) 
			[self notificateError:error];
		
		// Return data.
		return queryResult;
	}

    // //// //// //// //// ///// 
	// Return Data as NSFetchedResultsController 
	else {
        
        //// //// //// //// //// //// //// //// //// //// //// //// //// 
        // Only iPhone.
        #if TARGET_OS_IPHONE 
            return [[NSFetchedResultsController alloc] initWithFetchRequest:query
												   managedObjectContext:_managedObjectContext
													 sectionNameKeyPath:nil
                                                                   cacheName:nil];
        //// //// //// //// //// //// //// //// //// //// //// //// //// 
        #else
            return nil;
        #endif
	}
    //// //// //// //// //// //// //// //// //// //// //// //// //// 
}

 
// Thread Unsafe Database Action.
-(id)performDatabaseAction:(JPDBManagerAction*)anAction {
	return [self performDatabaseActionInternally:anAction];
}

 
// Thread Safe Database Action.
-(id)performThreadSafeDatabaseAction:(JPDBManagerAction*)anAction {
    id object = nil;
	// Syncronized call, so this is an thread safe operation.
	@synchronized( anAction ) {
		object = [self performDatabaseActionInternally:anAction];
	}
    return object;
}




#pragma mark - Write Data Methods. 


// Commit all pendent operations to the persistent store.
-(void)commit {
    
    // We need to have the full environment working to commit.
    if ( _managedObjectModel && _managedObjectContext && _persistentStoreCoordinator) {

        NSLog( @"Saving Changes To Database.");
        
        // Error Control.
        NSError *anError = nil;
        
        //// //// //// //// //// //// //// /////// //// //// //// //// //// //// ///
        // Performs the commit action for the application, which is to send
        // the save: message to the Application's Managed Object Context.
        if ( ! [[self managedObjectContext] save:&anError] ) {
            //Warn( @"Commit Error: %@.\n\n. Full Error Description:\n\n %@", [anError localizedDescription], anError );
            NSLog( @"Commit Error: %@.\n\n. Full Error Description:\n\n %@", [anError localizedDescription], anError );
            
            // Notificate the error.
            [self notificateError:anError];
        }
    }
}


// Create and return a new empty Record for specified Entity.
-(id)createNewRecordForEntity:(NSString*)anEntityName {
	
	// If not exist, return nothing.
	if ( _NOT_ [self existEntity:anEntityName] ) 
		return nil;
	
	// Create and return a new record.
	id newRecord = [NSEntityDescription insertNewObjectForEntityForName:anEntityName
                                                 inManagedObjectContext:_managedObjectContext];
	
	// Return created object.
	return newRecord;
}




#pragma mark -  Remove Data Methods.

// Delete an record of database. Use the Default Setting to Commit Automatically decision.
-(void)deleteRecord:(id)anObject {
	[[self managedObjectContext] deleteObject:anObject];
}

@end
