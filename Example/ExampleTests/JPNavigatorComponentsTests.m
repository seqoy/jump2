// JUMP
#import "JPNavigatorFactoryInterface.h"
#import "JPTestViewController.h"

// Kiwi
#import "Kiwi.h"


SPEC_BEGIN(NavigatorComponents)

describe(@"Navigator", ^{
    
    context(@"Map", ^{
        
        __block JPURLMap* map;
        
        // Bootstrap ///////////// ////////// ////////// ////////// ////////// ////////// //////////
        
        beforeAll(^{
            // Build the map.
            map = [JPURLMap new];
            
            //
            // Map some patterns.
            //
            
            // From class.
            [map from:@"test://fromClass/:value"
                            toViewController:[JPTestViewController class]
                                    selector:@selector(initWithValue:)
             ];
            
            // From storyboard.
            [map from:@"test://fromStoryboard/:value"
                             toStoryboardIdentifier:@"testController"
                                    usingStoryboard:@"TestNavigator"
                                            selector:@selector(setValue:)
             ];
        });
        
        // Tests ///////////// ////////// ////////// ////////// ////////// ////////// //////////

        it(@"Should build the map", ^{
            [map shouldNotBeNil];
            [[map should] beKindOfClass:[JPURLMap class]];
        });
        
        it(@"Should return an view controller from class using init method", ^{
            // Perform the pattern.
            JPTestViewController *result = [map objectForURL:@"test://fromClass/charge_value"];
            
            [result shouldNotBeNil];
            [[result should] beKindOfClass:[JPTestViewController class]];
            [[[result value] should] equal:@"charge_value"];
        });
        
        it(@"Should return an view controller from Storyboard and set value", ^{
            // Perform the pattern.
            JPTestViewController *result = [map objectForURL:@"test://fromStoryboard/charge_value"];
            
            [result shouldNotBeNil];
            [[result should] beKindOfClass:[JPTestViewController class]];
            [[[result value] should] equal:@"charge_value"];
        });
        
    });

    context(@"Factory", ^{
        
        __block id mapFactory;
        __block JPURLMap* map;
        
        // Bootstrap ///////////// ////////// ////////// ////////// ////////// ////////// //////////
        
        beforeAll(^{
            // Build the map.
            map = [JPURLMap new];
            
            // Mock the factory interface.
            mapFactory = [KWMock mockForProtocol:@protocol(JPNavigatorFactoryInterface)];
            [mapFactory stub:@selector(buildMap) andReturn:map];
        });
        
        // Tests ///////////// ////////// ////////// ////////// ////////// ////////// //////////
        
        it(@"Should conform with factory protocol", ^{
             [mapFactory shouldNotBeNil];
            [[mapFactory should] conformToProtocol:@protocol(JPNavigatorFactoryInterface)];
        });
        
        it(@"Should return the map", ^{
            [[[mapFactory buildMap] should] equal:map];
         });
    });
    
});

SPEC_END