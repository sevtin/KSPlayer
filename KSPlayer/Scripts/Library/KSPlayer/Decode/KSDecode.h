//
//  KSDecode.h
//  KSPlayer
//
//  Created by saeipi on 2020/7/4.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSProcess.h"
#include<libavcodec/avcodec.h>

@interface KSDecode : KSProcess

//当前解码到的pts
@property(nonatomic,assign) long long pts;

+ (void)freePacket:(AVPacket **)pkt;
+ (void)freeFrame:(AVFrame **)frame;
- (void)close;
- (void)clear;
- (BOOL)open:(AVCodecParameters *)par;
- (BOOL)send:(AVPacket *)pkt;
- (AVFrame *)receive;

@end
