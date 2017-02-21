//
//  KLJointAngleEstimator.m
//  BLEBridge
//
//  Created by Supat Saetia on 10/10/15.
//  Copyright © 2015 Supat Saetia. All rights reserved.
//

#import "KLJointAngleEstimator.h"
#include <stdio.h>
//#include <new>

//#define KFILTER_OFF 1
//#define KFILTER_ON 2

@implementation KLJointAngleEstimator

@synthesize eqpoint;
@synthesize target;
@synthesize center_angel;

//int static kFilterStat;

- (id)init
{
    self = [super init];
    
    if (self) {
        num_channel = 6;
        msparam = [[NSMutableArray alloc] initWithCapacity:(2 + 3 * num_channel + 1)];
        eqpoint = target = center_angel = 0;
        
        // msparam initialization here ...
        
        [msparam addObject:[NSNumber numberWithDouble:0]];
        [msparam addObject:[NSNumber numberWithDouble:-2]];
        [msparam addObject:[NSNumber numberWithDouble:-2]];
        [msparam addObject:[NSNumber numberWithDouble:-2]];
        [msparam addObject:[NSNumber numberWithDouble:2]];
        [msparam addObject:[NSNumber numberWithDouble:2]];
        [msparam addObject:[NSNumber numberWithDouble:2]];
        [msparam addObject:[NSNumber numberWithDouble:-2]];
        [msparam addObject:[NSNumber numberWithDouble:-2]];
        [msparam addObject:[NSNumber numberWithDouble:-2]];
        [msparam addObject:[NSNumber numberWithDouble:2]];
        [msparam addObject:[NSNumber numberWithDouble:2]];
        [msparam addObject:[NSNumber numberWithDouble:2]];
        [msparam addObject:[NSNumber numberWithDouble:-0.5]];
        [msparam addObject:[NSNumber numberWithDouble:-2]];
        [msparam addObject:[NSNumber numberWithDouble:-2]];
        [msparam addObject:[NSNumber numberWithDouble:-2]];
        [msparam addObject:[NSNumber numberWithDouble:-2]];
        [msparam addObject:[NSNumber numberWithDouble:-2]];
        [msparam addObject:[NSNumber numberWithDouble:-2]];
        
        //center_angel = [[msparam objectAtIndex:(2 + 3 * num_channel)] doubleValue];
    }
    
//    kFilterStat = KFILTER_OFF;
//    [self activateKoikefilterWithBuffersize:400];
    
    return self;
}

//- (id)initWithKoikeFilterBufferSize:(int)bufferSize withFlexorThreshold:(float)flexorThreshold andTensorThreshold:(float)tensorThreshold;
//{
//    self = [super init];
//    
//    if (self) {
//        num_channel = 6;
//        msparam = [[NSMutableArray alloc] initWithCapacity:(2 + 3 * num_channel + 1)];
//        eqpoint = target = center_angel = 0;
//        
//        // msparam initialization here ...
//        
//        [msparam addObject:[NSNumber numberWithDouble:0]];
//        [msparam addObject:[NSNumber numberWithDouble:flexorThreshold]];
//        [msparam addObject:[NSNumber numberWithDouble:flexorThreshold]];
//        [msparam addObject:[NSNumber numberWithDouble:flexorThreshold]];
//        [msparam addObject:[NSNumber numberWithDouble:tensorThreshold]];
//        [msparam addObject:[NSNumber numberWithDouble:tensorThreshold]];
//        [msparam addObject:[NSNumber numberWithDouble:tensorThreshold]];
//        [msparam addObject:[NSNumber numberWithDouble:-2]];
//        [msparam addObject:[NSNumber numberWithDouble:-2]];
//        [msparam addObject:[NSNumber numberWithDouble:-2]];
//        [msparam addObject:[NSNumber numberWithDouble:2]];
//        [msparam addObject:[NSNumber numberWithDouble:2]];
//        [msparam addObject:[NSNumber numberWithDouble:2]];
//        [msparam addObject:[NSNumber numberWithDouble:-0.5]];
//        [msparam addObject:[NSNumber numberWithDouble:-2]];
//        [msparam addObject:[NSNumber numberWithDouble:-2]];
//        [msparam addObject:[NSNumber numberWithDouble:-2]];
//        [msparam addObject:[NSNumber numberWithDouble:-2]];
//        [msparam addObject:[NSNumber numberWithDouble:-2]];
//        [msparam addObject:[NSNumber numberWithDouble:-2]];
//        
//        //center_angel = [[msparam objectAtIndex:(2 + 3 * num_channel)] doubleValue];
//    }
//    
//    kFilterStat = KFILTER_OFF;
//    [self activateKoikefilterWithBuffersize:bufferSize];
//    
//    return self;
//}

- (double)calcEqPoint:(NSMutableArray *)emg
{
//    double filteredEMG = 0;
//    NSMutableArray *femg = [[NSMutableArray alloc] init];
//    for (int i = 0; i < num_channel; i++) {
//        if (kFilterStat == KFILTER_ON) {
//            filteredEMG = koikeFilters[i].PushInput([[emg objectAtIndex:i] doubleValue]);
//            [femg addObject:[NSNumber numberWithDouble:filteredEMG]];
//        } else {
//            [femg addObject:[NSNumber numberWithDouble:0]];
//        }
//    }
    
    double num, den = 0;
    int idx = 0;
    num = [[msparam objectAtIndex:idx] doubleValue];
    idx++;
    for (int i = 0; i < num_channel; i++, idx++) {
        num += [[msparam objectAtIndex:idx] doubleValue] * [[emg objectAtIndex:i] doubleValue];
    }
    for (int i = 0; i < num_channel; i++, idx++) {
        num += [[msparam objectAtIndex:idx] doubleValue] * [[emg objectAtIndex:i] doubleValue] * [[emg objectAtIndex:i] doubleValue];
    }
    assert(idx == 1 + 2 * num_channel);
    den = [[msparam objectAtIndex:idx] doubleValue];
    idx++;
    for (int i = 0; i < num_channel; i++, idx++) {
        den += [[msparam objectAtIndex:idx] doubleValue] * [[emg objectAtIndex:i] doubleValue];
    }
    assert(idx == 2 + 3 * num_channel);
    
    return ((-num / den) * -1);
}

- (double)calcStiffness:(NSMutableArray *)emg
{
    double ret;
    int idx = 1 + 2 * num_channel;
    ret = [[msparam objectAtIndex:idx] doubleValue];
    idx++;
    for (int i = 0; i < num_channel; i++, idx++) {
        ret += [[msparam objectAtIndex:idx] doubleValue] * [[emg objectAtIndex:i] doubleValue];
    }
    assert(idx != [msparam count] - 1);
    return -ret;
}

- (void)setNeutralJointAngle:(NSMutableArray *)emg
{
    center_angel = [self calcEqPoint:emg];
}

//- (void)activateKoikefilterWithBuffersize:(int)bsize
//{
//    if (kFilterStat == KFILTER_OFF) {
//        //alloc a block of memory of C++ object arrays using ::operator new
//        koikeFilters = static_cast<CKoikeFilter *>(::operator new(sizeof(CKoikeFilter) * num_channel));
//        for (size_t i = 0; i < num_channel; i++) {
//            ::new (&koikeFilters[i]) CKoikeFilter(bsize);
//        }
//        kFilterStat = KFILTER_ON;
//    }
//    else if(kFilterStat == KFILTER_ON)
//    {
//        kFilterStat = KFILTER_OFF;
//        delete koikeFilters;
//    }
//}

@end
