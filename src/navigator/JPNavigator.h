/*
 * Created by Paulo Oliveira, 2014. JUMP version 2, Copyright (c) 2014 - seqoy.org and Paulo Oliveira ( http://www.seqoy.org )
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
#import "JPURLMap.h"
#import "JPNavigatorFactoryInterface.h"

@protocol JPNavigatorListener;

@interface JPNavigator : NSObject

/**
 * Take an factory that conform with the JPNavigatorFactoryInterface interface and build
 * an the URL maps from it.
 */
+ (instancetype)configureFromFactory:(id <JPNavigatorFactoryInterface>)factory;

/**
 * Convenient method to configure the Navigator using an block. The block must
 * return an configured JPURLMap.
 * Example:
 * <tt>
 * [JPNavigator configureWithBlock:^JPURLMap* () {
 *      JPURLMap *map = [JPURLMap new];
 *      [map from:@"test://fromClass/:value" toViewController:[TestController class] selector:@selector(initWithValue:)];
 *      return map;
 * }];
 * </tt>
 */
+ (instancetype)configureWithBlock:(JPURLMap * (^)())configBlock;

/**
 * An associated UINavigationController. JPNavigator doesn't control the navigation stack, 
 * you must assign an UINavigationController in order to push view controllers automatically.
 */
@property(strong) UINavigationController *navigationController;

/**
 * An array of objects that conforms with the <tt>JPNavigatorListener</tt> protocol and receive
 * information about the Navigator operation. You must add and remove your listeners directly
 * on the array. Example:
 *          <tt>[navigationController.listeners addObject:self];
 *          </tt>
 */
@property(strong) NSMutableArray *listeners;

/**
 * Return an Singleton Instance of this class.
 */
+ (JPNavigator *)navigator;

/**
 * The URL map used to translate between URLs and view controllers.
 */
@property(strong) JPURLMap *maps;

/**
 * Gets a view controller for the URL without opening it.
 *
 * @return The view controller mapped to URL.
 */
- (id)viewControllerForURL:(NSString *)URL;

/**
 * Add dictionary style subscripting to the navigator, equivalent to the 'viewControllerForURL:' method.
 * Example:
 *      UIViewController* vc = navigator[@"url://viewController"];
 *
 */
- (id)objectForKeyedSubscript:(id)key;

/**
 * Load and display the view controller with a pattern that matches the URL.
 *
 * @return The view controller mapped to URL.
 */
- (id)openNavigationURL:(NSString *)url;

/**
 * Load and display the view controller with a pattern that matches the URL.
 * 
 * @param handler An codeblock that will receive the initialized view controller to some extra configuration.
 * @return The view controller mapped to URL.
 */
- (id)openNavigationURL:(NSString *)url withConfigureHandler:(void (^)(UIViewController *viewController))handler;

@end

/////////// /////////// /////////// /////////// /////////// /////////// /////////// /////////// /////////// /////////// ///////////

#pragma mark - JPNavigatorListener Protocol

@protocol JPNavigatorListener <NSObject>

/**
 * The URL is about to be opened in a controller.
 */
- (void)navigator:(JPNavigator *)navigator willOpenViewController:(UIViewController *)controller;


@end
