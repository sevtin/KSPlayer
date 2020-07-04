//
//  ViewController.m
//  KSPlayer
//
//  Created by saeipi on 2020/5/5.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "ViewController.h"
#import "KSMediaPlayerController.h"
#import "KSAudioPlayerController.h"
#import "KSMainCell.h"
#import "KSDemuxThread.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,KSDemuxThreadDelegate>
@property(nonatomic,strong)KSDemuxThread *demuxThread;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:236/255.0];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KSMainCell *cell = [KSMainCell initWithTableView:tableView];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _demuxThread = [[KSDemuxThread alloc] init];
    _demuxThread.delegate = self;
    char *url = "http://www.w3school.com.cn/i/movie.mp4";
    [_demuxThread open:url];
    
    /*
    UIViewController *ctrl;
    switch (indexPath.row) {
        case 0:
        {
            ctrl = [[KSMediaPlayerController alloc] init];
        }
            break;
        case 1:
        {
            ctrl = [[KSAudioPlayerController alloc] init];
        }
            break;
        default:
            break;
    }
    if (ctrl) {
        [self.navigationController pushViewController:ctrl animated:NO];
    }*/
}

-(void)videoThread:(KSDemuxThread *)thread width:(int)width height:(int)height {
    
}
-(void)videoThread:(KSDemuxThread *)thread frame:(AVFrame *)frame {
    
}
@end
