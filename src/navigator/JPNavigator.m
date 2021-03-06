/*
 * Created by Paulo Oliveira at 2014. JUMP version 2, Copyright (c) 2014 - seqoy.org and Paulo Oliveira ( http://www.seqoy.org )
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
#import "JPNavigator.h"
#import "JPSynthetizeSingleton.h"
#import "NSArray+ObjectiveSugar.h"

@implementation JPNavigator


#pragma mark - Init Methods.
- (id)init {
    self = [super init];
    if (self) {
        self.listeners = [NSMutableArray new];
    }
    return self;
}

// Take an factory that conform with the JPNavigatorFactoryInterface interface and build it.
+ (instancetype)configureFromFactory:(id <JPNavigatorFactoryInterface>)factory {
    return [self configureWithBlock:^JPURLMap *() {
        return [factory buildMap];
    }];
}

+ (instancetype)configureWithBlock:(JPURLMap * (^)())configBlock {
    [JPNavigator navigator].maps = configBlock();
    return [JPNavigator navigator];
}

JPSynthetizeSingleton(JPNavigator)

+ (JPNavigator *)navigator {
    return [self sharedInstance];
}





#pragma mark - Custom subscripting.
- (id)objectForKeyedSubscript:(id)key {
    return [self viewControllerForURL:key];
}





#pragma mark - Controller Methods.
- (id)viewControllerForURL:(NSString *)URL {
    return [_maps objectForURL:URL];
}

// Load and display the view controller with a pattern that matches the URL.
- (UIViewController *)openNavigationURL:(NSString *)url {
    return [self openNavigationURL:url withConfigureHandler:nil];
}

// Load and display the view controller with a pattern that matches the URL.
- (id)openNavigationURL:(NSString *)url
   withConfigureHandler:(void (^)(UIViewController *viewController))handler {

    if (self.navigationController == nil )
        [NSException raise:NSInternalInconsistencyException
                    format:NSLocalizedString(@"nav_load", @"An navigation controller must be loaded!")];

    // Load the View Controller.
    UIViewController *viewController = self[url];

    // If can't load the View Controller.
    if (viewController == nil )
        [NSException raise:NSInternalInconsistencyException
                    format:NSLocalizedString(@"controller_not_found", @"No View Controller was found for the URL: %@"), url];


    // Call listeners.
    [self.listeners each:^(id <JPNavigatorListener> listener) {
        if ([listener conformsToProtocol:@protocol(JPNavigatorListener)]) {
            [listener navigator:self willOpenViewController:viewController];
        }
    }];

    // Call Configure Handler, if defined.
    if (handler)
        handler(viewController);

    // Push it to the Navigation.
    [self.navigationController pushViewController:viewController animated:YES];

    // Return it.
    return viewController;
}

@end
