//
//  KLJointAngleEstimator.h
//  BLEBridge
//
//  Created by Supat Saetia on 10/10/15.
//  Copyright © 2015 Supat Saetia. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "KoikeFilter.h"

@interface KLJointAngleEstimator : NSObject
{
    @private
    NSMutableArray *msparam;
    int num_channel;
    
//    CKoikeFilter *koikeFilters;
}

@property (readonly) double eqpoint;
@property (readonly) double target;
@property (readonly) double center_angel;

//- (id)initWithKoikeFilterBufferSize:(int)bufferSize withFlexorThreshold:(float)flexorThreshold andTensorThreshold:(float)tensorThreshold;

- (double)calcEqPoint:(NSMutableArray *)emg;
- (double)calcStiffness:(NSMutableArray *)emg;
- (void)setNeutralJointAngle:(NSMutableArray *)emg;

@end
