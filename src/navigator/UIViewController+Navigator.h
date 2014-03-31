/*
 * Created by Paulo Oliveira at 2014. JUMP version 2, Copyright (c) 2014 - SEQOY.org and Paulo Oliveira ( http://www.seqoy.org )
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
#import <UIKit/UIKit.h>

@class JPNavigator;

@interface UIViewController (Navigator)

/**
 * Load and display the view controller with a pattern that matches the URL.
 */
-(void)openNavigationURL:(NSString*)URL;

/**
 * Load and display the view controller with a pattern that matches the URL.
 *
 * @param handler An codeblock that will receive the initialized view controller to some extra configuration.
 */
-(void)openNavigationURL:(NSString*)url withConfigureHandler:(void (^)(UIViewController* viewController))handler;

/**
 * If you're using an customised navigation controller, override this method and return it here.
 * The default implementation returns the default navigation controller embedded in the UIViewController
 */
-(UINavigationController*)designatedNavigationController;

/**
 *  Convenient method to return the singleton version of the navigator.
 *
 *  @return An singleton JPNavigator instance.
 */
-(JPNavigator *)navigator;

@end
