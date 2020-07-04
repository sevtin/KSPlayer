//
//  KSDemuxThread.m
//  KSPlayer
//
//  Created by saeipi on 2020/7/4.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSDemuxThread.h"
#import "KSDemux.h"
#import "KSVideoThread.h"
#import "KSAudioThread.h"
#include "KSConst.h"

@interface KSDemuxThread()<KSVideoThreadDelegate> {
    KSDemux *demux;
    KSVideoThread *video_thread;
    KSAudioThread *audio_thread;
}

@end
@implementation KSDemuxThread

//不完整，没有音频
- (void)open:(const char *)url {
    dispatch_queue_t queue = dispatch_queue_create("com.saeipi.KSPlayer", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            av_register_all();
            avformat_network_init();
        });
        [self initDemux:url];
        [self start];
    });
}

- (BOOL)initDemux:(const char *)url {
    if (!url) {
        return false;
    }
    [self mutexLock];
    [self initSubThread];
    //打开解封装
    BOOL ret = [demux open:url];
    if (!ret) {
        [self mutexUnlock];
        printf("[demux open:url] error");
        return false;
    }
    [self.delegate videoThread:self width:demux.width height:demux.height];
    //打开视频解码器和处理线程
    if (![video_thread open:[demux copyVideoPar]]) {
        ret = false;
    }
    self.total_ms = demux.total_ms;
    [self mutexUnlock];
    
    return ret;
}

- (void)run {
    while (!isExit) {
        printf("|----------------|");
        [self mutexLock];
        if (isPause) {
            [self mutexUnlock];
            usleep(KS_Const_USleep_Pause);
            continue;
        }
        if (!demux) {
            [self mutexUnlock];
            usleep(KS_Const_USleep_Default);
            continue;
        }
        //音视频同步
        if (video_thread && audio_thread) {
            //self.pts = audio_thread.pts;
            //video_thread.syn_pts = audio_thread.pts;
        }
        AVPacket *pkt = [demux read];
        if (!pkt) {
            [self mutexUnlock];
            usleep(KS_Const_USleep_Default);
            continue;
        }
        KSMediaType type = [demux mediaType:pkt];
        if (type == KSMEDIA_TYPE_VIDEO) {
            if (video_thread) {
                [video_thread push:pkt];
            }
        }
        else if (type == KSMEDIA_TYPE_AUDIO) {
            if (audio_thread) {
                //[audio_thread push:pkt];
            }
        }
        [self mutexUnlock];
        usleep(2);
    }
}

-(void)initSubThread {
    if (!demux) {
        demux = [[KSDemux alloc] init];
    }
    if (!video_thread) {
        video_thread = [[KSVideoThread alloc] init];
        video_thread.delegate = self;
    }
    if (!audio_thread) {
        audio_thread = [[KSAudioThread alloc] init];
    }
}

//关闭线程清理资源
-(void)close {
    [super close];
    
    [self mutexLock];
    if (video_thread) {
        [video_thread close];
    }
    if (audio_thread) {
        [audio_thread close];
        audio_thread = NULL;
    }
    [self mutexUnlock];
}

- (void)start {
    dispatch_queue_t queue = dispatch_queue_create("com.saeipi.KSPlayer", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [self run];
    });
    dispatch_async(queue, ^{
        [self->video_thread run];
    });
}

-(void)videoThread:(KSVideoThread *)thread width:(int)width height:(int)height {
    printf("videoThread:(KSVideoThread *)thread width:(int)width height:(int)height");
    [self.delegate videoThread:self width:width height:height];
}

-(void)videoThread:(KSVideoThread *)thread frame:(AVFrame *)frame {
    printf("frame->pkt_size: %d",frame->pkt_size);
    [self.delegate videoThread:self frame:frame];
}

@end
