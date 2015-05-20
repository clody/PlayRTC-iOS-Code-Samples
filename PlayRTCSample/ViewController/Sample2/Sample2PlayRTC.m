//
//  Sample2PlayRTC.m
//  PlayRTCSample
//
//  Created by ds3grk on 2015. 5. 6..
//  Copyright (c) 2015년 playrtc. All rights reserved.
//

#import "Sample2PlayRTC.h"
#import "Sample2ViewController.h"

#define LOG_TAG @"Sample2PlayRTC"
#define LOG_LEVEL LOG_WARN
#define TDCPROJECTID @"60ba608a-e228-4530-8711-fa38004719c1"

@implementation Sample2PlayRTC
@synthesize isClose;
@synthesize isConnect;
@synthesize channelId;
@synthesize channelName;
@synthesize token;
@synthesize userPid;
@synthesize userUid;
@synthesize otherPeerId;
@synthesize otherPeerUid;
@synthesize playRTC;
@synthesize dataChannel;
@synthesize localVideoView;
@synthesize remoteVideoView;
@synthesize localMedia;
@synthesize remoteMedia;
@synthesize logView;
@synthesize dataView;
@synthesize controller;
- (id)init
{
    
    self = [super init];
    if (self) {
        self.isClose = FALSE;
        self.isConnect = FALSE;
        self.channelId = nil;
        self.channelName = nil;
        self.token = nil;
        self.userPid = nil;
        self.userUid = nil;
        self.otherPeerId = nil;
        self.otherPeerUid = nil;
        self.dataChannel = nil;
        self.localVideoView = nil;
        self.remoteVideoView = nil;
        self.localMedia = nil;
        self.remoteMedia = nil;
        self.logView = nil;
        self.dataView = nil;
        self.controller = nil;
        self.playRTC = [PlayRTCFactory newInstance:(id<PlayRTCObserver>)self];
    }
    return self;
}

- (void)dealloc
{
    self.channelId = nil;
    self.channelName = nil;
    self.token = nil;
    self.userPid = nil;
    self.userUid = nil;
    self.otherPeerId = nil;
    self.otherPeerUid = nil;
    self.playRTC = nil;
    self.dataChannel = nil;
    self.localVideoView = nil;
    self.remoteVideoView = nil;
    self.localMedia = nil;
    self.remoteMedia = nil;
    self.logView = nil;
    self.controller = nil;
    
}

- (void)setConfiguration
{
    isClose = FALSE;
    /*PlayRTCSetting 개체 구하기*/
    PlayRTCSettings* settings = [self.playRTC getSettings];
    
    [settings setTDCProjectId:TDCPROJECTID];
    [settings setTDCHttpReferer:nil];
    
    
    /*영상 및 음성 스트리밍 사용 설정 */
    
    [settings setVideoEnable:FALSE];
    /* camera frony, back */
    [settings.video setFrontCameraEnable:FALSE];
    [settings.video setBackCameraEnable:FALSE];
    
    [settings setAudioEnable:TRUE];
    
    /* 데이터 스트림 사용 여부 */
    [settings setDataEnable:FALSE];
    
    /* ring, 연결 수립 여부를 상대방에게 묻는지 여부를 지정, TRUE면 상대의 수락이 있어야 연결 수립 진행 */
    [settings.channel setRing:FALSE];
    
    
    
    /* SDK Console 로그 레벨 지정 */
    [settings.log.console setLevel:LOG_LEVEL];
    
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    /* SDK 파일 로깅을 위한 로그 파일 경로, 파일 로깅을 사용하지 않는다면 Pass */
    if(FALSE)
    {
        NSString* logPath = [docPath stringByAppendingPathComponent:@"log"];
        /* SDK 파일 로그 레벨 지정 */
        [settings.log.file setLevel:LOG_WARN];
        /* 파일 로그를 남기려면 로그파일 폴더 지정 . [PATH]/yyyyMMdd.log  */
        [settings.log.file setLogPath:logPath];
        [settings.log.file setRolling:10]; /* 10일간 보존 */
    }
    /* 서버 로그 전송 실패 시 임시 로그 DB 저장 폴더 */
    NSString* cachePath = [docPath stringByAppendingPathComponent:@"cache"];
    [settings.log setCachePath:cachePath];
    /* 서버 로그 전송 실패 시 재 전송 지연 시간, msec */
    [settings.log setRetryQueueDelays:1000];
    /* 서버 로그 재 전송 실패시 로그 DB 저장 후 재전송 시도 지연 시간, msec */
    [settings.log setRetryCacheDelays:(10 * 1000)];
    
}

