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

@required
-(void)videoThread:(KSVideoThread *)thread frame:(AVFrame *)frame;

@end

@interface KSVideoThread : KSThread
@property(nonatomic,weak)id<KSVideoThreadDelegate> delegate;
//同步时间，由外部传入
@property(nonatomic,assign) long long syn_pts;
//打开，不管成功与否都清理
-(BOOL)open:(AVCodecParameters *)par;
- (void)run;
@end
