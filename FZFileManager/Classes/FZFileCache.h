//
//  FZFileCache.h
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/7/26.
//

#import "FZFileOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface FZFileCache : FZFileOperation

+ (void)writeToCachedWithURL:(NSString *)URL content:(NSObject *)content async:(BOOL)async completedHandler:(void(^)(BOOL result,NSError *error))completedHandler;

+ (void)readCachedWithURL:(NSString *)URL type:(Class)type async:(BOOL)async completedHandler:(void(^)(id result,NSError *error))completedHandler;

+(NSString *)FileCachesPath;

+(BOOL)clearCache;

+(BOOL)clearPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
