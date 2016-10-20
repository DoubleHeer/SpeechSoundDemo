//
//  ViewController.m
//  SpeechSoundDemo
//
//  Created by heer on 2016/10/20.
//  Copyright © 2016年 heer. All rights reserved.
//

#import "ViewController.h"
#import "iflyMSC/iflyMSC.h"
#import "ISRDataHelper.h"

@interface ViewController ()<IFlySpeechRecognizerDelegate,UITextViewDelegate>
//语音识别对象
@property (nonatomic,strong) IFlySpeechRecognizer *iFlySpeechRecognizer;
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (weak, nonatomic) IBOutlet UILabel *showProcessLb;

@property (nonatomic) BOOL isCanceled;
@property (nonatomic,strong) NSMutableString *resultStr;
@end

@implementation ViewController
-(NSMutableString *)resultStr {
    if (!_resultStr) {
        _resultStr = [NSMutableString new];
    }
    return _resultStr;
}
//初始化设置识别参数
-(IFlySpeechRecognizer *)iFlySpeechRecognizer {
    if (!_iFlySpeechRecognizer) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        _iFlySpeechRecognizer.delegate = self;
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        //2.设置听写参数
        [_iFlySpeechRecognizer setParameter: @"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
        //asr_audio_path是录音文件名，设置value为nil或者为空取消保存，默认保存目录在 Library/cache下。
        [_iFlySpeechRecognizer setParameter:@"asrview.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
    }
    return _iFlySpeechRecognizer;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isCanceled = NO;
    self.textview.delegate = self;
}
#pragma mark -UITextViewDelegate
-(void)textViewDidEndEditing:(UITextView *)textView {
    self.resultStr = [textView.text mutableCopy];
}
#pragma mark - Btn
//开始听
- (IBAction)beginRecode:(id)sender {
    if ([self.iFlySpeechRecognizer isListening]) {
        self.showProcessLb.text = @"点击开始录音:正在录音，点击无效";
        NSLog(@"正在录音，点击无效");
        return ;
    }
 
    BOOL success = [self.iFlySpeechRecognizer startListening];
    if (success) {
        self.isCanceled = NO;
        self.showProcessLb.text = @"点击开始录音:录音中...";
        NSLog(@"开始录音");
    } else {
        self.showProcessLb.text = @"点击开始录音:哎呀，出意外了";
        NSLog(@"哎呀，出意外了");
    }
   
}
//停止听
- (IBAction)endRecode:(id)sender {
    
    [self.iFlySpeechRecognizer stopListening];
    self.showProcessLb.text = @"点击停止录音:停止录音,开始识别";
    NSLog(@"停止录音,开始识别");
 
}
//清空内容
- (IBAction)clearTextviewContent:(id)sender {
    self.resultStr = [NSMutableString string];
    self.textview.text = @"";
    self.showProcessLb.text = @"点击清空内容:清空内容";
    NSLog(@"清空内容");
}
//取消录音
- (IBAction)cancelRecode:(id)sender {
    if (![self.iFlySpeechRecognizer isListening]) {
        self.showProcessLb.text = @"点击取消录音:没有正在进行的录音";
        NSLog(@"没有正在进行的录音，直接返回");
        return ;
    }
    self.isCanceled = YES;
    [self.iFlySpeechRecognizer cancel];
    self.showProcessLb.text = @"点击取消录音:取消录音,不进行识别";
    NSLog(@"取消录音,不进行识别");
}

#pragma mark -IFlySpeechRecognizerDelegate
/*识别结果返回代理
 @param :results识别结果
 @ param :isLast 表示是否最后一次结果
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast {
    NSMutableString *result = [[NSMutableString alloc] init];
    NSMutableString * resultString = [[NSMutableString alloc]init];
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        
        [result appendFormat:@"%@",key];
        
        NSString * resultFromJson =  [ISRDataHelper stringFromABNFJson:result];
        [resultString appendString:resultFromJson];
        
    }
    if (isLast) {
        
        NSLog(@"result is:%@",self.resultStr);
    }
    [self.resultStr appendString:resultString];
    
}
/*识别会话结束返回代理
 @ param error 错误码,error.errorCode=0表示正常结束，非0表示发生错误。 */
- (void)onError: (IFlySpeechError *) error {
    
    NSLog(@"error=%d",[error errorCode]);
    
    NSString *text ;
    if (self.isCanceled) {
        
        NSLog(@"取消录音,不进行识别，但仍走此回调");
    } else if (error.errorCode ==0 ) {
        
        if (self.resultStr.length==0 || [self.resultStr hasPrefix:@"nomatch"]) {
            self.showProcessLb.text = @"识别结果回调:无匹配结果";
            text = @"无匹配结果";
        } else {
            self.showProcessLb.text = @"识别结果回调:识别成功";
            text = @"识别成功";
            self.textview.text = self.resultStr;
        }
    } else {
        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
        self.showProcessLb.text = [NSString stringWithFormat:@"识别结果回调:%@",text];
        NSLog(@"%@",text);
    }
    
    
 }
/**
 停止录音回调
 ****/
- (void) onEndOfSpeech {

}
/**
 开始识别回调
 ****/
- (void) onBeginOfSpeech {
    
}
/**
 音量回调函数 volume 0-30
 **/

 - (void) onVolumeChanged: (int)volume {
 
 }



@end
