//
//  FirstViewController.m
//  文字转语音
//
//  Created by HuangXunhui on 2017/6/6.
//  Copyright © 2017年 HuangXunhui. All rights reserved.
//

#import "FirstViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface FirstViewController ()<AVSpeechSynthesizerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *readTextButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property(strong,nonatomic) AVSpeechSynthesizer *speechSynthesizer;
@property(strong,nonatomic) AVSpeechUtterance *utterance;
@property(strong,nonatomic) NSArray *speechTextArray;
@property(strong,nonatomic) AVSpeechSynthesisVoice *voiceType;
@property(nonatomic,strong) NSMutableArray *highlightLayers;
@property(nonatomic,assign) BOOL isTapToRead;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.highlightLayers = [NSMutableArray array];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _textView.layer.borderWidth = 1;
    _textView.layer.borderColor = [UIColor grayColor].CGColor;
    
    [self setBtnProperty:_readTextButton];
    [self setBtnProperty:_stopButton];
    
    _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    _speechSynthesizer.delegate = self;
    
    _textView.text = @"\t深圳，简称“深”，别称鹏城，中国四大一线城市之一，广东省省辖市、计划单列市、副省级市、国家区域中心城市、超大城市。地处广东南部，珠江三角洲东岸，与香港一水之隔，东临大亚湾和大鹏湾，西濒珠江口和伶仃洋，南隔深圳河与香港相连，北部与东莞、惠州接壤。\n\t深圳是国务院定位的全国性经济中心和国际化城市，与北京、上海、广州并称“北上广深”。全市下辖福田区、龙岗区、罗湖区、宝安区、南山区、盐田区、龙华区、坪山区8个行政区。\n\t深圳是中国改革开放建立的第一个经济特区，是中国改革开放的窗口，已发展为有一定影响力的国际化城市，创造了举世瞩目的“深圳速度”，同时享有“设计之都”、“钢琴之城”、“创客之城”等美誉。\n\t深圳市域边界设有中国最多的出入境口岸。深圳也是重要的边境口岸城市，皇岗口岸实施24小时通关。Hello World! Let's do it.";
    
    //按句号断句
    _speechTextArray = [_textView.text componentsSeparatedByString:@"。"];
    
    _voiceType = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh_CN"];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];//创建单例对象并且使其设置为活跃状态.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)   name:AVAudioSessionRouteChangeNotification object:nil];//设置通知
    [self setproximity];
    
    if ([self isHeadsetPluggedIn]) {
        //设置AVAudioSession 的播放模式
        //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }else{
        //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
    
    //单击手势：获取tap手势下textview的当前sentence
    [_textView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getPressedWordWithRecognizer:)]];
}

#pragma mark - 获取tap手势下textview的当前sentence
- (NSString*)getPressedWordWithRecognizer:(UIGestureRecognizer*)recognizer
{
    //    //get view
    //    UITextView *textView = (UITextView *)recognizer.view;
    //    //get location
    //    CGPoint location = [recognizer locationInView:textView];
    //    UITextPosition *tapPosition = [textView closestPositionToPoint:location];
    //    UITextRange *textRange = [textView.tokenizer rangeEnclosingPosition:tapPosition withGranularity:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    //
    //    NSString *tapString = [textView textInRange:textRange];
    //    NSLog(@"%@",tapString);
    //    //return string
    //    return tapString;
    _isTapToRead = YES;
    UITextView *textView_New = (UITextView *)recognizer.view;
    CGPoint pos = [recognizer locationInView:textView_New];
    //    NSLog(@"Tap Gesture Coordinates: %.2f %.2f", pos.x, pos.y);
    UITextPosition *tapPos = [textView_New closestPositionToPoint:pos];
    UITextRange * wr = [textView_New.tokenizer rangeEnclosingPosition:tapPos withGranularity:UITextGranularitySentence inDirection:UITextLayoutDirectionRight];
    NSString *selectedText = [textView_New textInRange:wr];
    //    NSLog(@"selectedText: %@", selectedText);
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:selectedText];
    if (self.speechSynthesizer.isSpeaking && [textView_New.text containsString:selectedText]) {
        [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        _isTapToRead = YES;
    }
    utterance.volume = 1;
    utterance.pitchMultiplier = 0.8;//音调
    utterance.voice = _voiceType;//语言
    utterance.rate = 0.5;//说话速率
    [_speechSynthesizer speakUtterance:utterance];
    _isTapToRead = YES;
    return selectedText;
}

//// 开始移动
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"开始移动");
//}
//// 正在移动
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"正在移动");
//}
//// 移动结束
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"移动结束");
//}

#pragma mark - 耳机拔插通知方法的实现
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"耳机插入 == AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            NSLog(@"耳机拔出，停止播放操作 == AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

#pragma mark - 语音转文本核心方法
- (void)beginConversation {
    for (int i = 0; i < self.speechTextArray.count; i++) {
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:self.speechTextArray[i]];
        utterance.volume = 1;
        utterance.pitchMultiplier = 0.8;//音调
        utterance.voice = _voiceType;//语言
        utterance.rate = 0.5;//说话速率
        [_speechSynthesizer speakUtterance:utterance];
    }
    _isTapToRead = NO;
}

#pragma mark - 检查耳机是否插入
- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