- (void)createChannel:(NSString*)chName userId:(NSString*)userId
{
    if(self.playRTC == nil)
    {
        return;
    }
    self.channelName = chName;
    if(self.channelName == nil) self.channelName = @"";
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    if(channelName != nil) {
        NSDictionary * channel = [NSDictionary dictionaryWithObject:chName forKey:@"channelName"];
        [parameters setObject:channel forKey:@"channel"];
    }
    if(userId != nil) {
        self.userUid = userId;
        NSDictionary * peer = [NSDictionary dictionaryWithObject:userId forKey:@"uid"];
        [parameters setObject:peer forKey:@"peer"];
    }
    else {
        self.userUid = @"";
    }
    NSLog(@"[%@] createChannel channelName[%@] userId[%@]", LOG_TAG, channelName, userId);
    [self.playRTC createChannel:parameters];
    
}
- (void)connectChannel:(NSString*)chId userId:(NSString*)userId
{
    if(self.playRTC == nil)
    {
        return;
    }
    if(chId != nil) {
        self.channelId = chId;
    }
    else {
        self.channelId = @"";
    }
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    if(userId != nil) {
        self.userUid = userId;
        NSDictionary * peer = [NSDictionary dictionaryWithObject:userId forKey:@"uid"];
        [parameters setObject:peer forKey:@"peer"];
    }
    NSLog(@"[%@] connectChannel channelId[%@] userId[%@]", LOG_TAG, chId, userId);
    [self.playRTC connectChannel:self.channelId parameters:parameters];
    
}
- (void)disconnectChannel
{
    if(self.playRTC == nil) {
        [(Sample2ViewController*)self.controller closeController];
        return;
    }
    NSString* peerId = [self.playRTC getPeerId];
    [self.playRTC disconnectChannel:peerId];
}
- (void)deleteChannel
{
    if(self.playRTC == nil) {
        [(Sample2ViewController*)self.controller closeController];
        return;
    }
    [self.playRTC deleteChannel];
}

- (void)userCommand:(NSString*)peerId command:(NSString*)command
{
    [self.playRTC userCommand:peerId data:command];
}
- (void)getChannelList:(id<PlayRTCServiceHelperListener>)listener
{
    [self.playRTC getChannelList:listener];
}

#pragma mark - PlayRTCDataObserver
-(void)onConnectChannel:(PlayRTC*)obj channelId:(NSString*)chId reason:(NSString*)reason
{
    self.channelId = chId;
    NSLog(@"[PlayRTCSample1ViewController] onConnectChannel[%@] reason[%@]", channelId, reason);
    [(Sample2ViewController*)self.controller onConnectChannel:chId reason:reason];
}
-(void)onRing:(PlayRTC*)obj peerId:(NSString*)peerId peerUid:(NSString*)peerUid
{
    
}
-(void)onAccept:(PlayRTC*)obj peerId:(NSString*)peerId peerUid:(NSString*)peerUid
{
    
}
-(void)onReject:(PlayRTC*)obj peerId:(NSString*)peerId peerUid:(NSString*)peerUid
{
    
}
-(void)onUserCommand:(PlayRTC*)obj peerId:(NSString*)peerId peerUid:(NSString*)peerUid data:(NSString*)data
{
    NSLog(@"[%@] onUserCommand peerId[%@] peerUid[%@] data[%@]", LOG_TAG, peerId, peerUid, data);
    [(Sample2ViewController*)self.controller appendLogView:[NSString stringWithFormat:@"onUserCommand peerId[%@] peerUid[%@] data[%@]", peerId, peerUid, data]];
}

-(void)onAddLocalStream:(PlayRTC*)obj media:(PlayRTCMedia*)media
{
    NSLog(@"[%@] onAddLocalStream media[%@]", LOG_TAG, media);
    [(Sample2ViewController*)self.controller appendLogView:@"onAddLocalStream ..."];
    self.localMedia = media;
    
}
-(void)onAddRemoteStream:(PlayRTC*)obj peerId:(NSString*)peerId peerUid:(NSString*)peerUid media:(PlayRTCMedia*)media
{
    NSLog(@"[P%@] onAddRemoteStream peerId[%@] peerUid[%@] media[%@]", LOG_TAG, peerId, peerUid, media);
    [self.controller appendLogView:[NSString stringWithFormat:@"onAddRemoteStream peerId[%@] peerUid[%@]", peerId, peerUid]];
    self.remoteMedia = media;
    
}
-(void)onAddDataStream:(PlayRTC*)obj peerId:(NSString*)peerId peerUid:(NSString*)peerUid data:(PlayRTCData*)data
{
    NSLog(@"[%@] onAddDataStream peerId[%@] peerUid[%@] data[%@]", LOG_TAG, peerId, peerUid, data);
}

