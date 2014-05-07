/*
 * Copyright (c) 2011 - SEQOY.org and Paulo Oliveira ( http://www.seqoy.org )
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
#import "JPJSONProcesser.h"

////////////// ////////////// ////////////// ////////////// 
@implementation JPJSONProcesser

////////////// ////////////// ////////////// ////////////// 
+(void)raiseExceptionWithError:(NSError*)anError {
    NSException *e = [NSException exceptionWithName:NSStringFromClass([self class])
                                             reason:[anError localizedDescription]
                                           userInfo:[NSDictionary dictionaryWithObject:anError forKey:@"parserError"]   // Store the NSError.
                      ];
    [e raise];
}

////////////// ////////////// ////////////// ////////////// 
// Convert from JSON String to an Dictionary Object.
+(id)convertFromJSON:(NSString*)anJSONString
{
    return [JPJSONProcesser convertFromJSONData:[anJSONString dataUsingEncoding:NSUTF8StringEncoding]];
}

////////////// ////////////// ////////////// //////////////
// Convert from JSON Data to an Dictionary Object.
+(id)convertFromJSONData:(NSData *)anJSONData {
    
    // Error Handler.
    NSError *anError = nil;

    // Try to process.
    id processed = [NSJSONSerialization JSONObjectWithData:anJSONData
                                                   options:NSJSONReadingMutableContainers
                                                     error:&anError];
    
    // If some error, will raise an Exception.
    if (anError) {
        [self raiseExceptionWithError:anError];
        return nil;
    }
    
    // Everything ok.
	return processed;
}

////////////// ////////////// ////////////// ////////////// 
// Convert to an Dictionary to an JSON String. Not human readable.
+(NSString*)convertToJSON:(NSDictionary*)anJSONDictionary {
	return [JPJSONProcesser convertToJSON:anJSONDictionary humanReadable:NO];
}

////////////// ////////////// ////////////// ////////////// 
// Convert an Dictionary to an JSON String. Human readable or not defined by parameter.
+(NSString*)convertToJSON:(NSDictionary*)anJSONDictionary humanReadable:(BOOL)humanReadable {
    
    // Error Handler.
    NSError *anError = nil;
    
    // Try to process.
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:anJSONDictionary
                                                       options:( humanReadable ? NSJSONWritingPrettyPrinted : 0 )
                                                         error:&anError];
    
    // If some error, will raise an Exception.
    if (anError) {
        [self raiseExceptionWithError:anError];
        return nil;
    }
    
    // Everythink ok.
	return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
