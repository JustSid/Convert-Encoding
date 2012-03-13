//
//  JUFileConverter.h
//  JUFileConverter
//
//  Created by Sidney Just on 13.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Automator/AMBundleAction.h>

@interface JUFileConverter : AMBundleAction

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo;
- (BOOL)processPath:(NSString *)path convertedPaths:(NSMutableArray *)converted directFilePath:(BOOL)directPath recursion:(BOOL)recursion error:(NSDictionary **)errorInfo;

@end
