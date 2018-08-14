//
//  ViewController.m
//  RecordDemo
//
//  Created by 邢坤坤 on 2018/8/10.
//  Copyright © 2018年 KevinOmg. All rights reserved.
//

#import "ViewController.h"
#import <EZOnlineScorer/EZOnlineScorer.h>


@interface ViewController ()
@property (nonatomic,assign) NSString *Appid;
@property (nonatomic,assign) NSString *Secret;
@property (nonatomic,assign) NSString *Url;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _Appid = @"test.biling";
    _Secret = @"dd752b8a1faa41a3b23805907354910b";
    
    [EZOnlineScorerRecorder configureAppID:_Appid secret:_Secret];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
