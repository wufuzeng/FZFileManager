//
//  FZFileDownloader.m
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/7/27.
//

#import "FZFileDownloader.h"
#import "FZPathOperation.h"
#import "FZFolderOperation.h" 

@interface FZFileDownloader ()
<
NSURLSessionDownloadDelegate//下载监控
>
@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSOperationQueue *queue;

@property (nonatomic,strong) NSMutableDictionary *blockHandlers;

@end

@implementation FZFileDownloader

+ (FZFileDownloader *)sharedDownloader{
    static FZFileDownloader *sharedDownloader = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedDownloader = [[self alloc] init];
    });
    return sharedDownloader;
}

- (NSURLSessionDownloadTask *)fileWithUrl:(NSString *)url
                                 progress:(void (^)(NSUInteger current,NSUInteger total))progress
                                   result:(void (^)(NSData * _Nullable data,NSString * _Nullable path,NSError * _Nullable error))result{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"progressBlock"] = progress;
    info[@"downloadResult"] = result;
    self.blockHandlers[task] = info;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [task resume];
    }];
    [self.queue addOperation:operation];
    return task;
}

//NSData *resumeData = [[NSFileManager defaultManager] contentsAtPath:filePath];
////截止到点中暂停按钮瞬间,服务器返回的数据对象是resumeData
//[self.task cancelByProducingResumeData:^(NSData* resumeData){
//    self.resumeData = resumeData;//将截止到目前的数据储存
//    self.task = nil;
//}];
////设置task为nil
//
////恢复响应中执行如下操作
////重新的发送任务的请求并传入上次暂停前数据参数(继暂停前数据后开始下载)
//self.task = [self.session downloadTaskWithResumeData:self.resumeData];
//[self.task resume];//执行任务
//self.resumeData = nil; //设置resumeData为nil
//

#pragma mark -- NSURLSessionDownloadDelegate - 下载监控 -

// 任务下载
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
 
    NSDictionary * info = self.blockHandlers[downloadTask];
    void (^progressBlock)(NSUInteger current,NSUInteger total) = info[@"progressBlock"];
    //回到主线程更新进度
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger currentLength = totalBytesWritten;
        NSUInteger totalLength = totalBytesExpectedToWrite;
        if (progressBlock) {
            progressBlock(currentLength,totalLength);
        }
    });
}

// 下载任务完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSDictionary * info = self.blockHandlers[downloadTask];
    NSString *downloadPath = [[FZFolderOperation library] stringByAppendingPathComponent:@"Downloads"];
    NSString *fileName = downloadTask.response.suggestedFilename;
    NSString *filePath = [downloadPath stringByAppendingPathComponent:fileName];
    void (^downloadResult)(NSData * _Nullable data,NSString * _Nullable path,NSError * _Nullable error)  = info[@"downloadResult"];
    NSError *fileError = nil;
    [FZPathOperation moveItemAtPath:location.path toPath:filePath overwrite:YES error:&fileError];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    //回到主线程更新进度
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadResult) {
            downloadResult(data,filePath,fileError);
        }
    });
}

#pragma mark –- NSURLSessionTaskDelegate - 任务监控 -
/** 任务结束 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    NSDictionary * info = self.blockHandlers[task];
    void (^downloadResult)(NSData * _Nullable data,NSString * _Nullable path,NSError * _Nullable error) = info[@"downloadResult"];
    [self.blockHandlers removeObjectForKey:task];
    
    if (error && ([error code] != NSURLErrorCancelled)) {
        if (downloadResult) {
            downloadResult(nil,nil,error);
        }
    }
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
