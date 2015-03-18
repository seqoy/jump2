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
+(id)convertFromJSON:(NSString*)anJSONString {
    
    // Create data.
    NSData *data = [anJSONString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Process.
    return [self convertFromJSONData:data];
}

////////////// ////////////// ////////////// //////////////
// Convert from JSON Data to an Dictionary Object.
+(id)convertFromJSONData:(NSData *)anJSONData {
    
    NSError *serializationError = nil;
    
    // Try to process.
    id processed = [NSJSONSerialization JSONObjectWithData:anJSONData
                                                   options:NSJSONReadingMutableContainers
                                                     error:&serializationError];
    
    // If some error, will raise an Exception.
    if (serializationError != nil) {
        
        // Create error object.
        NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:serializationError, NSLocalizedDescriptionKey, nil];
        NSError *error_ = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:ui];
        
        [self raiseExceptionWithError:error_];
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
    NSError *serializationError = nil;
    
    // Try to process.
    NSData* processed = [NSJSONSerialization dataWithJSONObject:anJSONDictionary
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&serializationError];
    
    // If some error, will raise an Exception.
    if (serializationError != nil) {
        [self raiseExceptionWithError:serializationError];
        return nil;
    }
    
    // Everythink ok.
	return [[NSString alloc] initWithData:processed encoding:NSUTF8StringEncoding];
}

@end