-(void)onDisconnectChannel:(PlayRTC*)obj reason:(NSString*)reason
{
    isClose = TRUE;
    NSLog(@"[PlayRTCViewController] onDisconnectChannel reason[%@]", reason);
    [(Sample2ViewController*)self.controller appendLogView:[NSString stringWithFormat:@"onDisconnectChannel reason[%@]", reason]];
    
    NSString* msg = nil;
    if([reason isEqualToString:@"disconnect"])
    {
        msg = @"PlayRTC 채널에서 퇴장하였습니다.\n[이전화면]을 눌러 메뉴 화면으로 이동하세요.";
    }
    else
    {
        msg = @"PlayRTC 채널이 종료되었습니다.\n[이전화면]을 눌러 메뉴 화면으로 이동하세요.";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"채널 퇴장"
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"확인", nil];
    [alert show];
}
-(void)onOtherDisconnectChannel:(PlayRTC*)obj peerId:(NSString*)peerId peerUid:(NSString*)peerUid
{
    NSLog(@"[PlayRTCSample1ViewController] onOtherDisconnectChannel peerId[%@] peerUid[%@]", peerId, peerUid);
    //MainViewController* viewcontroller = (MainViewController*)[self.navigationController popViewControllerAnimated:TRUE];
    //viewcontroller = nil;
    [(Sample2ViewController*)self.controller appendLogView:[NSString stringWithFormat:@"onOtherDisconnectChannel peerId[%@] peerUid[%@]", peerId, peerUid]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:[NSString stringWithFormat:@"[%@]가 채널에서 퇴장하였습니다....\n[나가기]를 눌러 PlayRTC를 종료세요.", peerUid]
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"확인", nil];
    [alert show];
    
}

-(void)onError:(PlayRTC*)obj status:(PlayRTCStatus)status code:(PlayRTCCode)code desc:(NSString*)desc
{
    NSString* sStat = [Sample2PlayRTC getPlayRTCStatusString:status];
    NSString* sCode = [Sample2PlayRTC getPlayRTCCodeString:code];
    NSLog(@"[%@] onError status[%@] code[%@] desc[%@]", LOG_TAG, sStat, sCode, desc);
    
    [(Sample2ViewController*)self.controller appendLogView:[NSString stringWithFormat:@"onError [%@,%@] %@", sStat, sCode, desc]];
    
}
-(void)onStateChange:(PlayRTC*)obj peerId:(NSString*)peerId peerUid:(NSString*)peerUid status:(PlayRTCStatus)status desc:(NSString*)desc
{
    NSString* sStat = [Sample2PlayRTC getPlayRTCStatusString:status];
    NSLog(@"[%@] onStateChange status[%@] desc[%@]", LOG_TAG, sStat, desc);
    [(Sample2ViewController*)self.controller appendLogView:[NSString stringWithFormat:@"onStateChange [%@] %@", sStat, desc]];
}



