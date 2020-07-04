//
//  KSVideoThread.m
//  KSPlayer
//
//  Created by saeipi on 2020/7/4.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSVideoThread.h"

@implementation KSVideoThread
-(BOOL)open:(AVCodecParameters *)par theDelegate:(id)delegate {
    if (!par) {
        return false;
    }
    return true;
}
@end
