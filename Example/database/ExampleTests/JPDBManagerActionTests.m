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
        action = [JPDBManagerAction initWithManager:manager];
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
            [[action.entity should] equal:@"_ent_"];

            result = [action applyFetchTemplate:@"_fetch_"];
            [[result should] equal:action];
            [[action.fetchTemplate should] equal:@"_fetch_"];

            NSDictionary *emptyDictionary = [NSDictionary new];
            result = [action applyFetchReplaceWithDictionary:emptyDictionary];
            [[result should] equal:action];
            [[action.variablesListAndValues should] equal:emptyDictionary];

            result = [action applyFetchReplaceWithVariables:@"value", @"key", nil];
            [[result should] equal:action];
            [result.variablesListAndValues shouldNotBeNil];
            NSString *assigned = action.variablesListAndValues[@"key"];
            [[assigned should] equal:@"value"];

            NSPredicate *predicate = [NSPredicate new];
            result = [action applyPredicate:predicate];
            [[result should] equal:action];
            [[action.predicate should] equal:predicate];
        });
        
        
        
        

        it( @"Should run the action", ^{
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
            
            // Order require an entity to be defined.
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
        __block SEL finalMethod = @selector(queryEntity:withFetchTemplate:replaceFetchWithDictionary:
                arrayOfSortDescriptors:customPredicate:);

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
            [action queryAllDataFromEntity:__entityName];
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
            [action queryAllDataFromEntity:__entityName orderWithKey:@"_key_"];
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
            [action queryAllDataFromEntity:__entityName orderWithKeys:@"keyA", @"keyB", nil];
        });
        
        
        
        
        it(@"Should query specified Entity using one specified Fetch Template name", ^{
            [action stub:finalMethod

               withBlock:^id(NSArray *params) {
                   [[params[0] should] equal:__entityName];
                   [[params[1] should] equal:__fetchTemplate];
                   return nil;
               }
            ];
            [action queryEntity:__entityName withFetchTemplate:__fetchTemplate];

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
            [action queryEntity:__entityName withFetchTemplate:__fetchTemplate orderWithKey:@"_key_"];

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
            [action queryEntity:__entityName withFetchTemplate:__fetchTemplate orderWithKeys:@"keyA", @"keyB", nil];

        });


    });
    
});

SPEC_END