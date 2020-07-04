//
//  KSVideoThread.m
//  KSPlayer
//
//  Created by saeipi on 2020/7/4.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSVideoThread.h"
#import "KSConst.h"
@implementation KSVideoThread

- (instancetype)init {
    self = [super init];
    if (self) {
        decode = [[KSDecode alloc] init];
    }
    return self;
}

//打开，不管成功与否都清理
-(BOOL)open:(AVCodecParameters *)par {
    if (!par) {
        return false;
    }
    
    [self mutexLock];
    _syn_pts = 0;
    [self mutexUnlock];
    
    BOOL ret = true;
    if (![decode open:par]) {
        printf("video decode open failed!");
        ret = false;
    }
    return ret;
}

- (void)updatePlaystatus:(BOOL)pause {
    [self mutexLock];
    isPause = pause;
    [self mutexUnlock];
}

- (void)run {
    while (!isExit) {
        [self mutexLock];
        if (isPause) {
            [self mutexUnlock];
            usleep(KS_Const_USleep_Pause);
            continue;
        }
        
        //音视频同步
        _syn_pts = 999999999;
        if (_syn_pts > 0 && _syn_pts < decode.pts) {
            [self mutexUnlock];
            usleep(KS_Const_USleep_Sync);
            continue;
        }
        AVPacket *pkt = [self pop];
        BOOL ret = [decode send:pkt];
        if (!ret) {
            [self mutexUnlock];
            usleep(KS_Const_USleep_Default);
            continue;
        }
        while (!isExit) {
            AVFrame *frame = [decode receive];
            //显示视频
            if (!frame) {
                [self.delegate videoThread:self frame:frame];
            }
        }
        
        [self mutexUnlock];
    }
}

//解码pts，如果接收到的解码数据pts >= seekpts return true 并且显示画面
- (BOOL)repaintPts:(AVPacket *)pkt seekpts:(long long)seekpts {
    [self mutexLock];
    bool ret = [decode send:pkt];
    if (!ret) {
        [self mutexUnlock];
        return true; //表示结束解码
    }
    AVFrame *frame = [decode receive];
    if (!frame) {
        [self mutexUnlock];
        return false;
    }
    //到达位置
    if (decode.pts >= seekpts) {
        //显示视频
        [self.delegate videoThread:self frame:frame];
        
        [self mutexUnlock];
        return true;
    }
    [KSDecode freeFrame:&frame];
    [self mutexUnlock];
    return false;
}

@end
