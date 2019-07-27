//
//  FZFileReceiver.h
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/7/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FZFileReceiver : NSObject

+ (FZFileReceiver *)sharedReceiver;

- (NSURLSessionDataTask *)fileWithUrl:(NSString *)url
                             progress:(void (^)(NSUInteger current,NSUInteger total))progress
                               result:(void (^)(NSData * _Nullable data,NSError * _Nullable error))result;
 
@end

NS_ASSUME_NONNULL_END
