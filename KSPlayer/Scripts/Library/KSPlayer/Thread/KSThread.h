//
//  KSThread.h
//  KSPlayer
//
//  Created by saeipi on 2020/7/4.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSProcess.h"
#import "avformat.h"
#import "KSDecode.h"
typedef struct KSPacketQueue {
    //队列头，队列尾
    AVPacketList *first_pkt, *last_pkt;
    //队列中有多少个包
    int nb_packets;
    //对了存储空间大小
    int size;
} KSPacketQueue;

@interface KSThread : KSProcess {
    KSPacketQueue packet_queue;
    KSDecode *decode;
}

@property(nonatomic,assign) long long pts;
@property(nonatomic,assign) long long total_ms;


- (BOOL)push:(AVPacket *)pkt;
- (AVPacket *)pop;
- (void)close;
- (void)clear;

@end
