#import "Kiwi.h"

#import "NSArray+ObjectiveSugar.h"

#import "JPDBManager.h"
#import "JPDBManagerAction.h"

SPEC_BEGIN(ManagerAction)

describe(@"ManagerAction", ^{

    __block id manager;
    __block JPDBManagerAction *action;

    beforeEach(^{
        // Mock the manager.
        manager = [KWMock mockForClass:[JPDBManager class]];
        
        // Stub internal test.
        [manager stub:@selector(existAttribute:inEntity:) andReturn:[KWValue valueWithBool:YES]];

        // Build an action.
        action = [JPDBManagerAction initWithEntityName:nil andManager:manager];
    });

    ////////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// /////////

    context(@"Init", ^{

        it(@"Should init and store the manager", ^{
            [action shouldNotBeNil];
            [[action.manager should] equal:manager];
        });

        
        
        
        it(@"Should reset default values", ^{
            [action setStartFetchInLine:5 setLimitFetchResults:10];
            [[@(action.startFetchInLine) should] equal:@(5)];
            [[@(action.limitFetchResults) should] equal:@(10)];
            
            [action resetDefaultValues];

            [[@(action.startFetchInLine) should] equal:@(0)];
            [[@(action.limitFetchResults) should] equal:@(0)];
        });
        
    });
    
    ////////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// ///////// /////////
    
    context(@"Action Data", ^{

        it(@"Should apply Action data", ^{
            JPDBManagerAction *result;

            result = [action applyEntity:@"_ent_"];
            [[result should] equal:action];
            [[action.entityName should] equal:@"_ent_"];

            result = [action applyFetchTemplate:@"_fetch_"];
            [[result should] equal:action];
            [[action.fetchTemplate should] equal:@"_fetch_"];

            NSDictionary *emptyDictionary = [NSDictionary new];
            result = [action applyFetchReplaceWithDictionary:emptyDictionary];
            [[result should] equal:action];
            [[action.variablesListAndValues should] equal:emptyDictionary];

            NSPredicate *predicate = [NSPredicate new];
            result = [action applyPredicate:predicate];
            [[result should] equal:action];
            [[action.predicate should] equal:predicate];
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
            
            // Order require an entityName to be defined.
            [action applyEntity:@"_ent_"];
            
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

    #define __entityName @"_entity_"
    #define __fetchTemplate @"_fetchTemplate"
    
    context(@"Query", ^{

        // All query methods concatenate to call one final method, we'll stub and expect data from him
        // in all query tests.
        __block SEL finalMethod = @selector(queryWithFetchTemplate:withParams:sortDescriptors:predicate:);

        beforeEach(^{
            // Stub the final method.
            [action stub:finalMethod];
        });
        
        it(@"Should query all data of the specified Entity", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {
                   [[params[0] should] equal:__entityName];
                   return nil;
               }

            ];
            [action queryAllData];
        });

        
        
        
        it(@"Should query all data of the specified Entity ordering by specified key", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {
                   [[params[0] should] equal:__entityName];
                   [params[3] each:^( NSSortDescriptor *item ) {
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
                   [[params[0] should] equal:__entityName];
                   [params[3] eachWithIndex:^( NSSortDescriptor *item, NSUInteger index) {
                       if ( index == 0 ) [[item.key should] equal:@"keyA"];
                       if ( index == 1 ) [[item.key should] equal:@"keyB"];
                   }];
                   return nil;
               }
            ];
            [action queryAllDataOrderedByKeys:@"keyA", @"keyB"];
        });
        
        
        
        
        it(@"Should query specified Entity using one specified Fetch Template name", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {
                   [[params[0] should] equal:__entityName];
                   [[params[1] should] equal:__fetchTemplate];
                   return nil;
               }
            ];
            [action queryWithFetchTemplate:__fetchTemplate ];

        });




        it(@"Should query specified Entity using one specified Fetch Template name ordering with specific key", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {
                   [[params[0] should] equal:__entityName];
                   [[params[1] should] equal:__fetchTemplate];
                   [params[3] each:^( NSSortDescriptor *item ) {
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
                   [[params[0] should] equal:__entityName];
                   [[params[1] should] equal:__fetchTemplate];
                   [params[3] eachWithIndex:^( NSSortDescriptor *item, NSUInteger index) {
                       if ( index == 0 ) [[item.key should] equal:@"keyA"];
                       if ( index == 1 ) [[item.key should] equal:@"keyB"];
                   }];
                   return nil;
               }
            ];
            [action queryEntity:__entityName withFetchTemplate:__fetchTemplate orderedByKeys:@"keyA", @"keyB"];

        });




        it(@"Query specified Entity using one specified Fetch Template name, replacing data with dictionary", ^{
            NSDictionary *replaceWith = @{@"anKey": @"anValue"};
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {
                   [[params[0] should] equal:__entityName];
                   [[params[1] should] equal:__fetchTemplate];
                   [[params[2] should] equal:replaceWith];
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
                   [[params[0] should] equal:__entityName];
                   [[params[1] should] equal:__fetchTemplate];
                   [[params[2] should] equal:replaceWith];
                   [params[3] each:^( NSSortDescriptor *item ) {
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
                   [[params[0] should] equal:__entityName];
                   [[params[1] should] equal:__fetchTemplate];
                   [[params[2] should] equal:replaceWith];
                   [params[3] eachWithIndex:^( NSSortDescriptor *item, NSUInteger index) {
                       if ( index == 0 ) [[item.key should] equal:@"keyA"];
                       if ( index == 1 ) [[item.key should] equal:@"keyB"];
                   }];
                   return nil;
               }
            ];
            [action queryWithFetchTemplate:__fetchTemplate withParams:replaceWith
                    orderByKeys:@"keyA", @"keyB"];
        });




        it(@"Query specified Entity using one specified Fetch Template name, replacing data with dictionary"
                @"ordering by array of sort descriptors", ^{
            NSDictionary *replaceWith = @{@"anKey": @"anValue"};
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {
                   [[params[0] should] equal:__entityName];
                   [[params[1] should] equal:__fetchTemplate];
                   [[params[2] should] equal:replaceWith];
                   [params[3] eachWithIndex:^( NSSortDescriptor *item, NSUInteger index) {
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
                   [[params[0] should] equal:__entityName];
                   [[params[4] should] beKindOfClass:[NSPredicate class]];
                   return nil;
               }

            ];
            [action queryWithPredicate:[NSPredicate new]];
        });




        it(@"Should query specified Entity using one custom NSPredicate and specified key", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {
                   [[params[0] should] equal:__entityName];
                   [[params[4] should] beKindOfClass:[NSPredicate class]];
                   [params[3] each:^( NSSortDescriptor *item ) {
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
                   [[params[0] should] equal:__entityName];
                   [[params[4] should] beKindOfClass:[NSPredicate class]];
                   [params[3] eachWithIndex:^( NSSortDescriptor *item, NSUInteger index) {
                       if ( index == 0 ) [[item.key should] equal:@"keyA"];
                       if ( index == 1 ) [[item.key should] equal:@"keyB"];
                   }];
                   return nil;
               }

            ];
            [action queryEntity:__entityName withPredicate:[NSPredicate new] orderedByKeys:@"keyA", @"keyB"];
        });




        it(@"Should query specified Entity using one custom NSPredicate and sort descriptors", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {
                   [[params[0] should] equal:__entityName];
                   [[params[4] should] beKindOfClass:[NSPredicate class]];
                   [params[3] eachWithIndex:^( NSSortDescriptor *item, NSUInteger index) {
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
            [action deleteAllRecordsFromEntity:@"_entity_"];
        });





        it(@"Shoul delete all records queried by the specified Fetch Template", ^{
            // Stub internal query to return our data object.
            [action stub:@selector(queryWithFetchTemplate:) andReturn:@[dataObject]
           withArguments:@"_entity_", @"_template"];

            // Delete all.
            [[action should] receive:finalMethod withArguments:dataObject, [KWValue valueWithBool:NO]];
            [action deleteRecordsFromEntity:@"_entity_" withFetchTemplate:@"_template"];
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

            // Stub the manager to receive internal calls.
            [manager stub:@selector(createNewRecordForEntity:) andReturn:dataObject];
            [[manager should] receive:@selector(createNewRecordForEntity:) withArguments:@"_entity_"];


            id result = [action createNewRecordForEntity:@"_entity_"];
            [[action.entityName should] equal:@"_entity_"];

            [result shouldNotBeNil];
            [[result should] equal:dataObject];
        });
        
    });

});

SPEC_END