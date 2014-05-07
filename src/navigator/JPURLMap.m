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
#import "JPURLMap.h"
#import "SOCKit.h"
#import "NSMutableArray+ObjectiveSugar.h"



#pragma mark - JPURLMapDescriptor
@implementation JPURLMapDescriptor

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"[%@: ", NSStringFromClass([JPURLMapDescriptor class])];
    [description appendFormat:@"pattern: %@", self.pattern];
    [description appendFormat:@", selector: %@", NSStringFromSelector(self.selector)];
    [description appendFormat:@", class: %@", NSStringFromClass(self.class)];
    [description appendFormat:@", identifier: %@", self.identifier];
    [description appendFormat:@", storyboard: %@", self.storyboard];
    [description appendString:@"]"];
    return description;
}

@end




#pragma mark - JPURLMap Implementation.
@interface JPURLMap () {
    NSMutableArray *_objectPatterns;
}
@end

@implementation JPURLMap

- (id)init {
    self = [super init];
    if (self) {
        _objectPatterns = [NSMutableArray new];
    }
    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"[%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"patterns: %@", _objectPatterns];
    [description appendString:@"]"];
    return description;
}




#pragma mark - Map Methods.
- (void)from:(NSString *)URL toViewController:(id)target selector:(SEL)selector {
    if (selector == nil)
        [NSException raise:NSInvalidArgumentException
                    format:NSLocalizedString(@"need_selector", @"You must pass an selector!")];

    [self from:URL toViewController:target toStoryboardIdentifier:nil usingStoryboard:nil selector:selector];
}

- (void)from:(NSString *)URL toStoryboardIdentifier:(NSString *)identifier selector:(SEL)selector {
    [self from:URL toStoryboardIdentifier:identifier usingStoryboard:identifier selector:selector];
}

- (void)   from:(NSString *)URL toStoryboardIdentifier:(NSString *)identifier
usingStoryboard:(NSString *)storyboard selector:(SEL)selector {
    [self from:URL toViewController:nil toStoryboardIdentifier:identifier usingStoryboard:storyboard selector:selector];
}

- (void)   from:(NSString *)URL toViewController:(id)target toStoryboardIdentifier:(NSString *)identifier
usingStoryboard:(NSString *)storyboard selector:(SEL)selector {

    JPURLMapDescriptor *mapDescriptor = [JPURLMapDescriptor new];

    // Set properties.
    mapDescriptor.pattern = [SOCPattern patternWithString:URL];
    mapDescriptor.selector = selector;
    mapDescriptor.identifier = identifier;
    mapDescriptor.storyboard = storyboard;
    mapDescriptor.class = target;

    // Store it.
    [_objectPatterns push:mapDescriptor];
}



#pragma mark - Build Methods.
- (id)objectForURL:(NSString *)URL {

    // Look for matching pattern.
    for (JPURLMapDescriptor *mapDescriptor in _objectPatterns) {

        // Test if matches.
        if ([mapDescriptor.pattern stringMatches:URL]) {

            // Using...
            return mapDescriptor.class
                    ? [self viewControllerFromClassUsingMap:mapDescriptor andURL:URL]           // Class.
                    : [self viewControllerFromStoryboardUsingMap:mapDescriptor andURL:URL];     // Storyboard.
        }
    }

    return nil;
}

- (id)viewControllerFromClassUsingMap:(JPURLMapDescriptor *)map andURL:(NSString *)URL {

    // Perform it.
    id object = [map.pattern performSelector:map.selector
                                    onObject:map.class
                                sourceString:URL];

    // Returns an allocated, initialized and parameter setted object.
    return object;
}

- (id)viewControllerFromStoryboardUsingMap:(JPURLMapDescriptor *)map andURL:(NSString *)URL {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:map.storyboard bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:map.identifier];

    // If some method to perform, run it.
    if (map.selector != nil )
        [map.pattern performSelector:map.selector onObject:viewController sourceString:URL];

    // Returns an allocated, initialized and parameter setted object.
    return viewController;
}

@end
