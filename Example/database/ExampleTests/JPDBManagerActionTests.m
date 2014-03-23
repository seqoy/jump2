#import "Kiwi.h"

#import "NSArray+ObjectiveSugar.h"

#import "JPDBManager.h"
#import "JPDBManagerAction.h"

SPEC_BEGIN(ManagerAction)

describe(@"Database Action", ^{
    
    #define __entityName @"_entity_"
    #define __entityNameNotExist @"_entity_not_exist_"
    #define __fetchTemplate @"_fetchTemplate"

    __block id manager;
    __block id entity;
    __block JPDBManagerAction *action;

    beforeEach(^{
        // Mock an NSEntityDescription representing our entity.
        entity = [KWMock mockForClass:[NSEntityDescription class]];
        [entity stub:@selector(name) andReturn:__entityName];

        // Mock the manager.
        manager = [KWMock mockForClass:[JPDBManager class]];
        
        // Stub internal tests.
        [manager stub:@selector(existAttribute:inEntity:) andReturn:[KWValue valueWithBool:YES]];
        [manager stub:@selector(existEntity:) andReturn:[KWValue valueWithBool:YES] withArguments:__entityName];
        [manager stub:@selector(existEntity:) andReturn:[KWValue valueWithBool:NO] withArguments:__entityNameNotExist];
        [manager stub:@selector(entity:) andReturn:entity withArguments:__entityName];

        // Build an action.
        action = [JPDBManagerAction initWithEntityName:__entityName andManager:manager];
    });

    ////////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// /////////

    context(@"Init", ^{

        it(@"Should init and store the manager", ^{
            [action shouldNotBeNil];
            [[action.manager should] equal:manager];
            [[action.entity should] equal:entity];
            [[action.entityName should] equal:__entityName];
         });

        
        
        
        it(@"Should reset default values", ^{
            [action setFetchOffset:5 setFetchLimit:10];

            [[@(action.fetchOffset) should] equal:@(5)];
            [[@(action.fetchLimit) should] equal:@(10)];
            
            [action resetDefaultValues];

            [[@(action.fetchOffset) should] equal:@(0)];
            [[@(action.fetchLimit) should] equal:@(0)];
        });
        
    });
    
    ////////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// /////////
    
    context(@"Exceptions", ^{
        
        it(@"Should fail init with an entity that not exist", ^{

            // Run the controlled exception.
            [[theBlock(^{
                [action initWithEntityName:__entityNameNotExist andManager:manager];
            })

                    should] raiseWithName:JPDBManagerActionException];
        });

    });
    
    ////////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// /////////
    
    context(@"Action Data", ^{

        it(@"Should apply Action data", ^{
            JPDBManagerAction *result;

            result = [action applyFetchTemplate:__fetchTemplate];
            [[result should] equal:action];
            [[result.fetchTemplate should] equal:__fetchTemplate];

            NSDictionary *emptyDictionary = [NSDictionary new];
            result = [action applyFetchReplaceWithDictionary:emptyDictionary];
            [[result should] equal:action];
            [[result.variablesListAndValues should] equal:emptyDictionary];

            NSPredicate *predicate = [NSPredicate new];
            result = [action applyPredicate:predicate];
            [[result should] equal:action];
            [[result.predicate should] equal:predicate];
        });
        
        
        
        

        it( @"Should run the action", ^{
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wundeclared-selector"
            
            // Stub the manager to receive internal call.
            [manager stub:@selector(performDatabaseAction:) withArguments:action];
            [[manager should] receive:@selector(performDatabaseAction:) withArguments:action];
            [action run];
            
            #pragma clang diagnostic pop
        });


    });
    
    ////////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// /////////

    context(@"Order", ^{
        
        it( @"Should apply key orders", ^{
            JPDBManagerAction *result;
            
            NSArray *emptyArray = [NSArray new];
            result = [action applyArrayOfSortDescriptors:emptyArray];
            [[result should] equal:action];
            [[action.sortDescriptors should] equal:emptyArray];

            /////////// ///////////

            result = [action applyOrderKey:@"keyA"];
            [[result should] equal:action];
            [action.sortDescriptors each:^(NSSortDescriptor *item) {
                [[item.key should] equal:@"keyA"];
            }];

            [action removeOrderKey:@"keyA"];
            [[action.sortDescriptors should] beEmpty];

            /////////// ///////////

            result = [action applyOrderKeys:@"keyA", @"keyB", nil];
            [[result should] equal:action];
            [action.sortDescriptors eachWithIndex:^(NSSortDescriptor *item, NSUInteger i) {
                if ( i == 0 ) [[item.key should] equal:@"keyA"];
                if ( i == 1 ) [[item.key should] equal:@"keyB"];
            }];
        });
        
        
        
        
        it(@"Should change ascending order", ^{
            // Insert some sort descriptors.
            [action applyArrayOfSortDescriptors:
                    @[
                            [NSSortDescriptor sortDescriptorWithKey:@"keyA" ascending:YES],
                            [NSSortDescriptor sortDescriptorWithKey:@"keyB" ascending:YES]
                    ]
            ];

            // Set the order, it should change the sort descriptors property.
            action.ascendingOrder = NO;
            
            [action.sortDescriptors each:^( NSSortDescriptor *item ) {
                [[@(item.ascending) should] beFalse];
            }];
        });


    });
    
    ////////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// /////////
    
    context(@"Query", ^{

        // All query methods concatenate to call one final method, we'll stub and expect data from him
        // in all query tests.
        __block SEL finalMethod = @selector(queryWithFetchTemplate:withParams:sortDescriptors:predicate:);

        beforeEach(^{
            // Stub the final method.
            [action stub:finalMethod];
        });
        
        it(@"Should query all data of the specified Entity", ^{
            [action stub:finalMethod];
            [[action should] receive:finalMethod withArguments:any(), any(), any(), any()];
            [action queryAllData];
        });

        
        
        
        it(@"Should query all data of the specified Entity ordering by specified key", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {
                   [params[2] each:^( NSSortDescriptor *item ) {
                       [[item.key should] equal:@"_key_"];
                   }];
                   return nil;
               }
            ];
            [action queryAllDataOrderedByKey:@"_key_"];
        });




        it(@"Should query all data of the specified Entity ordering by specified keys", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {

                   [params[2] eachWithIndex:^( NSSortDescriptor *item, NSUInteger index) {
                       if ( index == 0 ) [[item.key should] equal:@"keyA"];
                       if ( index == 1 ) [[item.key should] equal:@"keyB"];
                   }];
                   return nil;
               }
            ];
            [action queryAllDataOrderedByKeys:@"keyA", @"keyB", nil];
        });
        
        
        
        
        it(@"Should query specified Entity using one specified Fetch Template name", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {

                   [[params[0] should] equal:__fetchTemplate];
                   return nil;
               }
            ];
            [action queryWithFetchTemplate:__fetchTemplate ];

        });




        it(@"Should query specified Entity using one specified Fetch Template name ordering with specific key", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {

                   [[params[0] should] equal:__fetchTemplate];
                   [params[2] each:^( NSSortDescriptor *item ) {
                       [[item.key should] equal:@"_key_"];
                   }];
                   return nil;
               }
            ];
            [action queryWithFetchTemplate:__fetchTemplate ordereredByKey:@"_key_"];

        });




        it(@"Should query specified Entity using one specified Fetch Template name ordering with specific keys", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {

                   [[params[0] should] equal:__fetchTemplate];
                   [params[2] eachWithIndex:^( NSSortDescriptor *item, NSUInteger index) {
                       if ( index == 0 ) [[item.key should] equal:@"keyA"];
                       if ( index == 1 ) [[item.key should] equal:@"keyB"];
                   }];
                   return nil;
               }
            ];
            [action queryWithFetchTemplate:__fetchTemplate orderedByKeys:@"keyA", @"keyB", nil];

        });




        it(@"Query specified Entity using one specified Fetch Template name, replacing data with dictionary", ^{
            NSDictionary *replaceWith = @{@"anKey": @"anValue"};
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {

                   [[params[0] should] equal:__fetchTemplate];
                   [[params[1] should] equal:replaceWith];
                   return nil;
               }
            ];
            [action queryWithFetchTemplate:__fetchTemplate withParams:replaceWith];
        });





        it(@"Query specified Entity using one specified Fetch Template name, replacing data with dictionary"
           @"ordering by key", ^{
            NSDictionary *replaceWith = @{@"anKey": @"anValue"};
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {

                   [[params[0] should] equal:__fetchTemplate];
                   [[params[1] should] equal:replaceWith];
                   [params[2] each:^( NSSortDescriptor *item ) {
                       [[item.key should] equal:@"_key_"];
                   }];
                   return nil;
               }
            ];
            [action queryWithFetchTemplate:__fetchTemplate withParams:replaceWith orderByKey:@"_key_"];
        });




        it(@"Query specified Entity using one specified Fetch Template name, replacing data with dictionary"
                @"ordering by keys", ^{
            NSDictionary *replaceWith = @{@"anKey": @"anValue"};
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {

                   [[params[0] should] equal:__fetchTemplate];
                   [[params[1] should] equal:replaceWith];
                   [params[2] eachWithIndex:^( NSSortDescriptor *item, NSUInteger index) {
                       if ( index == 0 ) [[item.key should] equal:@"keyA"];
                       if ( index == 1 ) [[item.key should] equal:@"keyB"];
                   }];
                   return nil;
               }
            ];
            [action queryWithFetchTemplate:__fetchTemplate withParams:replaceWith orderedByKeys:@"keyA", @"keyB", nil];
        });




        it(@"Query specified Entity using one specified Fetch Template name, replacing data with dictionary"
                @"ordering by array of sort descriptors", ^{
            NSDictionary *replaceWith = @{@"anKey": @"anValue"};
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {

                   [[params[0] should] equal:__fetchTemplate];
                   [[params[1] should] equal:replaceWith];
                   [params[2] eachWithIndex:^( NSSortDescriptor *item, NSUInteger index) {
                       if ( index == 0 ) [[item.key should] equal:@"keyA"];
                       if ( index == 1 ) [[item.key should] equal:@"keyB"];
                   }];
                   return nil;
               }
            ];
            [action queryWithFetchTemplate:__fetchTemplate withParams:replaceWith sortDescriptors:@[
                    [NSSortDescriptor sortDescriptorWithKey:@"keyA" ascending:YES],
                    [NSSortDescriptor sortDescriptorWithKey:@"keyB" ascending:YES]
            ]];
        });




        it(@"Should query specified Entity using one custom NSPredicate", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {

                   [[params[3] should] beKindOfClass:[NSPredicate class]];
                   return nil;
               }

            ];
            [action queryWithPredicate:[NSPredicate new]];
        });




        it(@"Should query specified Entity using one custom NSPredicate and specified key", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {

                   [[params[3] should] beKindOfClass:[NSPredicate class]];
                   [params[2] each:^( NSSortDescriptor *item ) {
                       [[item.key should] equal:@"_key_"];
                   }];
                   return nil;
               }

            ];
            [action queryWithPredicate:[NSPredicate new] orderByKey:@"_key_"];
        });




        it(@"Should query specified Entity using one custom NSPredicate and specified keys", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {

                   [[params[3] should] beKindOfClass:[NSPredicate class]];
                   [params[2] eachWithIndex:^( NSSortDescriptor *item, NSUInteger index) {
                       if ( index == 0 ) [[item.key should] equal:@"keyA"];
                       if ( index == 1 ) [[item.key should] equal:@"keyB"];
                   }];
                   return nil;
               }

            ];
            [action queryWithPredicate:[NSPredicate new] orderedByKeys:@"keyA", @"keyB", nil];
        });




        it(@"Should query specified Entity using one custom NSPredicate and sort descriptors", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {

                   [[params[3] should] beKindOfClass:[NSPredicate class]];
                   [params[2] eachWithIndex:^( NSSortDescriptor *item, NSUInteger index) {
                       if ( index == 0 ) [[item.key should] equal:@"keyA"];
                       if ( index == 1 ) [[item.key should] equal:@"keyB"];
                   }];
                   return nil;
               }

            ];
            [action queryWithPredicate:[NSPredicate new] sortDescriptors:@[
                    [NSSortDescriptor sortDescriptorWithKey:@"keyA" ascending:YES],
                    [NSSortDescriptor sortDescriptorWithKey:@"keyB" ascending:YES]
            ]];
        });
    });

    ////////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// /////////

    context(@"Query Call Manager", ^{

        it(@"Final method should call manager", ^{
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wundeclared-selector"

            // Stub the manager to receive internal call.
            [manager stub:@selector(performDatabaseAction:) withArguments:action];
            [[manager should] receive:@selector(performDatabaseAction:) withArguments:action];

            [action queryWithFetchTemplate:__fetchTemplate withParams:[NSDictionary new] sortDescriptors:@[
                    [NSSortDescriptor sortDescriptorWithKey:@"keyA" ascending:YES],
                    [NSSortDescriptor sortDescriptorWithKey:@"keyB" ascending:YES]
            ]                    predicate:[NSPredicate new]];

            #pragma clang diagnostic pop
        });

    });

    ////////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// /////////

    context(@"Remove Data", ^{

        // All remove methods concatenate to call one final method, we'll stub and expect data from him
        // in all query tests.
        __block SEL finalMethod = @selector(deleteRecord:andCommit:);

        // Mock data object to delete.
        __block id dataObject = [KWMock mockForClass:[NSManagedObject class]];

        beforeEach(^{
            // Stub the final method.
            [action stub:finalMethod];
        });

        it(@"Should delete all Records from specified entityName", ^{
            // Stub internal query to return our data object.
            [action stub:@selector(queryWithFetchTemplate:) andReturn:@[dataObject]];

            // Delete all.
            [[action should] receive:finalMethod withArguments:dataObject, [KWValue valueWithBool:NO]];
            [action deleteAllRecords];
        });





        it(@"Shoul delete all records queried by the specified Fetch Template", ^{
            // Stub internal query to return our data object.
            [action stub:@selector(queryWithFetchTemplate:) andReturn:@[dataObject]
                                                        withArguments:__fetchTemplate];

            // Delete all.
            [[action should] receive:finalMethod withArguments:dataObject, [KWValue valueWithBool:NO]];
            [action deleteRecordsWithFetchTemplate:__fetchTemplate];
        });

        
        
        
        
        it(@"Should elete an record of database", ^{
            [[action should] receive:finalMethod withArguments:dataObject, [KWValue valueWithBool:NO]];
            [action deleteRecord:dataObject];
        });

    });
    
    ////////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// /////////
    
    context(@"Delete Call Manager", ^{

        it(@"Should delete an record of database, final call", ^{
            id dataObject = [KWMock mockForClass:[NSManagedObject class]];

            // Stub the manager to receive internal calls.
            [manager stub:@selector(deleteRecord:)];
            [manager stub:@selector(commit)];

            [[manager should] receive:@selector(deleteRecord:) withArguments:dataObject];
            [[manager should] receive:@selector(commit)];

            [action deleteRecord:dataObject andCommit:YES];
        });

    });

    ////////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// /////////

    context(@"Create Data", ^{

        // Mock data object to create
        __block id dataObject = [KWMock mockForClass:[NSManagedObject class]];

        it(@"Should create and return a new empty Record for specified Entity, final call", ^{
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wundeclared-selector"

            // Stub the manager to receive internal calls.
            [manager stub:@selector(createNewRecordFromAction:) andReturn:dataObject];
            [[manager should] receive:@selector(createNewRecordFromAction:) withArguments:action];

                id result = [action createNewRecord];

            [result shouldNotBeNil];
            [[result should] equal:dataObject];
            
            #pragma clang diagnostic pop
        });
        
    });

});

SPEC_END




