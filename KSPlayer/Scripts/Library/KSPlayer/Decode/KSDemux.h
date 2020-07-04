//
//  KSDemux.h
//  KSPlayer
//
//  Created by saeipi on 2020/7/4.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSProcess.h"
#include "libavformat/avformat.h"
typedef enum {
    KSMEDIA_TYPE_UNKNOWN = -1,
    KSMEDIA_TYPE_VIDEO,
    KSMEDIA_TYPE_AUDIO
} KSMediaType;

@interface KSDemux : KSProcess {
    int sample_rate;
    int channels;
}

@property(nonatomic,assign)long long total_ms;
@property(nonatomic,assign)int width;
@property(nonatomic,assign)int height;
- (BOOL)open:(const char *)url;
- (void)close;
- (void)clear;
- (KSMediaType)mediaType:(AVPacket *)pkt;
- (AVCodecParameters*)copyVideoPar;
- (AVCodecParameters*)copyAudioPar;
- (AVPacket *)readVideo;
- (AVPacket *)read;

@end
