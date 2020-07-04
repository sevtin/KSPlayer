//
//  KSProcess.h
//  KSPlayer
//
//  Created by saeipi on 2020/7/4.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSProcess : NSObject{
    pthread_mutex_t lock;
    BOOL isExit;
    BOOL isPause;
}

- (void)mutexLock;
- (void)mutexUnlock;

@end
