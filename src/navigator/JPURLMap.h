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
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JPURLMap : NSObject

/**
 * Adds a URL pattern which will create and present a view controller when loaded.
 *
 *      @param URL URL  Pattern to match and create the view controller.
 *      @param target   Target can be either a Class which is a subclass of UIViewController, or an object which
 *                      implements a method that returns a UIViewController instance. If you use an object, the
 *                      selector will be called with arguments extracted from the URL, and the view controller that
 *                      you return will be the one that is presented.
 *      @param selector The selector to perform on the object. If there aren't enough parameters in the pattern
 *                      then the excess parameters in the selector will be nil.
 */
- (void)from:(NSString*)URL toViewController:(id)target selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and present a view controller when loaded.
 *
 *      @param URL URL  Pattern to match and create the view controller.
 *      @param identifier An identifier string that uniquely identifies the view controller in the storyboard file.
 *                        You set the identifier for a given view controller in Interface Builder when configuring
 *                        the storyboard file.
 *      @param selector The selector to perform on the object. If there aren't enough parameters in the pattern
 *                      then the excess parameters in the selector will be nil.
 */
- (void)from:(NSString*)URL toStoryboardIdentifier:(NSString*)identifier selector:(SEL)selector;

/**
 * Adds a URL pattern which will create and present a view controller when loaded.
 *
 *      @param URL URL  Pattern to match and create the view controller.
 *      @param identifier An identifier string that uniquely identifies the view controller in the storyboard file.
 *                        You set the identifier for a given view controller in Interface Builder when configuring
 *                        the storyboard file.
 *      @param storyboard The name of the storyboard resource file without the filename extension.
 *      @param selector The selector to perform on the object. If there aren't enough parameters in the pattern
 *                      then the excess parameters in the selector will be nil.
 *
 */
- (void)from:(NSString*)URL toStoryboardIdentifier:(NSString*)identifier usingStoryboard:(NSString*)storyboard selector:(SEL)selector;

/**
 * Gets or creates the object with a pattern that matches the URL.
 *
 * Object mappings are checked first, and if no object is bound to the URL then pattern
 * matching is used to create a new object. A matching string must exactly match all of the static portions
 * of the pattern and provide values for each of the parameters.
 */
-(id)objectForURL:(NSString*)URL;

- (NSString *)description;

@end




/**
 * Model object that store data for an mapped URL.
 */
#pragma mark - JPURLMapDescriptor
@class SOCPattern;
@interface JPURLMapDescriptor : NSObject

@property (strong) SOCPattern *pattern;
@property (assign) SEL selector;
@property (assign) Class class;
@property (strong) NSString* identifier;
@property (strong) NSString* storyboard;

- (NSString *)description;

@end

