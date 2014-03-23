#import <jump2/JPDBManagerAction.h>
#import <ObjectiveSugar/NSArray+ObjectiveSugar.h>
#import "Kiwi.h"
#import "JPDBManagerSingleton.h"
#import "NSManagedObject+JPDatabase.h"

// Fake object.
@interface Entity : NSManagedObject
+ (void)injectManager:(id)anManager;
@end

// We're hacking the class method manager to return an mocked and stubbed manager.
@implementation Entity

static JPDBManagerSingleton *_manager;

+(void)injectManager:(id)anManager {
    _manager = anManager;
}

+(JPDBManagerSingleton *)manager  {
    return _manager;
}

@end

SPEC_BEGIN(ManagerAction)

describe(@"Managed Object", ^{

    __block id entity;
    __block id mockedManager;

    #define __entityName NSStringFromClass([Entity class])

    beforeEach(^{

        // Mock some entity.
        entity = [KWMock mockForClass:[NSEntityDescription class]];
        [entity stub:@selector(name) andReturn:__entityName];

        // Mock the manager.
        mockedManager = [KWMock mockForClass:[JPDBManager class]];

        // Stub some methods.
        [mockedManager stub:@selector(entity:) andReturn:entity withArguments:__entityName];
        [mockedManager stub:@selector(existEntity:) andReturn:[KWValue valueWithBool:YES] withArguments:__entityName];
        [mockedManager stub:@selector(existAttribute:inEntity:) andReturn:[KWValue valueWithBool:YES]];

        [mockedManager stub:@selector(getDatabaseActionForEntity:)
                  andReturn:[JPDBManagerAction initWithEntityName:__entityName andManager:mockedManager]
              withArguments:__entityName];


        // Inject it.
        [Entity injectManager:mockedManager];

    });

    /////////////// ///////////////// ///////////////// ///////////////// ///////////////// ///////////////// /////////

    context(@"Entity Info", ^{

        it(@"Should return the entity name", ^{
            [[[Entity entity] should] equal:__entityName];

        });



        it(@"Should return an configured action", ^{
            JPDBManagerAction *action = [Entity getAction];
            [action shouldNotBeNil];
            [[[action entityName] should] equal:__entityName];
            [[[action entity].name should] equal:__entityName];
            [action.manager shouldNotBeNil];
        });



        it(@"Should count how many object this entity has", ^{

            // Manager return 2 objects.
            [mockedManager stub:@selector(performDatabaseAction:) andReturn:@[any(), any()] withArguments:any()];

            [[@([Entity count]) should] equal:@2];
        });



        it(@"Should count with specific query", ^{
            NSString *predicate = @"predicate == test";

            [mockedManager stub:@selector(performDatabaseAction:)

               withBlock:^id(NSArray *params) {
                   JPDBManagerAction *action = params[0];
                   [[[action predicate].predicateFormat should] equal:predicate];

                   // Return 4 objects.
                   return @[any(), any(), any(), any()];
               }
            ];
            
            // Test it.
            [[@([Entity countWhere:predicate]) should] equal:@4];
        });

    });

    /////////////// ///////////////// ///////////////// ///////////////// ///////////////// ///////////////// /////////

    context(@"Query", ^{

        it(@"Query all data of this Entity", ^{

            // Manager return 2 objects.
            [mockedManager stub:@selector(performDatabaseAction:) andReturn:@[any(), any()] withArguments:any()];

            NSArray * result = [Entity all];
            
            [[result should] haveCountOf:2];

        });




        it(@"Should query all data ordered by specified key", ^{
            [mockedManager stub:@selector(performDatabaseAction:)

                      withBlock:^id(NSArray *params) {
                          JPDBManagerAction *action = params[0];

                          [action.sortDescriptors each:^(NSSortDescriptor *item) {
                              [[item.key should] equal:@"_key_"];
                          }];

                          // Return 4 objects.
                          return @[any(),  any(), any()];
                      }
            ];

            NSArray * result =[Entity allOrderedBy:@"_key_"];

            
            [[result should] haveCountOf:3];

        });




        it(@"Should query all data ordered by specified keys", ^{
            [mockedManager stub:@selector(performDatabaseAction:)

                      withBlock:^id(NSArray *params) {
                          JPDBManagerAction *action = params[0];

                          [action.sortDescriptors eachWithIndex:^(NSSortDescriptor *item, NSUInteger index) {
                              if (index == 0) [[item.key should] equal:@"keyA"];
                              if (index == 1) [[item.key should] equal:@"keyB"];
                          }];

                          // Return 4 objects.
                          return @[any(),  any(), any(), any()];
                      }
            ];

            NSArray * result =[Entity allOrderedByKeys:@"keyA", @"keyB", nil];

            [[result should] haveCountOf:4];

        });




        it(@"Should query this Entity using one specific query", ^{
            NSString *query = @"format == %@";
            NSString *param = @"param";

            [mockedManager stub:@selector(performDatabaseAction:)

                      withBlock:^id(NSArray *params) {
                          JPDBManagerAction *action = params[0];

                          NSString * where = @"format == \"param\"";

                          [[[action predicate].predicateFormat should] equal:where];

                          // Return 4 objects.
                          return @[any(), any(), any(), any()];
                      }
            ];

            NSArray * result = [Entity where:query, param];

            [[result should] haveCountOf:4];

        });




        it(@"Should query one specific query and specific key", ^{
            NSString *query = @"format == %@";
            NSString *param = @"param";

            [mockedManager stub:@selector(performDatabaseAction:)

                      withBlock:^id(NSArray *params) {
                          JPDBManagerAction *action = params[0];

                          [action.sortDescriptors each:^(NSSortDescriptor *item) {
                              [[item.key should] equal:@"_key_"];
                          }];

                          NSString * where = @"format == \"param\"";
                          [[[action predicate].predicateFormat should] equal:where];

                          // Return 3 objects.
                          return @[any(),  any(), any()];
                      }
            ];

            NSArray * result =[Entity usingOrder:@"_key_" where:query, param];

            [[result should] haveCountOf:3];

        });




        it(@"Should find this Entity using one specific query", ^{
            NSString *predicate = @"id == 1";
            Entity *object      = [Entity new];

            [mockedManager stub:@selector(performDatabaseAction:)

                      withBlock:^id(NSArray *params) {
                          JPDBManagerAction *action = params[0];

                          [[[action predicate].predicateFormat should] equal:predicate];

                          // Return 1 object.
                          return @[object];
                      }
            ];

            id result = [Entity find:predicate];

            [[result should] equal:object];

        });




        it(@"Should query using block", ^{
            NSString *predicate = @"predicate == test";

            [mockedManager stub:@selector(performDatabaseAction:)

                      withBlock:^id(NSArray *params) {
                          JPDBManagerAction *action = params[0];

                          [[[action predicate].predicateFormat should] equal:predicate];

                          // Return 3 objects.
                          return @[any(),  any(), any()];
                      }
            ];

            id result = [Entity query:^(JPDBManagerAction *query) {
                [query applyPredicate:[NSPredicate predicateWithFormat:predicate]];
            }];

            [[result should] haveCountOf:3];

        });
    });

    /////////////// ///////////////// ///////////////// ///////////////// ///////////////// ///////////////// /////////

    context(@"Remove", ^{

        it(@"Should delete this object", ^{
            Entity *object = [Entity new];

            [mockedManager stub:@selector(deleteRecord:) withArguments:object];
            [[mockedManager should] receive:@selector(deleteRecord:) withArguments:object];
            [object delete];
        });




        it (@"Should delete all objects of this entity", ^{

            // Data object to delete.
            Entity * dataObject = [Entity new];

            // Mock manager to return this data object to delete.
            [mockedManager stub:@selector(performDatabaseAction:) andReturn:@[dataObject, dataObject]];

            // Mock manager to delete this object.
            [mockedManager stub:@selector(deleteRecord:) withArguments:dataObject];
            [[mockedManager should] receive:@selector(deleteRecord:) withCount:2 arguments:dataObject];

            // Test it.
            [Entity deleteAll];

        });
    });

    /////////////// ///////////////// ///////////////// ///////////////// ///////////////// ///////////////// /////////

    context(@"Create", ^{

        it(@"Should create a new instance of this Entity", ^{

            // Data object to create.
            Entity * dataObject = [Entity new];

            // Stub the manager to receive internal calls.
            [mockedManager stub:@selector(createNewRecordFromAction:) andReturn:dataObject];
            [[mockedManager should] receive:@selector(createNewRecordFromAction:) andReturn:dataObject];

            Entity *result = [Entity create];

            [result shouldNotBeNil];
            [[result should] equal:dataObject];


        });

    });

    /////////////// ///////////////// ///////////////// ///////////////// ///////////////// ///////////////// /////////

    context(@"Commit", ^{

        it(@"Should commit data for this Entity", ^{

            // Stub the manager to receive internal calls.
            [mockedManager stub:@selector(commit)];
            [[mockedManager should] receive:@selector(commit)];

            // Test it.

            [Entity save];

        });

    });

});

SPEC_END