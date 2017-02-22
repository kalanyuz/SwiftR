//
//  SwiftSigV_macOS.h
//  SwiftSigV_macOS
//
//  Created by Kalanyu Zintus-art on 2017/02/15.
//  Copyright © 2017 kalanyuz. All rights reserved.
//
#include <TargetConditionals.h>

#if TARGET_OS_IOS
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <Cocoa/Cocoa.h>
#endif

//! Project version number for SwiftSigV_macOS.
FOUNDATION_EXPORT double SwiftSigV_macOSVersionNumber;

//! Project version string for SwiftSigV_macOS.
FOUNDATION_EXPORT const unsigned char SwiftSigV_macOSVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SwiftSigV_macOS/PublicHeader.h>


