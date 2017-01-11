//
//  MSBTileManagerSwizzle.m
//  BandTileEvent
//
//  Created by Anton Sokolchenko on 09.01.17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSBTileManagerSwizzle.h"
#import <MicrosoftBandKit_iOS/MicrosoftBandKit_iOS.h>
#import <objc/runtime.h>

#import "MSBStartStrip.h"

@implementation MSBTileManagerSwizzle

+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self instance];
	});
}

+ (instancetype)instance {
	static id sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[MSBTileManagerSwizzle alloc] init];
		[sharedInstance swizzle];
	});
	return sharedInstance;
}

- (void)swizzle {
	SEL selector = NSSelectorFromString(@"filterTilesForThisApp:error:");      // The selector for the method you want to swizzle
	Protocol *protocol = NSProtocolFromString(@"MSBTileManagerProtocol"); // The protocol containing the method
	
	// Get the class list
	int classesCount = objc_getClassList(NULL, 0);
	Class *classes = (__unsafe_unretained Class *)malloc( classesCount * sizeof(Class));
	objc_getClassList(classes, classesCount);
	
	// For every class
	for (int classIndex = 0; classIndex < classesCount; classIndex++) {
		Class class = classes[classIndex];
		
		// Check, whether the class implements the protocol
		// The protocol confirmation can be found in a super class
		Class conformingClass = class;
		while (conformingClass != Nil) {
			if (class_conformsToProtocol(conformingClass, protocol)) {
				break;
			}
			conformingClass = class_getSuperclass(conformingClass);
		}
		
		// Check, whether the protocol is found in the class or a superclass
		if (conformingClass != Nil) {
			Method originalMethod = class_getInstanceMethod(class, selector);
			if (originalMethod == NULL) {
				return;
			}
			Method swizzledMethod = class_getInstanceMethod(self.class, @selector(filterTilesForThisAppSwizzled:error:));
			IMP swizzledMethodIMP = method_getImplementation(swizzledMethod);
			
			method_setImplementation(originalMethod, swizzledMethodIMP);
		}
	}
}

// id = MSBStartStrip *
- (void)filterTilesForThisAppSwizzled:(id)tiles error:(__unsafe_unretained id)error {
	tiles = [tiles strapps];
	// Empty implementation, do not filter anything
	NSLog(@"filterTilesForThisAppSwizzled called");
}

//void filterTilesForThisAppSwizzled(id self, SEL cmd, id tiles, id error) {
//	//NSLog(@"%@", tiles);
//}

@end
