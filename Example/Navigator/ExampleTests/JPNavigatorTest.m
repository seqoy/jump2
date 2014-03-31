// JUMP
#import "JPNavigator.h"
#import "JPTestViewController.h"

// Kiwi
#import "Kiwi.h"

SPEC_BEGIN(Navigator)

describe(@"Navigator", ^{
    
    __block JPNavigator *navigator;
    
    context(@"Singleton", ^{
       
        it(@"Should build an singleton", ^{
            navigator = [JPNavigator navigator];
            
            [navigator shouldNotBeNil];
            [[navigator should] beKindOfClass:[JPNavigator class]];
        });

    });
    
    context(@"Navigation", ^{
        
        // Bootstrap ///////////// ////////// ////////// ////////// ////////// ////////// //////////
        
        beforeAll(^{
            // Build and configure some map.
            JPURLMap *map = ({
                JPURLMap *map = [JPURLMap new];
                [map from:@"test://fromStoryboard/:value"
                                               toStoryboardIdentifier:@"testController"
                                                      usingStoryboard:@"TestNavigator"
                                                             selector:@selector(setValue:)];
                map;
            });
            
            // Mock an factory and stub an factory.
            id factory = [KWMock mockForProtocol:@protocol(JPNavigatorFactoryInterface)];
            [factory stub:@selector(buildMap) andReturn:map];
            
            //
            // Configure the Navigator from Factory, this also will cover the
            // 'configureWithBlock:' method, since one call the other internally.
            //
            navigator = [JPNavigator configureFromFactory:factory];
            
            // Some assertions before go...
            [navigator shouldNotBeNil];
            [[navigator maps] shouldNotBeNil];
            [[[navigator maps] should] equal:map];
        });
        
        afterEach(^{
            [navigator.listeners removeAllObjects];
            navigator.navigationController = nil;
        });
        
         // Tests ///////////// ////////// ////////// ////////// ////////// ////////// //////////
       
        it(@"Should retrieve a view controller for the URL without opening it", ^{
            // Perform.
            JPTestViewController* result = [navigator viewControllerForURL:@"test://fromStoryboard/charge_value"];
            
            [result shouldNotBeNil];
            [[result should] beKindOfClass:[JPTestViewController class]];
            [[[result value] should] equal:@"charge_value"];
        });

        it(@"Should retrieve a view controller using custom subscripting", ^{
            // Perform.
            JPTestViewController* result = navigator[@"test://fromStoryboard/charge_value"];

            [result shouldNotBeNil];
            [[result should] beKindOfClass:[JPTestViewController class]];
            [[[result value] should] equal:@"charge_value"];
        });

        it(@"Should load and display the view controller and configure it", ^{
            
            // Mock and stub navigation controller. /////// ////////// ////////// //////////
            
            UINavigationController *nav = [KWMock mockForClass:[UINavigationController class]];
            [nav stub:@selector(pushViewController:animated:) withBlock:^id(NSArray *params) {
                id controller = params[0];
                [controller shouldNotBeNil];
                [[controller should] beKindOfClass:[JPTestViewController class]];
                return nil;
            }];
            
            
            // Attach it.
            [navigator setNavigationController:nav];
            [[[navigator navigationController] should] equal:nav];
            
            
            // Mock and Stub listener. /////// ////////// ////////// //////////

            id listener = [KWMock mockForProtocol:@protocol(JPNavigatorListener)];
            [listener stub:@selector(navigator:willOpenViewController:) withBlock:^id(NSArray *params) {
                [[params[0] should] equal:navigator];
                id controller = params[1];
                [controller shouldNotBeNil];
                [[controller should] beKindOfClass:[JPTestViewController class]];
                return nil;
            }];
            
            
            // Attach listener.
            [[navigator listeners] addObject:listener];
            [[[navigator listeners][0] should] equal:listener];
            
            
            // Perform. /////// ////////// ////////// ////////// /////// ////////// ////////// //////////
            JPTestViewController* result = [navigator
                                                       openNavigationURL:@"test://fromStoryboard/charge_value"
                                                    withConfigureHandler:^(UIViewController *handler) {
                                                               [(JPTestViewController*)handler setValue:@"charge_value_handled"];
                                                           }
                                            ];
            
            [result shouldNotBeNil];
            [[result should] beKindOfClass:[JPTestViewController class]];
            [[[result value] should] equal:@"charge_value_handled"];
        });
    });
    
    context(@"Exceptions", ^{
        
        // Bootstrap ///////////// ////////// ////////// ////////// ////////// ////////// //////////
        
        beforeAll(^{
            navigator = [JPNavigator navigator];
        });
        
        // Tests ///////////// ////////// ////////// ////////// ////////// ////////// //////////
        it(@"Should fail without an attached Navigation Controller", ^{
            
            // Run the controlled exception.
            [[theBlock(^{
                [navigator openNavigationURL:@"test://fromStoryboard/charge_value"];
            })
              
              should] raiseWithName:NSInternalInconsistencyException];
        });
        
        it(@"Should fail trying to retrieve an View Controller that doesn't exist", ^{
            
            // Mock navigation controller.
            UINavigationController *nav = [KWMock mockForClass:[UINavigationController class]];
            [navigator setNavigationController:nav];

            // Run the controlled exception.
            [[theBlock(^{
                [navigator openNavigationURL:@"test://fromUnknownPattern"];
            })
              
              should] raiseWithName:NSInternalInconsistencyException];

        });
    });
});

SPEC_END




