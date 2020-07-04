//
//  KSDecode.m
//  KSPlayer
//
//  Created by saeipi on 2020/7/4.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSDecode.h"
#import <pthread.h>

@interface KSDecode() {
    AVCodecContext *codec;
}

@end
@implementation KSDecode
- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_mutex_init(&lock, NULL);
        codec = NULL;
    }
    return self;
}
+ (void)freePacket:(AVPacket **)pkt {
    if (!pkt || !(*pkt)) {
        return;
    }
    av_packet_free(pkt);
}

+ (void)freeFrame:(AVFrame **)frame {
    if (!frame || !(*frame)) {
        return;
    }
    av_frame_free(frame);
}

- (void)close {
    [self mutexLock];
    if (codec) {
        avcodec_close(codec);
        avcodec_free_context(&codec);
    }
    _pts = 0;
    [self mutexUnlock];
}

- (void)clear {
    [self mutexLock];
    //清理解码缓冲
    if (codec) {
        avcodec_flush_buffers(codec);
    }
    [self mutexUnlock];
}

- (BOOL)open:(AVCodecParameters *)par {
    if (!par) {
        return false;
    }
    [self close];
    
    //找到解码器
    AVCodec *video_codec = avcodec_find_decoder(par->codec_id);
    if (!video_codec) {
        avcodec_parameters_free(&par);
        return false;
    }
    [self mutexLock];
    codec = avcodec_alloc_context3(video_codec);
    
    //配置解码器上下文参数
    avcodec_parameters_to_context(codec, par);
    avcodec_parameters_free(&par);
    
    //八线程解码
    codec->thread_count = 8;
    
    //打开解码器上下文
    int ret = avcodec_open2(codec, NULL, NULL);
    if (ret != 0) {
        avcodec_free_context(&codec);
        [self mutexUnlock];
        return false;
    }
    [self mutexUnlock];
    return true;
}

//发送到解码线程，不管成功与否都释放pkt空间（对象和媒体内容）
- (BOOL)send:(AVPacket *)pkt {
    //容错处理
    if (!pkt || pkt->size <= 0 || !pkt->data){return false;}
    [self mutexLock];
    if (!codec) {
        [self mutexUnlock];
        return false;
    }
    int ret = avcodec_send_packet(codec, pkt);
    [self mutexUnlock];
    av_packet_free(&pkt);
    if (ret != 0){return false;}
    return true;
}

//获取解码数据，一次send可能需要多次Recv，获取缓冲中的数据Send NULL在Recv多次
//每次复制一份，由调用者释放 av_frame_free
- (AVFrame *)receive {
    [self mutexLock];
    
    if (!codec) {
        [self mutexUnlock];
        return NULL;
    }
    AVFrame *frame = av_frame_alloc();
    int ret = avcodec_receive_frame(codec, frame);
    
    //为什么不放后面
    [self mutexUnlock];
    if (ret != 0) {
        av_frame_free(&frame);
        return NULL;
    }
    _pts = frame->pts;
    return frame;
}

- (void)mutexLock {
    pthread_mutex_lock(&lock);
}

- (void)mutexUnlock {
    pthread_mutex_unlock(&lock);
}

@end
