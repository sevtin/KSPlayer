//
//  KSThread.m
//  KSPlayer
//
//  Created by saeipi on 2020/7/4.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSThread.h"
#import <pthread.h>
#import "avdevice.h"
#import "avformat.h"
#import "KSDecode.h"

@implementation KSThread

- (BOOL)push:(AVPacket *)pkt {
    if (!pkt) {
        return false;
    }
    //引用计数+1
    if(av_dup_packet(pkt) < 0) {
        return false;
    }
    
    //分配空间
    AVPacketList *pkt1 = av_malloc(sizeof(AVPacketList));
    if (!pkt1){
        return false;
    }
    pkt1->pkt = *pkt;
    pkt1->next = NULL;
    
    if (!packet_queue.last_pkt){
        packet_queue.first_pkt = pkt1;//如果是空队列
    }
    else{
        packet_queue.last_pkt->next = pkt1;//设成最后一个包的下一个元素
    }
    
    //移动指针，最后一个元素指向pkt1
    packet_queue.last_pkt = pkt1;
    //元素个数增加
    packet_queue.nb_packets++;
    //统计每一个包的size，求和
    packet_queue.size += pkt1->pkt.size;
    
    return true;
}

//访问加锁
- (AVPacket *)pop {
    
    AVPacketList *pktl = NULL;
    AVPacket *pkt = av_malloc(sizeof(AVPacket));
    //获取队列头
    pktl = packet_queue.first_pkt;
    if (pktl) {
        //更新队列头的指针
        packet_queue.first_pkt = pktl->next;
        if (!packet_queue.first_pkt){
            packet_queue.last_pkt = NULL;//队列已经空了
        }
        //元素个数减1
        packet_queue.nb_packets--;
        //减去出队列包数据大小
        packet_queue.size -= pktl->pkt.size;
        //取出真正的AVPacket数据
        *pkt = pktl->pkt;
        //释放分配的内存
        av_free(pktl);
    }
    return pkt;
}

- (void)close {
    [self clear];
    isExit = true;
    
    [self mutexLock];
    decode = NULL;
    [self mutexUnlock];
}

- (void)clear {
    [self mutexLock];
    [decode clear];
    AVPacket *pkt;
    for (; ; ) {
        pkt = [self pop];
        if (pkt) {
            av_packet_free(&pkt);
        }else{
            break;
        }
    }
    [self mutexUnlock];
}

@end
