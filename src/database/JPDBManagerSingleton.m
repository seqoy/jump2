/*
 * Created by Paulo Oliveira at 2011. JUMP version 2, Copyright (c) 2014 - seqoy.org and Paulo Oliveira ( http://www.seqoy.org )
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
#import "JPDBManagerSingleton.h"
#import "JPSynthetizeSingleton.h"
#import "JPDBManagerAction.h"

@implementation JPDBManagerSingleton

//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// 
#pragma mark -
#pragma mark Protect Init Methods.
//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// 
+ (id)init {
    [NSException raise:JPDBInvalidInitiator
                format:@"Can't initialize an Singleton Class. Use [%@ sharedInstance] instead.", NSStringFromClass([self class])];
    return nil;
}

//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// ///
+ (id)initAndStartCoreData {
    return [self init];
}

//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// 
#pragma mark -
#pragma mark Synthesize Singleton Pattern Methods.
//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// 
JPSynthetizeSingleton(JPDBManagerSingleton)


//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// 
#pragma mark -
#pragma mark Database Action Methods. 
//// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// //// 
// This method is called from the JPDBManagerAction as an private call. On Singleton is synchronized to be thread safe.
- (id)performDatabaseAction:(JPDBManagerAction *)anAction {
    return [super performSelector:@selector(performThreadSafeDatabaseAction:) withObject:anAction];
}
@end
