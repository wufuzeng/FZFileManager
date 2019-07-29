//
//  FZFileReceiver.m
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/7/27.
//

#import "FZFileReceiver.h"

#import "FZPathOperation.h"
#import "FZFolderOperation.h"
#import "FZFileOperation.h"
#import <CommonCrypto/CommonDigest.h>


@interface FZFileReceiver ()
<
NSURLSessionDataDelegate//接收监控
>

@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSOperationQueue *queue;
@property (nonatomic,strong) NSMutableDictionary *blockHandlers;

@end

@implementation FZFileReceiver

+ (FZFileReceiver *)sharedReceiver{
    static FZFileReceiver *sharedReceiver = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedReceiver = [[self alloc] init];
    });
    return sharedReceiver;
}

- (NSURLSessionDataTask *)fileWithUrl:(NSString *)url
                             progress:(void (^)(NSUInteger current,NSUInteger total))progress
                               result:(void (^)(NSData * _Nullable data,NSError * _Nullable error))result{
    
    NSString  *filePath = [FZFileReceiver filePathForkey:url];
    [FZFileOperation removeItemAtPath:filePath error:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"progressBlock"] = progress;
    info[@"resultBlock"] = result;
    info[@"filePath"] = filePath;
    self.blockHandlers[task] = info;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [task resume];
    }];
    [self.queue addOperation:operation];
    return task;
}

#pragma mark –- NSURLSessionDataDelegate - 接收监控 -
/** 接收数据回调 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    /*
     * 1>参数dataTask携带信息
     *  dataTask.countOfBytesReceived//已完成任务的长度【int类型】
     *  dataTask.countOfBytesExpectedToReceive;//任务总长度【int类型】
     *  downloadTask.response.suggestedFilename //建议文件名
     * 2>参数data携带信息
     *  data//已接受到任务的内容
     *  data.length//接收到任务的长度
     */
    NSDictionary * info = self.blockHandlers[dataTask];
    NSString *filePath = info[@"filePath"];
    NSFileHandle *fileHandle = info[@"fileHandle"];
    void (^progressBlock)(NSUInteger current,NSUInteger total) = info[@"progressBlock"];
    
    //创建空的目标文件
    NSError *error = nil;
    
    if ([FZPathOperation isExistingFilePath:filePath error:nil] == false ) {
        if([FZFileOperation createFileAtPath:filePath content:nil overwrite:YES attributes:nil error:&error]) {
            //初始化文件句柄对象(写)
            fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
            NSMutableDictionary *newInfo = [NSMutableDictionary dictionaryWithDictionary:info];
            newInfo[@"fileHandle"] = fileHandle;
            self.blockHandlers[dataTask] = newInfo;
        }
    } 
    
    if (fileHandle) {
        @synchronized (self) {
            /** 同步写入 */
            [fileHandle writeData:data];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        /** 回到主线程更新进度 */
        NSUInteger currentLength = dataTask.countOfBytesReceived;
        NSUInteger totalLength = dataTask.countOfBytesExpectedToReceive;
        if (progressBlock) {
            progressBlock(currentLength,totalLength);
        }
    });
}

#pragma mark –- NSURLSessionTaskDelegate - 任务监控 -
/** 任务结束 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    NSDictionary * info = self.blockHandlers[task];
    NSString *filePath = info[@"filePath"];
    NSFileHandle *fileHandle = info[@"fileHandle"];
    void (^resultBlock)(NSData * _Nullable data,NSError * _Nullable error) = info[@"resultBlock"];
    
    [self.blockHandlers removeObjectForKey:task];
    
    [fileHandle closeFile];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        /** 回到主线程更新进度 */
        if (error) {
            if ([error code] != NSURLErrorCancelled) {
                if (resultBlock) {
                    resultBlock(nil,error);
                }
            }
        }else{
            if (resultBlock) {
                [FZFileOperation removeItemAtPath:filePath error:nil];
                resultBlock(data,error);
            }
        }
    });
}

 
+ (NSString *)filePathForkey:(NSString *)key{
    NSString *fileName = [self fileNameForKey:key];
    NSString *downloadPath = [[FZFolderOperation tmp] stringByAppendingPathComponent:@"Receivers"];
    return [downloadPath stringByAppendingPathComponent:fileName];
}

/** MD5 */
+ (NSString *)fileNameForKey:(NSString *)key{
    const char *fooData = [key UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(fooData, (CC_LONG)strlen(fooData), result);
    NSMutableString *saveResult = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [saveResult appendFormat:@"%02x", result[i]];
    }
    return saveResult;
}

#pragma mark -- Lazy Func --



-(NSOperationQueue *)queue{
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc]init];
        _queue.maxConcurrentOperationCount = 2;
    }
    return _queue;
}

-(NSURLSession *)session{
    if (_session == nil) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:self
                                            delegateQueue:self.queue];
    }
    return _session;
}

-(NSMutableDictionary *)blockHandlers{
    if (_blockHandlers == nil) {
        _blockHandlers = [NSMutableDictionary dictionary];
    }
    return _blockHandlers;
}

@end
