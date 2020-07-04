//
//  KSDecode.h
//  KSPlayer
//
//  Created by saeipi on 2020/7/4.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#include<libavcodec/avcodec.h>

@interface KSDecode : NSObject{
    pthread_mutex_t lock;
    BOOL isExit;
    //当前解码到的pts
    long long pts;
}

+ (void)freePacket:(AVPacket **)pkt;
+ (void)freeFrame:(AVFrame **)frame;
- (void)close;
- (void)clear;
- (BOOL)open:(AVCodecParameters *)par;
- (BOOL)send:(AVPacket *)pkt;
- (AVFrame *)receive;

@end
