//
//  RecordViewController.m
//  RecordDemo
//
//  Created by 邢坤坤 on 2018/8/10.
//  Copyright © 2018年 KevinOmg. All rights reserved.
//

#import "RecordViewController.h"
#import <EZOnlineScorer/EZOnlineScorer.h>
#import "EZOnlineScorerRecorderPayload.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, ScorerType) {
    asr,
    readAload
};

@interface RecordViewController ()<EZOnlineScorerRecorderDelegate>

@property (nonatomic, assign) ScorerType *scorerType;

@property (nonatomic,assign) EZOnlineScorerRecorder *scorerRecorder;

@property (nonatomic,assign) AVPlayer *player;

@property (nonatomic,copy) NSURL *documentsURLPath;

@property (nonatomic,assign) UIAlertController *alertVc;

@property (nonatomic,assign) NSTimer *timer;

@property (nonatomic,assign) int count;

@property (nonatomic,assign) BOOL _isSwitch;

@property (strong, nonatomic) IBOutlet UIButton *scoreProperty;

@property (strong, nonatomic) IBOutlet UIButton *playProperty;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;



@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (EZOnlineScorerRecorder *) setupScorer {
    
    EZReadAloudPayload *pay = [[EZReadAloudPayload alloc] initWithReferenceText:@"i like apple"];
    
    EZOnlineScorerRecorder *scorer = [[EZOnlineScorerRecorder alloc] initWithPayload:pay useSpeex:true];
    
    scorer.delegate = self;
    
    _scorerRecorder = scorer;
    
    return scorer;
}

//权限判断
- (BOOL)granted {
    AVAudioSessionRecordPermission permission = [[AVAudioSession sharedInstance] recordPermission];
    return permission == AVAudioSessionRecordPermissionGranted;
}


// 文件保存路径地址
- (NSURL *)recordURL {
    
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *str = [tmpDir stringByAppendingString:@"testAudio.aac"];
    NSURL *pathurl = [NSURL fileURLWithPath:str isDirectory:NO];
    
    return pathurl;
    
}


//开始录音
-(void)Scorer {
    
    if (_scorerRecorder.isRecording) {
        
        [_scorerRecorder stopScoring];
        
        [_scoreProperty setTitle:@"开始录制"forState:UIControlStateNormal];
        
        [_timer invalidate];
        
        _timer=nil;
        
    }
    
    [self setupScorer];
    
    _count=0;
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(repeatShowTime:)userInfo:@"admin"repeats:YES];
    
    
    
    NSString *str = [NSTemporaryDirectory() stringByAppendingString:@"testAudio.aac"];
    NSURL *pathurl = [NSURL fileURLWithPath:str isDirectory:YES];
    _documentsURLPath = pathurl;
    
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        
        if (granted) {
            
            NSLog(@"通过验证");
            
            AVAudioSession *session = [AVAudioSession sharedInstance];
            
            NSError *error = nil;
            [session setCategory:AVAudioSessionCategoryPlayAndRecord  withOptions: AVAudioSessionCategoryRecord error:&error];
            [session setActive:YES error:&error];
            
            [_scorerRecorder recordToURL:pathurl];
            
        }else {
            
            NSLog(@"未通过验证,需开权限");
            
            self.alertVc = [UIAlertController alertControllerWithTitle:@"未能开启录音" message:@"请开启录音权限，否则不能录音" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [self.alertVc addAction:action];
            
            [self presentViewController:self.alertVc animated:YES completion:nil];
            
        }
    }];
    
}


- (IBAction)startScorer:(id)sender {
    
    [self Scorer];
    
    // 即使不点击停止 ，也会有一个最长时间的限制
    [_scoreProperty setTitle:@"录制中"forState:UIControlStateNormal];
    [_playProperty setTitle:@"播放" forState:UIControlStateNormal];
    _playProperty.backgroundColor = [UIColor whiteColor];
    
}


- (IBAction)stopScorer:(id)sender {
    
    [_scorerRecorder stopRecording];
    
    
    if(_timer) {
        [_timer invalidate];
        _timer=nil;
    }
    
    _count=0;
    _timeLabel.text=@"00:00";
    [_scoreProperty setTitle:@"开始录制"forState:UIControlStateNormal];
    [_playProperty setTitle:@"播放" forState:UIControlStateNormal];
    _playProperty.backgroundColor = [UIColor whiteColor];
    
}


- (IBAction)play:(id)sender {
    
    [_playProperty setTitle:@"播放中" forState:UIControlStateNormal];
    _playProperty.backgroundColor = [UIColor greenColor];
    
    
    if (_scorerRecorder.isRecording) {
        return;
    }
    
    if (_player.rate != 0) {
        [_player pause];
    }
    
    AVPlayer *play = [[AVPlayer alloc] initWithURL: _documentsURLPath];
    if ((_player = play)) {
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        NSError *error = nil;
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        [session setActive:YES error:&error];
        
        [_player play];
        
    }else{
        
        self.alertVc = [UIAlertController alertControllerWithTitle:@"播放失败" message:@"播放失败请检查" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [self.alertVc addAction:action];
        
        [self presentViewController:self.alertVc animated:YES completion:nil];
        
    }
}




- (void)repeatShowTime:(NSTimer*)tempTimer {
    _count++;
    //设置在文本框上显示时间；
    _timeLabel.text= [NSString stringWithFormat:@"%02d:%02d",_count/60,_count%60];
    
}


//在线记分员开始录制中
-(void)onlineScorerDidBeginRecording:(EZOnlineScorerRecorder *)scorer{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"录制中");
    });
}

// 做了批量改变
-(void)onlineScorer:(EZOnlineScorerRecorder *)scorer didVolumnChange:(float)volumn{
    
    //    NSLog(@"做了状态改变");
}

//在线记分员完成了录音
-(void)onlineScorerDidFinishRecording:(EZOnlineScorerRecorder *)scorer{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"录音完成");
    });
}

// 录制失败
-(void)onlineScorer:(EZOnlineScorerRecorder *)scorer didFailWithError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"录制失败");
    });
}

// 生成报告
-(void)onlineScorer:(EZOnlineScorerRecorder *)scorer didGenerateReport:(NSDictionary *)report{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"生成报告中");

        
    });
}



- (void)dealloc{
    //销毁NSTimer
    if(_timer){
        [_timer invalidate];
        _timer=nil;
    }
}

@end
