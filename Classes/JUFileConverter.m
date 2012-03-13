//
//  JUFileConverter.m
//  JUFileConverter
//
//  Created by Sidney Just on 13.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <OSAkit/OSAKit.h>
#import "JUFileConverter.h"

@implementation JUFileConverter

- (NSStringEncoding)encodingForIndex:(NSInteger)index
{
    switch(index)
    {
        case 0:
            return NSUTF8StringEncoding;
            break;
            
        case 1:
            return NSISOLatin1StringEncoding;
            break;
        
        case 2:
            return NSISOLatin2StringEncoding;
            break;
            
        case 3:
            return NSASCIIStringEncoding;
            break;
            
        case 4:
            return NSUnicodeStringEncoding;
            break;
            
        case 5:
            return NSUTF16StringEncoding;
            break;
            
        case 6:
            return NSUTF16LittleEndianStringEncoding;
            break;
            
        case 7:
            return NSUTF16BigEndianStringEncoding;
            break;
            
        default:
            break;
    }
    
    return NSUTF8StringEncoding;
}

- (NSDictionary *)errorDictionaryWithReason:(NSString *)reason
{
    NSArray *objsArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:errOSASystemError], reason, nil];
    NSArray *keysArray = [NSArray arrayWithObjects:OSAScriptErrorNumber, OSAScriptErrorMessage, nil];
    
    return [NSDictionary dictionaryWithObjects:objsArray forKeys:keysArray];
}





- (BOOL)convertFile:(NSString *)path directFilePath:(BOOL)directPath error:(NSDictionary **)errorInfo
{
    BOOL useFromEncoding = [[[self parameters] objectForKey:@"useFromEncoding"] boolValue];
    NSStringEncoding fromEncoding = [self encodingForIndex:[[[self parameters] objectForKey:@"fromEncoding"] integerValue]];
    NSStringEncoding toEncoding   = [self encodingForIndex:[[[self parameters] objectForKey:@"toEncoding"] integerValue]];
    
    if(useFromEncoding && fromEncoding == toEncoding)
        return YES;
    
    
    NSStringEncoding encoding;
    NSError  *error = nil;
    NSString *content = [[NSString alloc] initWithContentsOfFile:path usedEncoding:&encoding error:&error];
    
    if(content == nil)
    {
        if(directPath)
            *errorInfo = [self errorDictionaryWithReason:[NSString stringWithFormat:@"Could not read %@. Error: %@", path, [error localizedFailureReason]]];
            
        return NO;
    }
    
    
    
    if(useFromEncoding)
    {
        if(fromEncoding != encoding)
        {
            [content release];
            return YES;
        }
    }
    if(encoding == toEncoding)
    {
        [content release];
        return YES;
    }
    
    
    
    if(![content writeToFile:path atomically:YES encoding:toEncoding error:&error])
    {
        *errorInfo = [self errorDictionaryWithReason:[NSString stringWithFormat:@"Could not write %@. Error: %@", path, [error localizedFailureReason]]];
        
        [content release];
        return NO;
    }
    
    
    [content release];
    
    return YES;
}

- (BOOL)convertFolder:(NSString *)path convertedPaths:(NSMutableArray *)converted error:(NSDictionary **)errorInfo
{
    NSError *error = nil;
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    if(!content)
    {
        *errorInfo = [self errorDictionaryWithReason:[NSString stringWithFormat:@"Could not get content of folder %@.\nError: %@", path, [error localizedFailureReason]]];
        return NO;
    }
    
    
    
    for(NSString *file in content)
    {
        NSString *filePath = [path stringByAppendingPathComponent:file];
        
        if(![self processPath:filePath convertedPaths:converted directFilePath:NO recursion:YES error:errorInfo])
            return NO;
    }
    
    return YES;
}



- (BOOL)processPath:(NSString *)path convertedPaths:(NSMutableArray *)converted directFilePath:(BOOL)directPath recursion:(BOOL)recursion error:(NSDictionary **)errorInfo
{
    BOOL isFolder;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isFolder];
    BOOL result;
    
    if(exists)
    {
        if(isFolder)
        {
            BOOL allowsRecursion = [[[self parameters] objectForKey:@"allowsRecursion"] boolValue];
            
            if(!allowsRecursion && recursion == YES)
                return YES;
                
            result = [self convertFolder:path convertedPaths:converted error:errorInfo];
        }
        else
        {
            result = [self convertFile:path directFilePath:directPath error:errorInfo];
        }
        
        if(result)
            [converted addObject:path];
        
        
        if(*errorInfo == nil)
            return YES;
        
        return result;
    }
    
    
    
    
    *errorInfo = [self errorDictionaryWithReason:[NSString stringWithFormat:@"Path %@ doesn't seem to exist...", path]];
    return NO;
}

                  
                  

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo
{
    NSMutableArray *converted = [NSMutableArray array];

    
    if([input isKindOfClass:[NSArray class]])
    {
        NSArray *paths = input;
        
        for(NSString *path in paths)
        {
            BOOL result = [self processPath:path convertedPaths:converted directFilePath:YES recursion:NO error:errorInfo];
            
            if(!result)
                return nil;
        }
    }

	
	return converted;
}

@end
