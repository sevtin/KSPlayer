//
//  KSDemuxThread.h
//  KSPlayer
//
//  Created by saeipi on 2020/7/4.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSThread.h"
@class KSDemuxThread;
@protocol KSDemuxThreadDelegate <NSObject>

@required
-(void)videoThread:(KSDemuxThread *)thread width:(int)width height:(int)height;
-(void)videoThread:(KSDemuxThread *)thread frame:(AVFrame *)frame;

@end
@interface KSDemuxThread : KSThread

@property(nonatomic,weak)id<KSDemuxThreadDelegate> delegate;

- (void)open:(const char *)url;

@end
