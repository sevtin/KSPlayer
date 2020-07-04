//
//  KSDemux.m
//  KSPlayer
//
//  Created by saeipi on 2020/7/4.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSDemux.h"
@interface KSDemux() {
    AVFormatContext *fmt_ctx;
    //音视频索引，读取时区分音视频
    int video_index;
    int audio_index;
}

@end
@implementation KSDemux

- (double)r2d:(AVRational)r {
    return r.den == 0 ? 0 : (double)r.num / (double)r.den;
}

- (BOOL)open:(const char *)url {
    [self close];
    
    //参数设置
    AVDictionary *opts = NULL;
    //设置rtsp流已tcp协议打开
    av_dict_set(&opts, "rtsp_transport", "tcp", 0);
    //网络延时时间
    av_dict_set(&opts, "max_delay", "500", 0);
    
    [self mutexLock];
    int ret = avformat_open_input(&fmt_ctx,
                                  url,
                                  NULL,  // NULL表示自动选择解封器
                                  &opts //参数设置，比如rtsp的延时时间
                                  );
    if (ret != 0) {
        [self mutexUnlock];
        printf("avformat_open_input error: %s",av_err2str(ret));
        return false;
    }
    //获取流信息
    ret = avformat_find_stream_info(fmt_ctx, 0);
    
    //总时长 毫秒
    _total_ms = fmt_ctx->duration / (AV_TIME_BASE / 1000);
    
    //打印视频流详细信息
    av_dump_format(fmt_ctx, 0, url, 0);
    
    //获取视频流
    video_index = av_find_best_stream(fmt_ctx, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
    AVStream *stream = fmt_ctx->streams[video_index];
    _width = stream->codecpar->width;
    _height = stream->codecpar->height;
    
    //获取音频流
    audio_index = av_find_best_stream(fmt_ctx, AVMEDIA_TYPE_AUDIO, -1, -1, NULL, 0);
    stream = fmt_ctx->streams[audio_index];
    sample_rate = stream->codecpar->sample_rate;
    channels = stream->codecpar->channels;
    
    [self mutexUnlock];
    
    return true;
}

- (void)close {
    [self mutexLock];
    if (!fmt_ctx) {
        [self mutexUnlock];
        return;
    }
    //清理读取缓冲
    avformat_close_input(&fmt_ctx);
    //媒体总时长（毫秒）
    _total_ms = 0;
    [self mutexUnlock];
}

- (void)clear {
    [self mutexLock];
    if (!fmt_ctx) {
        [self mutexUnlock];
        return;
    }
    //清理读取缓冲
    avformat_flush(fmt_ctx);
    [self mutexUnlock];
}

- (KSMediaType)mediaType:(AVPacket *)pkt {
    if (!pkt) {
        return KSMEDIA_TYPE_UNKNOWN;
    }
    if (pkt->stream_index == video_index) {
        return KSMEDIA_TYPE_VIDEO;
    }
    return KSMEDIA_TYPE_AUDIO;
}

- (AVCodecParameters*)copyStreamPar:(int)index {
    [self mutexLock];
    if (!fmt_ctx) {
        [self mutexUnlock];
        return NULL;
    }
    AVCodecParameters *par = avcodec_parameters_alloc();
    avcodec_parameters_copy(par, fmt_ctx->streams[index]->codecpar);
    [self mutexUnlock];
    return par;
}

//获取视频参数  返回的空间需要清理  avcodec_parameters_free
- (AVCodecParameters*)copyVideoPar {
    return [self copyStreamPar:video_index];
}

//获取音频参数  返回的空间需要清理 avcodec_parameters_free
- (AVCodecParameters*)copyAudioPar {
    return [self copyStreamPar:audio_index];
}

- (AVPacket *)readVideo {
    [self mutexLock];
    if (!fmt_ctx) {
        [self mutexUnlock];
        return NULL;
    }
    [self mutexUnlock];
    
    AVPacket *pkt = NULL;
    //防止阻塞
    for (int i = 0; i < 20; i++) {
        pkt = [self read];
        if (!pkt) {
            break;
        }
        if (pkt->stream_index == video_index) {
            break;
        }
        av_packet_free(&pkt);
    }
    return pkt;
}

//空间需要调用者释放 ，释放AVPacket对象空间，和数据空间 av_packet_free
- (AVPacket *)read {
    [self mutexLock];
    if (!fmt_ctx) {
        [self mutexUnlock];
        return NULL;
    }
    AVPacket *pkt = av_packet_alloc();
    //读取一帧，并分配空间
    int ret = av_read_frame(fmt_ctx, pkt);
    if (ret != 0) {
        [self mutexUnlock];
        av_packet_free(&pkt);
        return NULL;
    }
    //pts转换为毫秒
    double r = [self r2d:fmt_ctx->streams[pkt->stream_index]->time_base];
    
    pkt->pts = pkt->pts*(1000 * r);
    pkt->dts = pkt->dts*(1000 * r);
    [self mutexUnlock];
    return pkt;
}

@end