/////////////////////////////////////////////
+(NSString*)getPlayRTCStatusString:(PlayRTCStatus)status
{
    if(status == PlayRTCStatusNone)
    {
        return @"PlayRTCStatusNone";
    }
    else if(status == PlayRTCStatusInitialize)
    {
        return @"PlayRTCStatusInitialize";
    }
    else if(status == PlayRTCStatusChannelStart)
    {
        return @"PlayRTCStatusChannelStart";
    }
    else if(status == PlayRTCStatusChannelConnect)
    {
        return @"PlayRTCStatusChannelConnect";
    }
    else if(status == PlayRTCStatusLocalMedia)
    {
        return @"PlayRTCStatusLocalMedia";
    }
    else if(status == PlayRTCStatusChanneling)
    {
        return @"PlayRTCStatusChanneling";
    }
    else if(status == PlayRTCStatusRing)
    {
        return @"PlayRTCStatusRing";
    }
    else if(status == PlayRTCStatusPeerCreation)
    {
        return @"PlayRTCStatusPeerCreation";
    }
    else if(status == PlayRTCStatusSignaling)
    {
        return @"PlayRTCStatusSignaling";
    }
    else if(status == PlayRTCStatusPeerConnecting)
    {
        return @"PlayRTCStatusPeerConnecting";
    }
    else if(status == PlayRTCStatusPeerCreation)
    {
        return @"PlayRTCStatusPeerCreation";
    }
    else if(status == PlayRTCStatusPeerDataChannel)
    {
        return @"PlayRTCStatusPeerDataChannel";
    }
    else if(status == PlayRTCStatusPeerMedia)
    {
        return @"PlayRTCStatusPeerMedia";
    }
    else if(status == PlayRTCStatusPeerSuccess)
    {
        return @"PlayRTCStatusPeerSuccess";
    }
    else if(status == PlayRTCStatusPeerConnected)
    {
        return @"PlayRTCStatusPeerConnected";
    }
    else if(status == PlayRTCStatusPeerDisconnected)
    {
        return @"PlayRTCStatusPeerDisconnected";
    }
    else if(status == PlayRTCStatusPeerClosed)
    {
        return @"PlayRTCStatusPeerClosed";
    }
    else if(status == PlayRTCStatusUserCommand)
    {
        return @"PlayRTCStatusUserCommand";
    }
    else if(status == PlayRTCStatusChannelDisconnected)
    {
        return @"PlayRTCStatusChannelDisconnected";
    }
    else if(status == PlayRTCStatusClosed)
    {
        return @"PlayRTCStatusClosed";
    }
    else if(status == PlayRTCStatusNetworkConnected)
    {
        return @"PlayRTCStatusNetworkConnected";
    }
    else if(status == PlayRTCStatusNetworkDisconnected)
    {
        return @"PlayRTCStatusNetworkDisconnected";
    }
    return @"";
}
+(NSString*)getPlayRTCCodeString:(PlayRTCCode)code
{
    if(code == PlayRTCCodeNone)
    {
        return @"PlayRTCCodeNone";
    }
    else if(code == PlayRTCCodeMissingParameter)
    {
        return @"PlayRTCCodeMissingParameter";
    }
    else if(code == PlayRTCCodeInvalidParameter)
    {
        return @"PlayRTCCodeInvalidParameter";
    }
    else if(code == PlayRTCCodeVersionUnsupported)
    {
        return @"PlayRTCCodeVersionUnsupported";
    }
    else if(code == PlayRTCCodeNotInitialize)
    {
        return @"PlayRTCCodeNotInitialize";
    }
    else if(code == PlayRTCCodeMediaUnsupported)
    {
        return @"PlayRTCCodeMediaUnsupported";
    }
    else if(code == PlayRTCCodeConnectionFail)
    {
        return @"PlayRTCCodeConnectionFail";
    }
    else if(code == PlayRTCCodeDisconnectFail)
    {
        return @"PlayRTCCodeDisconnectFail";
    }
    else if(code == PlayRTCCodeSendRequestFail)
    {
        return @"PlayRTCCodeSendRequestFail";
    }
    else if(code == PlayRTCCodeMessageSyntax)
    {
        return @"PlayRTCCodeMessageSyntax";
    }
    else if(code == PlayRTCCodeProjectIdInvalid)
    {
        return @"PlayRTCCodeProjectIdInvalid";
    }
    else if(code == PlayRTCCodeTokenInvalid)
    {
        return @"PlayRTCCodeTokenInvalid";
    }
    else if(code == PlayRTCCodeTokenExpired)
    {
        return @"PlayRTCCodeTokenExpired";
    }
    else if(code == PlayRTCCodeChannelIdInvalid)
    {
        return @"PlayRTCCodeChannelIdInvalid";
    }
    else if(code == PlayRTCCodeServiceError)
    {
        return @"PlayRTCCodeServiceError"; 
    }
    else if(code == PlayRTCCodePeerMaxCount)
    {
        return @"PlayRTCCodePeerMaxCount";
    }
    else if(code == PlayRTCCodePeerIdInvalid)
    {
        return @"PlayRTCCodePeerIdInvalid";
    }
    else if(code == PlayRTCCodePeerIdAlready)
    {
        return @"PlayRTCCodePeerIdAlready";
    }
    else if(code == PlayRTCCodePeerInternalError)
    {
        return @"PlayRTCCodePeerInternalError";
    }
    else if(code == PlayRTCCodePeerConnectionFail)
    {
        return @"PlayRTCCodePeerConnectionFail";
    }
    else if(code == PlayRTCCodeSdpCreationFail)
    {
        return @"PlayRTCCodeSdpCreationFail";
    }
    else if(code == PlayRTCCodeSdpRegistrationFail)
    {
        return @"PlayRTCCodeSdpRegistrationFail";
    }
    else if(code == PlayRTCCodeDataChannelCreationFail)
    {
        return @"PlayRTCCodeDataChannelCreationFail";
    }
    else if(code == PlayRTCCodeNotConnect)
    {
        return @"PlayRTCCodeNotConnect";
    }
    else if(code == PlayRTCCodeConnectAlready)
    {
        return @"PlayRTCCodeConnectAlready";
    }
    return @"";
}

@end