- (void)setBtnProperty:(UIButton *)button {
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor redColor].CGColor;
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Actions
- (IBAction)readText:(id)sender {
    if (!self.speechSynthesizer.isSpeaking) {
        [self beginConversation];
        //        [self.speechSynthesizer speakUtterance:_utterance];;
    }else {
        if (self.speechSynthesizer.isSpeaking && !self.speechSynthesizer.isPaused) {
            [self.speechSynthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        }else if(self.speechSynthesizer.isPaused && self.speechSynthesizer.isSpeaking){
            [self.speechSynthesizer continueSpeaking];
        }
    }
}

- (IBAction)stopReadText:(id)sender {
    [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    [_readTextButton setTitle:@"开始" forState:UIControlStateNormal];
}

#pragma mark - 阅读时文本高亮核心方法
- (void)drawLayerForTextHighlightWithString:(NSString*)string {
    
    for (CALayer* eachLayer in [self highlightLayers]) {
        [eachLayer removeFromSuperlayer];
    }
    
    NSLayoutManager* manager = [[self textView]layoutManager];
    if ([string hasPrefix:@"\n\t"]) {
       string = [string stringByReplacingOccurrencesOfString:@"\n\t" withString:@""];
    }
    if ([string hasPrefix:@"\t"]) {
      string =  [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    }
    // Find the string
    NSRange match = [[[self textView]text]rangeOfString:string options:
                     NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch];
    
    // Convert it to a glyph range
    NSRange matchingGlyphRange = [manager glyphRangeForCharacterRange:match actualCharacterRange:NULL];
    
    // Enumerate each line in that glyph range (this will fire for each line that the match spans)
    [manager enumerateLineFragmentsForGlyphRange:matchingGlyphRange usingBlock:
     ^(CGRect lineRect, CGRect usedRect, NSTextContainer *textContainer, NSRange lineRange, BOOL *stop) {
         
         // currentRange uses NSIntersectionRange to return the range of the text that is on the current line
         NSRange currentRange = NSIntersectionRange(lineRange, matchingGlyphRange);
         
         // This rect will be built by enumerating each character in the line, and adding to it's width
         __block CGRect finalLineRect = CGRectZero;
         
         // Here we use enumerateSubstringsInRange:... to go through each glyph and build the final rect for the line
         [[[self textView]text]enumerateSubstringsInRange:currentRange options:NSStringEnumerationByComposedCharacterSequences usingBlock:
          ^(NSString* substring, NSRange substringRange, NSRange enclostingRange, BOOL* stop) {
              
              // The range of the single glyph being enumerated
              NSRange singleGlyphRange =  [manager glyphRangeForCharacterRange:substringRange actualCharacterRange:NULL];
              
              // get the rect for that glyph
              CGRect glyphRect = [manager boundingRectForGlyphRange:singleGlyphRange inTextContainer:textContainer];
              
              // check to see if this is the first iteration, if not add the width to the final rect for the line
              if (CGRectEqualToRect(finalLineRect, CGRectZero)) {
                  finalLineRect = glyphRect;
              } else {
                  finalLineRect.size.width += glyphRect.size.width;
              }
              
          }];
         
         // once we get the rect for the line, draw the layer
         UIEdgeInsets textContainerInset = [[self textView]textContainerInset];
         finalLineRect.origin.x += textContainerInset.left;
         finalLineRect.origin.y += textContainerInset.top;
         
         CALayer *roundRect = [CALayer layer];
         [roundRect setFrame:finalLineRect];
         [roundRect setBounds:finalLineRect];
         
         //         [roundRect setCornerRadius:5.0f];
         [roundRect setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.5].CGColor];
         [roundRect setOpacity:0.5f];
         //         [roundRect setBorderColor:[[UIColor blackColor]CGColor]];
         //         [roundRect setBorderWidth:3.0f];
         //         [roundRect setShadowColor:[[UIColor blackColor]CGColor]];
         //         [roundRect setShadowOffset:CGSizeMake(20.0f, 20.0f)];
         //         [roundRect setShadowOpacity:1.0f];
         //         [roundRect setShadowRadius:10.0f];
         
         [[[self textView]layer]addSublayer:roundRect];
         [[self highlightLayers]addObject:roundRect];
         
     }];
}

#pragma mark - AVSpeechSynthesizerDelegate
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
        [self drawLayerForTextHighlightWithString:utterance.speechString];
        [_readTextButton setTitle:@"暂停" forState:UIControlStateNormal];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance {
    [_readTextButton setTitle:@"继续" forState:UIControlStateNormal];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance {
    [_readTextButton setTitle:@"暂停" forState:UIControlStateNormal];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    if (_isTapToRead == YES || ([utterance.speechString isEqualToString:_speechTextArray.lastObject] && _isTapToRead == NO)) {
        [_readTextButton setTitle:@"开始" forState:UIControlStateNormal];
    }
    for (CALayer* eachLayer in [self highlightLayers]) {
        [eachLayer removeFromSuperlayer];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    [_readTextButton setTitle:@"开始" forState:UIControlStateNormal];
    for (CALayer* eachLayer in [self highlightLayers]) {
        [eachLayer removeFromSuperlayer];
    }
}

#pragma mark - 设置距离传感器
- (void)setproximity{
    //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    if ([UIDevice currentDevice].proximityMonitoringEnabled) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
}

#pragma mark - proximityState 属性 如果用户接近手机，此时属性值为YES，并且屏幕关闭（非休眠）。
-(void)sensorStateChange:(NSNotificationCenter *)notification{
    if ([self isHeadsetPluggedIn]) {
        return;
    }
    if ([[UIDevice currentDevice] proximityState]) {
        NSLog(@"靠近话筒");
        //设置AVAudioSession 的播放模式
        //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }else{
        NSLog(@"离开话筒");
        //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
}

- (void)dealloc{
    if ([UIDevice currentDevice].proximityMonitoringEnabled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
