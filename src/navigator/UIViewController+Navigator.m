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
#import "UIViewController+Navigator.h"
#import "JPNavigator.h"

@implementation UIViewController (Navigator)


- (void)openNavigationURL:(NSString *)URL {
    [self openNavigationURL:URL withConfigureHandler:nil];
}

- (void)openNavigationURL:(NSString *)url
     withConfigureHandler:(void (^)(UIViewController *viewController))handler {

    // Attach an Navigation Controller.
    [self.navigator setNavigationController:[self designatedNavigationController]];

    // Open it.
    [self.navigator openNavigationURL:url withConfigureHandler:handler];
}

- (UINavigationController *)designatedNavigationController {
    return self.navigationController;
}

- (JPNavigator *)navigator {
    return [JPNavigator navigator];
}


@end
