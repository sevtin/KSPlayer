//
//  KSThread.h
//  KSPlayer
//
//  Created by saeipi on 2020/7/4.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "avformat.h"

typedef struct KSPacketQueue {
    //队列头，队列尾
    AVPacketList *first_pkt, *last_pkt;
    //队列中有多少个包
    int nb_packets;
    //对了存储空间大小
    int size;
} KSPacketQueue;

@interface KSThread : NSObject {
    pthread_mutex_t lock;
    NSThread *thread;
    BOOL isExit;
    KSPacketQueue packet_queue;
}

- (void)mutexLock;
- (void)mutexUnlock;
- (void)msleep:(int)ms;

@end
