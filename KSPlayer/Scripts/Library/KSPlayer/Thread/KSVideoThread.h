//
//  KSVideoThread.h
//  KSPlayer
//
//  Created by saeipi on 2020/7/4.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSThread.h"
@class KSVideoThread;

@protocol KSVideoThreadDelegate <NSObject>

-(void)videoThread:(KSVideoThread *)thread width:(int)width height:(int)height;
-(void)videoThread:(KSVideoThread *)thread frame:(AVFrame *)frame;

@end

@interface KSVideoThread : KSThread

@property(nonatomic,weak)id<KSVideoThreadDelegate> delegate;

@end
