//
//  KSProcess.m
//  KSPlayer
//
//  Created by saeipi on 2020/7/4.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSProcess.h"
#import <pthread.h>
@implementation KSProcess

- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_mutex_init(&lock, NULL);
    }
    return self;
}

- (void)mutexLock {
    pthread_mutex_lock(&lock);
}

- (void)mutexUnlock {
    pthread_mutex_unlock(&lock);
}

@end
